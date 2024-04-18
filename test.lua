debug.getregistry().MATH3D_MAXPAGE = 1024

local math3d = require "math3d"

local tu = require "test.util"
do
	print "---- constant -------"
	local c = math3d.constant "null"
	print(c, math3d.mark(c))
	print("Identity Null",math3d.tostring(c))
	local c = math3d.constant "v4"
	print("Identity Vec4", math3d.tostring(c))
	local c = math3d.constant "quat"
	print("Identity Quat", math3d.tostring(c))
	local c = math3d.constant "mat"
	print("Identity Mat",math3d.tostring(c))
	local c1 = math3d.matrix {}
	assert(c == c1)
	local c2 = math3d.matrix { s = 1 }
	assert(c == c2)
	local c3 = math3d.matrix { s = 1 , t = { 0,0,0 } }
	assert(c == c3)

	assert(math3d.vector() == math3d.constant "v4")
	assert(math3d.constant("v4", {0,0,0,1}) == math3d.constant "v4")
	assert(math3d.constant("v4", math3d.vector(0,0,0,1)) == math3d.constant "v4")

	assert(math3d.quaternion() == math3d.constant "quat")
	assert(math3d.constant("quat", {0,0,0,1}) == math3d.constant "quat")
	assert(math3d.constant("quat", math3d.quaternion(0,0,0,1)) == math3d.constant "quat")

	assert(math3d.matrix() ==  math3d.constant "mat")
	assert(math3d.matrix{} ==  math3d.constant "mat")
	assert(math3d.constant("mat", {1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1}) == math3d.constant "mat")
	assert(math3d.constant("mat", math3d.matrix(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)) == math3d.constant "mat")

	local vec = math3d.constant { type = "v4", 1,2,3,4 }
	print(vec, math3d.tostring(vec))

	local vec2 = math3d.constant { type = "v4", 1,2,3,4 }
	print(vec2, math3d.tostring(vec))

	assert(vec == vec2)

	local vec = math3d.constant ("v4", { 0,0,0,0 })
	print(vec, math3d.tostring(vec))

	local aabb = math3d.constant { type = "aabb", 1,1,1,2,2,2 }
	print(aabb, math3d.tostring(aabb))

	local vec = math3d.constant { type = "v4", 1,1,1,0 }
	print(vec, math3d.tostring(vec))
end

do
	print "---- serialize ----"
	local c = math3d.matrix { s = 1 }
	local s = math3d.serialize(c)
	local c2 = math3d.matrix(s)
	print(math3d.tostring(c))
	print(math3d.tostring(c2))
end

local ref1, ref2, ref3

do
	print "----- ref ------"

	ref1 = math3d.ref()

	ref1.m = { s = 10, r = { axis = {1,0,0}, r = math.rad(60) },  t = { 1,2,3 } }

	ref1[4] = { 4,5,6 }

	ref2 = math3d.ref()

	ref2.v = math3d.vector(1,2,3,4)

	print("ref1", ref1)
	print("ref1 value", math3d.tostring(ref1))
	print(ref2)
	print("ref2 value", math3d.tostring(math3d.vector(ref2)))
	ref2.v = math3d.pack("dddd", 1,2,3,4)
	print(ref2)
	ref2.v = math3d.vector(ref2, 1)
	print("ref2", ref2)
end

print "-----pow&log-----"
do
	local v = math3d.vector(2, 2, 2, 1)
	local ev = math3d.pow(v)	--result : (e^2, e^2, e^2, e^1)
	print("pow(v) with e base:", math3d.tostring(ev))

	local v3 = math3d.pow(v, 3)	-- result : (3^2, 3^2, 3^2, 1^2)
	print("pow(v, 3):", math3d.tostring(v3))

	local lev = math3d.log(ev)	-- result: (loge(e^2), loge(e^2), loge(e^2), loge(e^1)) = (2, 2, 2, 1)
	print("log(ev) with e base:", math3d.tostring(lev))

	local vv = math3d.log(v3, 3)
	print("log(v3, 3):", math3d.tostring(vv))
end

print "-----plane test-----"
do
	--[[
		    local d1dotn = math3d.dot(plane, ray.d)
			local t = 0.0
			if math.abs(d1dotn) > 1e-7 then
				local dis = math3d.index(plane, 4)
				local odotn = math3d.dot(ray.o, plane)
				t = (dis - odotn) / d1dotn
			end
			local intersetion_pt = math3d.muladd(ray.d, tt, ray.o)
	]]
	local plane_pos = math3d.vector(0, 3, 0)
	local plane_dir = math3d.vector(0, 10, 0)
	local plane = math3d.plane(plane_pos, plane_dir)

	local ray = {o = math3d.vector(0, 10, 0), d = math3d.vector(0.0, -3, 0.0)}
	local tt = math3d.plane_ray(ray.o, ray.d, plane)
	if tt == nil then
		print "plane parallel with ray"
	elseif tt < 0 then
		print "plane intersetion in ray backward"
	else
		print "plane intersetion with plane front face"
	end

	local intersetion_pt = math3d.muladd(ray.d, tt, ray.o)
	print(math3d.tostring(intersetion_pt))
end

local corner_names = {
	"lbn", "ltn", "rbn", "rtn",
	"lbf", "ltf", "rbf", "rtf",
}

local function print_box_points(points, tabnum)
	assert(math3d.array_size(points) == 8)

	local function point_name(pidx, tabnum)
		return ('\t'):rep(tabnum or 0) .. ("%s: %s"):format(corner_names[pidx], math3d.tostring(math3d.array_index(points, pidx)))
	end

	local function point_pairs(pidx1, pidx2, tabnum)
		return ("%s;\t%s"):format(point_name(pidx1, tabnum), point_name(pidx2))
	end
	local t = {
		point_pairs(1, 5, tabnum),
		point_pairs(2, 6, tabnum),
		point_pairs(3, 7, tabnum),
		point_pairs(4, 8, tabnum),
	}

	return print(table.concat(t, "\n"))
end

local function print_box_planes(planes, tabnum)
	assert(math3d.array_size(planes) == 6)

	local function plane_name(pidx, tabnum)
		return tu.tabs(tabnum) .. math3d.tostring(math3d.array_index(planes, pidx))
	end
	local t = {}
	for i=1, 6 do
		t[#t+1] = plane_name(i, tabnum)
	end

	print(table.concat(t, '\n'))
end

print "----- ray/line interset with triangles -----"
do
	local v0, v1, v2 = math3d.vector(-1.0, 0.0, 0.0, 1.0), math3d.vector(0.0, 1.0, 0.0, 1.0), math3d.vector(1.0, 0.0, 0.0, 1.0)
	print "\ttriangle1:"
	tu.print_triangle(v0, v1, v2, 1)

	local v3, v4, v5 = math3d.vector(-1.0, 0.0, 2.0, 1.0), math3d.vector(0.0, 1.0, 2.0, 1.0), math3d.vector(1.0, 0.0, 2.0, 1.0)
	print "\ttriangle2:"
	tu.print_triangle(v3, v4, v5, 1)

	local v6, v7, v8 = math3d.vector(0.0, 0.0, 1.0, 1.0), math3d.vector(0.0, 1.0, 0.0, 1.0), math3d.vector(0.0, 0.0, -1.0, 1.0)
	print "\ttriangle3:"
	tu.print_triangle(v6, v7, v8, 1)

	local ray = {o=math3d.vector(0.0, 0.0, 0.0), d=math3d.vector(0.0, 0.0, 1.0)}
	print "\tinterset with ray:"
	tu.print_ray(ray, 1)

	print "\tsegment1 interset with triangle:"
	local s0, s1 = math3d.vector(0, 0, 1, 1), math3d.vector(0, 0, 3, 1)

	print("\tstart point:", math3d.tostring(s0))
	print("\tend point:", math3d.tostring(s1))

	local interset, t = math3d.triangle_ray(ray.o, ray.d, v0, v1, v2)
	if interset then
		print(("\tray triangle interset result:%f, point:%s"):format(t, math3d.tostring(math3d.muladd(ray.d, t, ray.o))))
	else
		print "\tray NOT interset with triangle"
	end

	print"\tsegment with triangle1:"
	interset, t = math3d.triangle_ray(s0, math3d.sub(s1, s0), v0, v1, v2)
	print("\tsegment interset with triangle1: ", interset, "t: ", t, "is in the segment:", 0<=t and t<=1.0)

	interset, t = math3d.triangle_ray(s0, math3d.sub(s1, s0), v3, v4, v5)
	print("\tsegment interset with triangle2: ", interset, "t: ", t, "is in the segment:", 0<=t and t<=1.0)

	interset, t = math3d.triangle_ray(s0, math3d.sub(s1, s0), v6, v7, v8)
	print("\tsegment interset with triangle3: ", interset, "t: ", t or "no intersect")

	print "\tray intersect with box:"
	local boxcorners = {math3d.vector(-1.0, -1.0, -1.0), math3d.vector(1.0, 1.0, 1.0)}
	local aabb = math3d.aabb(boxcorners[1], boxcorners[2])
	local aabbpoints = math3d.aabb_points(aabb)

	print "\tray intersect with aabb points:"
	print_box_points(aabbpoints, 2)

	local ray1 = {o=math3d.vector(0.0, 0.0, 0.0, 1.0), d=math3d.vector(0.0, 0.0, -1.0)}
	local function do_ray_box_test(ray, boxpoints)
		print "\tray:"
		tu.print_ray(ray, 2)
		local resultpoints = math3d.ray_intersect_box(ray.o, ray.d, boxpoints)
		print "\tray intersect results:"
		tu.print_points(resultpoints, 2)
		return resultpoints
	end

	print "\tray box test 1:"
	local results = do_ray_box_test(ray1, aabbpoints)
	assert(math3d.array_size(results) == 1)

	print "\tray box test 2:"
	local ray2 = tu.create_ray(math3d.vector(0.0, 0.0, -1.0, 1.0), math3d.vector(-1.0, 0.0, 0.0, 1.0))
	results = do_ray_box_test(ray2, aabbpoints)
	assert(math3d.array_size(results) == 2)

	print "\tray box test 3:"
	--local ray3 = create_ray(math3d.array_index(aabbpoints, 1), math3d.array_index(aabbpoints, 5))
	local ray3 = tu.create_ray(math3d.vector(0.0, 0.0, -1.0, 1.0), math3d.vector(0.0, 0.0, 1.0, 1.0))
	results = do_ray_box_test(ray3, aabbpoints)
	assert(math3d.array_size(results) == 2)

	print "\tray box test 4:"
	local ray4 = tu.create_ray(math3d.vector(-1.0, 0.0, 0.0, 1.0), math3d.vector(1.0, 0.0, 1.0, 1.0))
	results = do_ray_box_test(ray4, aabbpoints)
	assert(math3d.array_size(results) == 2)

	local aabb2 = math3d.aabb(math3d.vector(0.0, 0.0, 0.0, 0.0), math3d.vector(2.0, 2.0, 2.0, 0.0))
	local aabbpoints2 = math3d.aabb_points(aabb2)
	print "\taabb2 points:"
	print_box_points(aabbpoints2, 2)

	print "\tray box test 5:"
	local ray5 = tu.create_ray(math3d.vector(0.0, 0.0, 0.0, 1.0), math3d.vector(2.0, 2.0, 2.0, 1.0))
	results = do_ray_box_test(ray5, aabbpoints2)
	assert(math3d.array_size(results) == 2)

	print "\tray box test 6:"
	local ray6 = tu.create_ray(math3d.vector(1.0, 1.0, -1.0, 1.0), math3d.vector(2.0, 2.0, 2.0, 1.0))
	results = do_ray_box_test(ray6, aabbpoints2)
	assert(math3d.array_size(results) == 2)
end

print "===SRT==="
do
	ref1.m = { r = { 0, math.rad(60), 0 }, t = { 1,2,3} }	-- .s = 1
	print(ref1)
	local s,r,t = math3d.srt(ref1)
	print("S = ", math3d.tostring(s))
	print("R = ", math3d.tostring(r))
	print("T = ", math3d.tostring(t))

	local function print_srt()
		print("S = ", math3d.tostring(ref1.s))
		print("R = ", math3d.tostring(ref1.r))
		print("T = ", math3d.tostring(ref1.t))
	end

	print_srt()
end

print "===QUAT==="
do
	local q = math3d.quaternion { 0, math.rad(60), 0 }
	print(math3d.tostring(q))
	ref3 = math3d.ref()
	ref3.m = math3d.quaternion { axis = {1,0,0}, r = math.rad(60) } -- init mat with quat
	print(ref3)
	ref3.q = ref3	-- convert mat to quat
	print(ref3)

	print(math3d.tostring(math3d.constant "quat", math3d.constant "quat"))	-- Identity quat
end

print "===FUNC==="
do
	ref2.v = math3d.vector(1,2,3,4)
	print(ref2)
	ref2.v = math3d.add(ref2,ref2,ref2)
	print(ref2)
	ref2.v = math3d.mul(ref2, 2.5)

	print("length", ref2, "=", math3d.length(ref2))
	print("floor", ref2, "=", math3d.tostring(math3d.floor(ref2)))
	print("dot", ref2, ref2, "=", math3d.dot(ref2, ref2))
	print("cross", ref2, ref2, "=", math3d.tostring(math3d.cross(ref2, ref2)))
	print("normalize", ref2, "=", math3d.tostring(math3d.normalize(ref2)))
	print("normalize", ref3, "=", math3d.tostring(math3d.normalize(ref3)))
	print("transpose", ref1, "=", math3d.tostring(math3d.transpose(ref1)))
	local point = math3d.vector(1, 2, 3, 1)
	print("transformH", ref1, point, "=", math3d.tostring(math3d.transformH(ref1, point)))
	print("inverse", ref1, "=", math3d.tostring(math3d.inverse(ref1)))
	print("inverse", ref2, "=", math3d.tostring(math3d.inverse(ref2)))
	print("inverse", ref3, "=", math3d.tostring(math3d.inverse(ref3)))
	print("reciprocal", ref2, "=", math3d.tostring(math3d.reciprocal(ref2)))

	print("add with number", math3d.tostring(math3d.add(1, math3d.vector(2, 2, 2), 3)))
	print("sub with number", math3d.tostring(math3d.sub(1, math3d.vector(2, 2, 2))))
end

print "===INVERSE==="
do
	local m = math3d.lookto(math3d.vector(1, 2, 1), math3d.vector(1, -1, 1))
	local imf = math3d.inverse_fast(m)
	local mf = math3d.inverse(m)

	print("look to matrix:", math3d.tostring(m))
	print("inverse fast:", math3d.tostring(imf))
	print("inverse:", math3d.tostring(mf))
end

print "===MULADD==="
do
	local v1, v2 = math3d.vector(1, 2, 3, 0), math3d.vector(1, 0, 0, 0)
	local p = math3d.vector(4, 1, 0, 1)
	local r = math3d.muladd(v1, v2, p)
	print("muladd:", math3d.tostring(v1), math3d.tostring(v2), math3d.tostring(p), "=", math3d.tostring(r))
end

print "===VIEW&PROJECTION MATRIX==="
do
	local eyepos = math3d.vector( 0, 5, -10 )
	local at = math3d.vector (0, 0, 0)
	local direction = math3d.normalize(math3d.vector (1, 1, 1))
	local updir = math3d.vector (0, 1, 0)

	local mat1 = math3d.lookat(eyepos, at, updir)
	local mat2 = math3d.lookto(eyepos, direction, updir)

	print("lookat matrix:", math3d.tostring(mat1), "eyepos:", math3d.tostring(eyepos), "at:", math3d.tostring(at))

	print("lookto matrix:", math3d.tostring(mat2), "eyepos:", math3d.tostring(eyepos), "direction:", math3d.tostring(direction))

	local frustum = {
		l=-1, r=1,
		t=-1, b=1,
		n=0.1, f=100
	}

	local perspective_mat = math3d.projmat(frustum)

	local frustum_ortho = {
		l=-1, r=1,
		t=-1, b=1,
		n=0.1, f=100,
		ortho = true,
	}
	local ortho_mat = math3d.projmat(frustum_ortho)

	print("perspective matrix:", math3d.tostring(perspective_mat))
	print("ortho matrix:", math3d.tostring(ortho_mat))
end

print "===ROTATE VECTOR==="
do
	local v = math3d.vector{1, 2, 1}
	local q = math3d.quaternion {axis=math3d.vector{0, 1, 0}, r=math.pi * 0.5}
	local vv = math3d.transform(q, v, 0)
	print("rotate vector with quaternion", math3d.tostring(v), "=", math3d.tostring(vv))

	local mat = math3d.matrix {s=1, r=q, t=math3d.vector{0, 0, 0, 1}}
	local vv2 = math3d.transform(mat, v, 0)
	print("transform vector with matrix", math3d.tostring(v), "=", math3d.tostring(vv2))

	local p = math3d.vector{1, 2, 1, 1}
	local mat2 = math3d.matrix {s=1, r=q, t=math3d.vector{0, 0, 5, 1}}
	local r_p = math3d.transform(mat2, p, nil)
	print("transform point with matrix", math3d.tostring(p), "=", math3d.tostring(r_p))
end

print "===FORWARD VECTOR==="
do
	local forward = math3d.normalize(math3d.vector {1, 1, 1})
	local right, up = math3d.base_axes(forward)
	print("forward:", math3d.tostring(forward), "right:", math3d.tostring(right), "up:", math3d.tostring(up))
end

require "test.frustum_aabb"
require "test.array"
require "test.matrix"
require "test.adapter"
require "test.slot"

require "test.alive"

ref1 = nil
ref2 = nil
ref3 = nil