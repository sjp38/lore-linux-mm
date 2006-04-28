Date: Fri, 28 Apr 2006 16:18:30 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 1/7] page migration: Reorder functions in migrate.c
Message-Id: <20060428161830.7af8c3f0.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0604281556220.3412@schroedinger.engr.sgi.com>
References: <20060428060302.30257.76871.sendpatchset@schroedinger.engr.sgi.com>
	<20060428150806.057b0bac.akpm@osdl.org>
	<Pine.LNX.4.64.0604281556220.3412@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, lee.schermerhorn@hp.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> wrote:
>
> > How hurtful would that be?
> 
> Not too difficult if I have a tree to patch against.

OK, thanks.

Patches against mainline would probably suit - I don't think there's much
overlapping stuff going on, if any.

http://www.zip.com.au/~akpm/linux/patches/stuff/x.bz2 is my current rollup
(against -rc3) up to the end of the memory management stuff (ie: where I'll
insert the new migration patches).  So perhaps you could verify that the
reworked patches apply against that patch, at least.

It includes:

mm-vm_bug_on.patch
mm-thrash-detect-process-thrashing-against-itself.patch
#mm-posix-memory-lock.patch
page-migration-make-do_swap_page-redo-the-fault.patch
slab-extract-cache_free_alien-from-__cache_free.patch
pg_uncached-is-ia64-only.patch
slab-page-mapping-cleanup.patch
migration-remove-unnecessary-pageswapcache-checks.patch
wait_table-and-zonelist-initializing-for-memory-hotadd-change-name-of-wait_table_size.patch
wait_table-and-zonelist-initializing-for-memory-hotadd-change-to-meminit-for-build_zonelist.patch
wait_table-and-zonelist-initializing-for-memory-hotaddadd-return-code-for-init_current_empty_zone.patch
wait_table-and-zonelist-initializing-for-memory-hotadd-wait_table-initialization.patch
wait_table-and-zonelist-initializing-for-memory-hotadd-update-zonelists.patch
squash-duplicate-page_to_pfn-and-pfn_to_page.patch
sparsemem-interaction-with-memory-add-bug-fixes.patch
support-for-panic-at-oom.patch
mm-fix-typos-in-comments-in-mm-oom_killc.patch
reserve-space-for-swap-label.patch
tightening-hugetlb-strict-accounting.patch
slab-cleanup-kmem_getpages.patch
slab-stop-using-list_for_each.patch
swsusp-rework-memory-shrinker-rev-2.patch
swsusp-rework-memory-shrinker-rev-2-fix.patch
#
pgdat-allocation-for-new-node-add-specify-node-id.patch
pgdat-allocation-for-new-node-add-specify-node-id-powerpc-fix.patch
pgdat-allocation-for-new-node-add-specify-node-id-tidy.patch
pgdat-allocation-for-new-node-add-specify-node-id-fix-3.patch
pgdat-allocation-for-new-node-add-get-node-id-by-acpi.patch
pgdat-allocation-for-new-node-add-get-node-id-by-acpi-tidy.patch
pgdat-allocation-for-new-node-add-generic-alloc-node_data.patch
pgdat-allocation-for-new-node-add-generic-alloc-node_data-tidy.patch
pgdat-allocation-for-new-node-add-refresh-node_data.patch
pgdat-allocation-for-new-node-add-refresh-node_data-fix.patch
pgdat-allocation-for-new-node-add-export-kswapd-start-func.patch
pgdat-allocation-for-new-node-add-export-kswapd-start-func-tidy.patch
pgdat-allocation-for-new-node-add-call-pgdat-allocation.patch
register-hot-added-memory-to-iomem-resource.patch
#
mm-introduce-remap_vmalloc_range.patch
mm-introduce-remap_vmalloc_range-tidy.patch
mm-introduce-remap_vmalloc_range-fix.patch
#
change-gen_pool-allocator-to-not-touch-managed-memory.patch
change-gen_pool-allocator-to-not-touch-managed-memory-update.patch
change-gen_pool-allocator-to-not-touch-managed-memory-update-2.patch
radix-tree-direct-data.patch
radix-tree-small.patch
likely-cleanup-remove-unlikely-in-sys_mprotect.patch
slab-redzone-double-free-detection.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
