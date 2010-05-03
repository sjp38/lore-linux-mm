Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1E94D600794
	for <linux-mm@kvack.org>; Mon,  3 May 2010 11:07:19 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Mon, 03 May 2010 11:07:15 -0400
Message-Id: <20100503150715.15039.42035.sendpatchset@localhost.localdomain>
In-Reply-To: <20100503150455.15039.10178.sendpatchset@localhost.localdomain>
References: <20100503150455.15039.10178.sendpatchset@localhost.localdomain>
Subject: [PATCH 7/7] numa-update-documentation-vm-numa-add-memoryless-node-info-fix1
Sender: owner-linux-mm@kvack.org
To: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Valdis.Kletnieks@vt.edu, Randy Dunlap <randy.dunlap@oracle.com>, Christoph Lameter <cl@linux-foundation.org>, eric.whitney@hp.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Incremental patch to
numa-update-documentation-vm-numa-add-memoryless-node-info.patch
in 28april'10 mmotm.

Address Randy Dunlap's review comments plus a few other fixups.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 Documentation/vm/numa |   58 +++++++++++++++++++++++++-------------------------
 1 file changed, 29 insertions(+), 29 deletions(-)

Index: linux-2.6.34-rc5-mmotm-100428-1653/Documentation/vm/numa
===================================================================
--- linux-2.6.34-rc5-mmotm-100428-1653.orig/Documentation/vm/numa
+++ linux-2.6.34-rc5-mmotm-100428-1653/Documentation/vm/numa
@@ -7,7 +7,7 @@ hardware view and the Linux software vie
 
 From the hardware perspective, a NUMA system is a computer platform that
 comprises multiple components or assemblies each of which may contain 0
-or more cpus, local memory, and/or IO buses.  For brevity and to
+or more CPUs, local memory, and/or IO buses.  For brevity and to
 disambiguate the hardware view of these physical components/assemblies
 from the software abstraction thereof, we'll call the components/assemblies
 'cells' in this document.
@@ -21,13 +21,13 @@ these types of interconnects can be aggr
 cells at multiple distances from other cells.
 
 For Linux, the NUMA platforms of interest are primarily what is known as Cache
-Coherent NUMA or CCNuma systems.   With CCNUMA systems, all memory is visible
-to and accessible from any cpu attached to any cell and cache coherency
+Coherent NUMA or ccNUMA systems.   With ccNUMA systems, all memory is visible
+to and accessible from any CPU attached to any cell and cache coherency
 is handled in hardware by the processor caches and/or the system interconnect.
 
 Memory access time and effective memory bandwidth varies depending on how far
-away the cell containing the cpu or io bus making the memory access is from the
-cell containing the target memory.  For example, access to memory by cpus
+away the cell containing the CPU or IO bus making the memory access is from the
+cell containing the target memory.  For example, access to memory by CPUs
 attached to the same cell will experience faster access times and higher
 bandwidths than accesses to memory on other, remote cells.  NUMA platforms
 can have cells at multiple remote distances from any given cell.
@@ -45,25 +45,25 @@ Linux divides the system's hardware reso
 abstractions called "nodes".  Linux maps the nodes onto the physical cells
 of the hardware platform, abstracting away some of the details for some
 architectures.  As with physical cells, software nodes may contain 0 or more
-cpus, memory and/or IO buses.  And, again, memory access times to memory on
-"closer" nodes [nodes that map to closer cells] will generally experience
+CPUs, memory and/or IO buses.  And, again, memory accesses to memory on
+"closer" nodes--nodes that map to closer cells--will generally experience
 faster access times and higher effective bandwidth than accesses to more
 remote cells.
 
 For some architectures, such as x86, Linux will "hide" any node representing a
-physical cell that has no memory attached, and reassign any cpus attached to
+physical cell that has no memory attached, and reassign any CPUs attached to
 that cell to a node representing a cell that does have memory.  Thus, on
-these architectures, one cannot assume that all cpus that Linux associates with
+these architectures, one cannot assume that all CPUs that Linux associates with
 a given node will see the same local memory access times and bandwidth.
 
 In addition, for some architectures, again x86 is an example, Linux supports
 the emulation of additional nodes.  For NUMA emulation, linux will carve up
 the existing nodes--or the system memory for non-NUMA platforms--into multiple
 nodes.  Each emulated node will manage a fraction of the underlying cells'
-physical memory.  Numa emluation is useful for testing NUMA kernel and
+physical memory.  NUMA emluation is useful for testing NUMA kernel and
 application features on non-NUMA platforms, and as a sort of memory resource
 management mechanism when used together with cpusets.
-[See Documentation/cgroups/cpusets.txt]
+[see Documentation/cgroups/cpusets.txt]
 
 For each node with memory, Linux constructs an independent memory management
 subsystem, complete with its own free page lists, in-use page lists, usage
@@ -71,8 +71,8 @@ statistics and locks to mediate access.
 each memory zone [one or more of DMA, DMA32, NORMAL, HIGH_MEMORY, MOVABLE],
 an ordered "zonelist".  A zonelist specifies the zones/nodes to visit when a
 selected zone/node cannot satisfy the allocation request.  This situation,
-when a zone's has no available memory to satisfy a request, is called
-'overflow" or "fallback".
+when a zone has no available memory to satisfy a request, is called
+"overflow" or "fallback".
 
 Because some nodes contain multiple zones containing different types of
 memory, Linux must decide whether to order the zonelists such that allocations
@@ -82,11 +82,11 @@ such as DMA or DMA32, represent relative
 a default zonelist order based on the sizes of the various zone types relative
 to the total memory of the node and the total memory of the system.  The
 default zonelist order may be overridden using the numa_zonelist_order kernel
-boot parameter or sysctl.  [See Documentation/kernel-parameters.txt and
+boot parameter or sysctl.  [see Documentation/kernel-parameters.txt and
 Documentation/sysctl/vm.txt]
 
 By default, Linux will attempt to satisfy memory allocation requests from the
-node to which the cpu that executes the request is assigned.  Specifically,
+node to which the CPU that executes the request is assigned.  Specifically,
 Linux will attempt to allocate from the first node in the appropriate zonelist
 for the node where the request originates.  This is called "local allocation."
 If the "local" node cannot satisfy the request, the kernel will examine other
@@ -98,26 +98,26 @@ Local allocation will tend to keep subse
 as long as the task on whose behalf the kernel allocated some memory does not
 later migrate away from that memory.  The Linux scheduler is aware of the
 NUMA topology of the platform--embodied in the "scheduling domains" data
-structures [See Documentation/scheduler/sched-domains.txt]--and the scheduler
+structures [see Documentation/scheduler/sched-domains.txt]--and the scheduler
 attempts to minimize task migration to distant scheduling domains.  However,
 the scheduler does not take a task's NUMA footprint into account directly.
 Thus, under sufficient imbalance, tasks can migrate between nodes, remote
 from their initial node and kernel data structures.
 
-System administrators and application designers can restrict a tasks migration
-to improve NUMA locality using various cpu affinity command line interfaces,
+System administrators and application designers can restrict a task's migration
+to improve NUMA locality using various CPU affinity command line interfaces,
 such as taskset(1) and numactl(1), and program interfaces such as
 sched_setaffinity(2).  Further, one can modify the kernel's default local
 allocation behavior using Linux NUMA memory policy.
-[See Documentation/vm/numa_memory_policy.]
+[see Documentation/vm/numa_memory_policy.]
 
-System administrators can restrict the cpus and nodes' memories that a non-
+System administrators can restrict the CPUs and nodes' memories that a non-
 privileged user can specify in the scheduling or NUMA commands and functions
-using control groups and cpusets.  [See Documentation/cgroups/cpusets.txt]
+using control groups and CPUsets.  [see Documentation/cgroups/CPUsets.txt]
 
 On architectures that do not hide memoryless nodes, Linux will include only
 zones [nodes] with memory in the zonelists.  This means that for a memoryless
-node the "local memory node"--the node of the first zone in cpu's node's
+node the "local memory node"--the node of the first zone in CPU's node's
 zonelist--will not be the node itself.  Rather, it will be the node that the
 kernel selected as the nearest node with memory when it built the zonelists.
 So, default, local allocations will succeed with the kernel supplying the
@@ -128,22 +128,22 @@ does contain memory overflows.
 Some kernel allocations do not want or cannot tolerate this allocation fallback
 behavior.  Rather they want to be sure they get memory from the specified node
 or get notified that the node has no free memory.  This is usually the case when
-a subsystem allocates per cpu memory resources, for example.
+a subsystem allocates per CPU memory resources, for example.
 
 A typical model for making such an allocation is to obtain the node id of the
-node to which the "current cpu" is attached using one of the kernel's
-numa_node_id() or cpu_to_node() functions and then request memory from only
+node to which the "current CPU" is attached using one of the kernel's
+numa_node_id() or CPU_to_node() functions and then request memory from only
 the node id returned.  When such an allocation fails, the requesting subsystem
 may revert to its own fallback path.  The slab kernel memory allocator is an
-example of this.  Or, the subsystem may chose to disable or not to enable
+example of this.  Or, the subsystem may choose to disable or not to enable
 itself on allocation failure.  The kernel profiling subsystem is an example of
 this.
 
-If the architecture supports [does not hide] memoryless nodes, then cpus
+If the architecture supports--does not hide--memoryless nodes, then CPUs
 attached to memoryless nodes would always incur the fallback path overhead
 or some subsystems would fail to initialize if they attempted to allocated
-memory exclusively from the a node without memory.  To support such
+memory exclusively from a node without memory.  To support such
 architectures transparently, kernel subsystems can use the numa_mem_id()
 or cpu_to_mem() function to locate the "local memory node" for the calling or
-specified cpu.  Again, this is the same node from which default, local page
+specified CPU.  Again, this is the same node from which default, local page
 allocations will be attempted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
