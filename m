Date: Tue, 19 Sep 2006 14:53:40 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Message-Id: <20060919145340.c2b13cbb.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609191426560.7480@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
	<20060914220011.2be9100a.akpm@osdl.org>
	<20060914234926.9b58fd77.pj@sgi.com>
	<20060915002325.bffe27d1.akpm@osdl.org>
	<20060916044847.99802d21.pj@sgi.com>
	<20060916083825.ba88eee8.akpm@osdl.org>
	<20060916145117.9b44786d.pj@sgi.com>
	<20060916161031.4b7c2470.akpm@osdl.org>
	<Pine.LNX.4.64.0609162134540.13809@schroedinger.engr.sgi.com>
	<Pine.LNX.4.63.0609191212390.7746@chino.corp.google.com>
	<Pine.LNX.4.64.0609191224560.6976@schroedinger.engr.sgi.com>
	<Pine.LNX.4.63.0609191401360.8253@chino.corp.google.com>
	<Pine.LNX.4.64.0609191426560.7480@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: rientjes@google.com, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph wrote:
> Paul has already cpuset code in mm that supports exactly this situation.

See my *-mm patches:
  cpuset-top_cpuset-tracks-hotplug-changes-to-node_online_map.patch
  cpuset-hotunplug-cpus-and-mems-in-all-cpusets.patch

and patient Andrews fixes thereto.

In particular, anytime you add or remove nodes (whether
fake or real) be sure to update node_online_map, and then
call cpuset_track_online_nodes(), so that the cpuset code
can resync with node_online_map.  You must make this call
in a context where it is ok for the called code to sleep
on various cpuset mutex's.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
