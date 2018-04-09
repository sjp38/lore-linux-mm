Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id E36C76B0005
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 11:19:06 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id a125so6252245qkd.4
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 08:19:06 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id c47si630142qtk.457.2018.04.09.08.19.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 08:19:05 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH] Documentation/vm/hmm.txt: typos and syntaxes fixes
Date: Mon,  9 Apr 2018 11:18:59 -0400
Message-Id: <20180409151859.4713-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Randy Dunlap <rdunlap@infradead.org>, Ralph Campbell <rcampbell@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

This fix typos and syntaxes, thanks to Randy Dunlap for pointing them
out (they were all my faults).

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Randy Dunlap <rdunlap@infradead.org>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 Documentation/vm/hmm.txt | 108 +++++++++++++++++++++++------------------------
 1 file changed, 54 insertions(+), 54 deletions(-)

diff --git a/Documentation/vm/hmm.txt b/Documentation/vm/hmm.txt
index e99b97003982..2d1d6f69e91b 100644
--- a/Documentation/vm/hmm.txt
+++ b/Documentation/vm/hmm.txt
@@ -1,22 +1,22 @@
 Heterogeneous Memory Management (HMM)
 
-Provide infrastructure and helpers to integrate non conventional memory (device
-memory like GPU on board memory) into regular kernel code path. Corner stone of
-this being specialize struct page for such memory (see sections 5 to 7 of this
-document).
-
-HMM also provide optional helpers for SVM (Share Virtual Memory) ie allowing a
-device to transparently access program address coherently with the CPU meaning
-that any valid pointer on the CPU is also a valid pointer for the device. This
-is becoming a mandatory to simplify the use of advance heterogeneous computing
-where GPU, DSP, or FPGA are used to perform various computations on behalf of
-a process.
+Provide infrastructure and helpers to integrate non-conventional memory (device
+memory like GPU on board memory) into regular kernel path, with the cornerstone
+of this being specialized struct page for such memory (see sections 5 to 7 of
+this document).
+
+HMM also provides optional helpers for SVM (Share Virtual Memory), i.e.,
+allowing a device to transparently access program address coherently with the
+CPU meaning that any valid pointer on the CPU is also a valid pointer for the
+device. This is becoming mandatory to simplify the use of advanced hetero-
+geneous computing where GPU, DSP, or FPGA are used to perform various
+computations on behalf of a process.
 
 This document is divided as follows: in the first section I expose the problems
 related to using device specific memory allocators. In the second section, I
 expose the hardware limitations that are inherent to many platforms. The third
 section gives an overview of the HMM design. The fourth section explains how
-CPU page-table mirroring works and what is HMM's purpose in this context. The
+CPU page-table mirroring works and the purpose of HMM in this context. The
 fifth section deals with how device memory is represented inside the kernel.
 Finally, the last section presents a new migration helper that allows lever-
 aging the device DMA engine.
@@ -35,7 +35,7 @@ aging the device DMA engine.
 
 1) Problems of using a device specific memory allocator:
 
-Devices with a large amount of on board memory (several giga bytes) like GPUs
+Devices with a large amount of on board memory (several gigabytes) like GPUs
 have historically managed their memory through dedicated driver specific APIs.
 This creates a disconnect between memory allocated and managed by a device
 driver and regular application memory (private anonymous, shared memory, or
@@ -44,29 +44,29 @@ regular file backed memory). From here on I will refer to this aspect as split
 i.e., one in which any application memory region can be used by a device
 transparently.
 
-Split address space because device can only access memory allocated through the
-device specific API. This implies that all memory objects in a program are not
-equal from the device point of view which complicates large programs that rely
-on a wide set of libraries.
+Split address space happens because device can only access memory allocated
+through device specific API. This implies that all memory objects in a program
+are not equal from the device point of view which complicates large programs
+that rely on a wide set of libraries.
 
-Concretly this means that code that wants to leverage devices like GPUs need to
-copy object between genericly allocated memory (malloc, mmap private/share/)
-and memory allocated through the device driver API (this still end up with an
-mmap but of the device file).
+Concretely this means that code that wants to leverage devices like GPUs needs
+to copy object between generically allocated memory (malloc, mmap private, mmap
+share) and memory allocated through the device driver API (this still ends up
+with an mmap but of the device file).
 
-For flat data-sets (array, grid, image, ...) this isn't too hard to achieve but
-complex data-sets (list, tree, ...) are hard to get right. Duplicating a
-complex data-set needs to re-map all the pointer relations between each of its
+For flat data sets (array, grid, image, ...) this isn't too hard to achieve but
+complex data sets (list, tree, ...) are hard to get right. Duplicating a
+complex data set needs to re-map all the pointer relations between each of its
 elements. This is error prone and program gets harder to debug because of the
-duplicate data-set and addresses.
+duplicate data set and addresses.
 
-Split address space also means that libraries can not transparently use data
+Split address space also means that libraries cannot transparently use data
 they are getting from the core program or another library and thus each library
-might have to duplicate its input data-set using the device specific memory
+might have to duplicate its input data set using the device specific memory
 allocator. Large projects suffer from this and waste resources because of the
 various memory copies.
 
-Duplicating each library API to accept as input or output memory allocted by
+Duplicating each library API to accept as input or output memory allocated by
 each device specific allocator is not a viable option. It would lead to a
 combinatorial explosion in the library entry points.
 
@@ -81,16 +81,16 @@ a shared address space for all other patterns.
 
 2) I/O bus, device memory characteristics
 
-I/O buses cripple shared address due to few limitations. Most I/O buses only
-allow basic memory access from device to main memory, even cache coherency is
-often optional. Access to device memory from CPU is even more limited. More
-often than not, it is not cache coherent.
+I/O buses cripple shared address spaces due to a few limitations. Most I/O
+buses only allow basic memory access from device to main memory; even cache
+coherency is often optional. Access to device memory from CPU is even more
+limited. More often than not, it is not cache coherent.
 
 If we only consider the PCIE bus, then a device can access main memory (often
 through an IOMMU) and be cache coherent with the CPUs. However, it only allows
 a limited set of atomic operations from device on main memory. This is worse
-in the other direction, the CPU can only access a limited range of the device
-memory and can not perform atomic operations on it. Thus device memory can not
+in the other direction: the CPU can only access a limited range of the device
+memory and cannot perform atomic operations on it. Thus device memory cannot
 be considered the same as regular memory from the kernel point of view.
 
 Another crippling factor is the limited bandwidth (~32GBytes/s with PCIE 4.0
@@ -99,14 +99,14 @@ The final limitation is latency. Access to main memory from the device has an
 order of magnitude higher latency than when the device accesses its own memory.
 
 Some platforms are developing new I/O buses or additions/modifications to PCIE
-to address some of these limitations (OpenCAPI, CCIX). They mainly allow two
+to address some of these limitations (OpenCAPI, CCIX). They mainly allow two-
 way cache coherency between CPU and device and allow all atomic operations the
-architecture supports. Saddly, not all platforms are following this trend and
+architecture supports. Sadly, not all platforms are following this trend and
 some major architectures are left without hardware solutions to these problems.
 
-So for shared address space to make sense, not only must we allow device to
-access any memory memory but we must also permit any memory to be migrated to
-device memory while device is using it (blocking CPU access while it happens).
+So for shared address space to make sense, not only must we allow devices to
+access any memory but we must also permit any memory to be migrated to device
+memory while device is using it (blocking CPU access while it happens).
 
 
 -------------------------------------------------------------------------------
@@ -123,13 +123,13 @@ while keeping track of CPU page table updates. Device page table updates are
 not as easy as CPU page table updates. To update the device page table, you must
 allocate a buffer (or use a pool of pre-allocated buffers) and write GPU
 specific commands in it to perform the update (unmap, cache invalidations, and
-flush, ...). This can not be done through common code for all devices. Hence
+flush, ...). This cannot be done through common code for all devices. Hence
 why HMM provides helpers to factor out everything that can be while leaving the
 hardware specific details to the device driver.
 
-The second mechanism HMM provides, is a new kind of ZONE_DEVICE memory that
+The second mechanism HMM provides is a new kind of ZONE_DEVICE memory that
 allows allocating a struct page for each page of the device memory. Those pages
-are special because the CPU can not map them. However, they allow migrating
+are special because the CPU cannot map them. However, they allow migrating
 main memory to device memory using existing migration mechanisms and everything
 looks like a page is swapped out to disk from the CPU point of view. Using a
 struct page gives the easiest and cleanest integration with existing mm mech-
@@ -144,7 +144,7 @@ address A triggers a page fault and initiates a migration back to main memory.
 
 With these two features, HMM not only allows a device to mirror process address
 space and keeping both CPU and device page table synchronized, but also lever-
-ages device memory by migrating the part of the data-set that is actively being
+ages device memory by migrating the part of the data set that is actively being
 used by the device.
 
 
@@ -154,7 +154,7 @@ used by the device.
 
 Address space mirroring's main objective is to allow duplication of a range of
 CPU page table into a device page table; HMM helps keep both synchronized. A
-device driver that want to mirror a process address space must start with the
+device driver that wants to mirror a process address space must start with the
 registration of an hmm_mirror struct:
 
  int hmm_mirror_register(struct hmm_mirror *mirror,
@@ -162,7 +162,7 @@ device driver that want to mirror a process address space must start with the
  int hmm_mirror_register_locked(struct hmm_mirror *mirror,
                                 struct mm_struct *mm);
 
-The locked variant is to be use when the driver is already holding the mmap_sem
+The locked variant is to be used when the driver is already holding mmap_sem
 of the mm in write mode. The mirror struct has a set of callbacks that are used
 to propagate CPU page tables:
 
@@ -210,8 +210,8 @@ When the device driver wants to populate a range of virtual addresses, it can
                    bool block);
 
 The first one (hmm_vma_get_pfns()) will only fetch present CPU page table
-entries and will not trigger a page fault on missing or non present entries.
-The second one does trigger a page fault on missing or read only entry if the
+entries and will not trigger a page fault on missing or non-present entries.
+The second one does trigger a page fault on missing or read-only entry if the
 write parameter is true. Page faults use the generic mm page fault code path
 just like a CPU page fault.
 
@@ -251,10 +251,10 @@ HMM implements all this on top of the mmu_notifier API because we wanted a
 simpler API and also to be able to perform optimizations latter on like doing
 concurrent device updates in multi-devices scenario.
 
-HMM also serves as an impedence mismatch between how CPU page table updates
+HMM also serves as an impedance mismatch between how CPU page table updates
 are done (by CPU write to the page table and TLB flushes) and how devices
 update their own page table. Device updates are a multi-step process. First,
-appropriate commands are writen to a buffer, then this buffer is scheduled for
+appropriate commands are written to a buffer, then this buffer is scheduled for
 execution on the device. It is only once the device has executed commands in
 the buffer that the update is done. Creating and scheduling the update command
 buffer can happen concurrently for multiple devices. Waiting for each device to
@@ -302,7 +302,7 @@ HMM provides a set of helpers to register and hotplug device memory as a new
 The first callback (free()) happens when the last reference on a device page is
 dropped. This means the device page is now free and no longer used by anyone.
 The second callback happens whenever the CPU tries to access a device page
-which it can not do. This second callback must trigger a migration back to
+which it cannot do. This second callback must trigger a migration back to
 system memory.
 
 
@@ -310,7 +310,7 @@ system memory.
 
 6) Migration to and from device memory
 
-Because the CPU can not access device memory, migration must use the device DMA
+Because the CPU cannot access device memory, migration must use the device DMA
 engine to perform copy from and to device memory. For this we need a new
 migration helper:
 
@@ -326,7 +326,7 @@ engine to perform copy from and to device memory. For this we need a new
 Unlike other migration functions it works on a range of virtual address, there
 are two reasons for that. First, device DMA copy has a high setup overhead cost
 and thus batching multiple pages is needed as otherwise the migration overhead
-makes the whole exersize pointless. The second reason is because the
+makes the whole exercise pointless. The second reason is because the
 migration might be for a range of addresses the device is actively accessing.
 
 The migrate_vma_ops struct defines two callbacks. First one (alloc_and_copy())
@@ -375,7 +375,7 @@ file backed page or shmem if device page is used for shared memory). This is a
 deliberate choice to keep existing applications, that might start using device
 memory without knowing about it, running unimpacted.
 
-A Drawback is that the OOM killer might kill an application using a lot of
+A drawback is that the OOM killer might kill an application using a lot of
 device memory and not a lot of regular system memory and thus not freeing much
 system memory. We want to gather more real world experience on how applications
 and system react under memory pressure in the presence of device memory before
@@ -385,7 +385,7 @@ deciding to account device memory differently.
 Same decision was made for memory cgroup. Device memory pages are accounted
 against same memory cgroup a regular page would be accounted to. This does
 simplify migration to and from device memory. This also means that migration
-back from device memory to regular memory can not fail because it would
+back from device memory to regular memory cannot fail because it would
 go above memory cgroup limit. We might revisit this choice latter on once we
 get more experience in how device memory is used and its impact on memory
 resource control.
-- 
2.14.3
