Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 60D466B004D
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 04:35:51 -0500 (EST)
Date: Wed, 21 Dec 2011 10:35:47 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: + memcg-clear-pc-mem_cgorup-if-necessary-fix-2-fix.patch added
 to -mm tree
Message-ID: <20111221093547.GC27137@tiehlicka.suse.cz>
References: <20111220233037.47879100052@wpzn3.hot.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111220233037.47879100052@wpzn3.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, hannes@cmpxchg.org, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, mszeredi@suse.cz, yinghan@google.com, linux-mm@kvack.org

On Tue 20-12-11 15:30:36, Andrew Morton wrote:
> 
> The patch titled
>      Subject: memcg-clear-pc-mem_cgorup-if-necessary-fix-2-fix
> has been added to the -mm tree.  Its filename is
>      memcg-clear-pc-mem_cgorup-if-necessary-fix-2-fix.patch
> 
> Before you just go and hit "reply", please:
>    a) Consider who else should be cc'ed
>    b) Prefer to cc a suitable mailing list as well
>    c) Ideally: find the original patch on the mailing list and do a
>       reply-to-all to that, adding suitable additional cc's
> 
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> 
> See http://userweb.kernel.org/~akpm/stuff/added-to-mm.txt to find
> out what to do about this
> 
> The current -mm tree may be found at http://userweb.kernel.org/~akpm/mmotm/
> 
> ------------------------------------------------------
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: memcg-clear-pc-mem_cgorup-if-necessary-fix-2-fix
> 
> ksm.c needs memcontrol.h, per Michal

Just for record. It really doesn't need it at the moment because it gets
memcontrol.h via rmap.h resp. swap.h but I plan to remove memcontrol
include from those two.
I can do that in a separate patch if you prefer?

> 
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Miklos Szeredi <mszeredi@suse.cz>
> Cc: Ying Han <yinghan@google.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/ksm.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff -puN mm/ksm.c~memcg-clear-pc-mem_cgorup-if-necessary-fix-2-fix mm/ksm.c
> --- a/mm/ksm.c~memcg-clear-pc-mem_cgorup-if-necessary-fix-2-fix
> +++ a/mm/ksm.c
> @@ -28,6 +28,7 @@
>  #include <linux/kthread.h>
>  #include <linux/wait.h>
>  #include <linux/slab.h>
> +#include <linux/memcontrol.h>
>  #include <linux/rbtree.h>
>  #include <linux/memory.h>
>  #include <linux/mmu_notifier.h>
> _
> Subject: Subject: memcg-clear-pc-mem_cgorup-if-necessary-fix-2-fix
> 
> Patches currently in -mm which might be from akpm@linux-foundation.org are
> 
> origin.patch
> linux-next.patch
> linux-next-git-rejects.patch
> i-need-old-gcc.patch
> arch-alpha-kernel-systblss-remove-debug-check.patch
> arch-x86-platform-iris-irisc-register-a-platform-device-and-a-platform-driver.patch
> x86-olpc-xo15-sci-enable-lid-close-wakeup-control-through-sysfs-fix.patch
> mm-vmallocc-eliminate-extra-loop-in-pcpu_get_vm_areas-error-path-fix.patch
> drivers-platform-x86-sony-laptopc-fix-scancodes-checkpatch-fixes.patch
> drivers-platform-x86-sony-laptopc-fix-scancodes-v2-checkpatch-fixes.patch
> slub-document-setting-min-order-with-debug_guardpage_minorder-0-checkpatch-fixes.patch
> mm.patch
> mm-add-extra-free-kbytes-tunable-update-checkpatch-fixes.patch
> mm-reduce-the-amount-of-work-done-when-updating-min_free_kbytes-checkpatch-fixes.patch
> mm-hugetlbc-fix-virtual-address-handling-in-hugetlb-fault-fix.patch
> mm-more-intensive-memory-corruption-debug-fix.patch
> mm-exclude-reserved-pages-from-dirtyable-memory-fix.patch
> mm-simplify-find_vma_prev-fix.patch
> mm-hugetlb-fix-pgoff-computation-when-unmapping-page-from-vma-fix.patch
> frv-duplicate-output_buffer-of-e03-checkpatch-fixes.patch
> hpet-factor-timer-allocate-from-open.patch
> treewide-convert-uses-of-attrib_noreturn-to-__noreturn-checkpatch-fixes.patch
> leds-add-driver-for-tca6507-led-controller.patch
> checkpatch-improve-memset-and-min-max-with-cast-checking-fix.patch
> checkpatch-catch-all-occurances-of-type-and-cast-spacing-errors-per-line-checkpatch-fixes.patch
> drivers-rtc-rtc-mxcc-fix-setting-time-for-mx1-soc-fix.patch
> drivers-rtc-rtc-mxcc-make-alarm-work-fix.patch
> rtc-ab8500-add-calibration-attribute-to-ab8500-rtc-checkpatch-fixes.patch
> rtc-ab8500-add-calibration-attribute-to-ab8500-rtc-v3-checkpatch-fixes.patch
> mm-vmscan-distinguish-between-memcg-triggering-reclaim-and-memcg-being-scanned-checkpatch-fixes.patch
> memcg-make-mem_cgroup_split_huge_fixup-more-efficient-fix.patch
> memcg-clear-pc-mem_cgorup-if-necessary-fix.patch
> memcg-clear-pc-mem_cgorup-if-necessary-fix-2-fix.patch
> memcg-simplify-lru-handling-by-new-rule-fix.patch
> procfs-introduce-the-proc-pid-map_files-directory-checkpatch-fixes.patch
> workqueue-make-alloc_workqueue-take-printf-fmt-and-args-for-name-fix.patch
> kexec-remove-kmsg_dump_kexec.patch
> panic-dont-print-redundant-backtraces-on-oops-fix.patch
> scatterlist-new-helper-functions.patch
> scatterlist-new-helper-functions-update-fix.patch
> memstick-add-support-for-legacy-memorysticks-fix.patch
> dio-optimize-cache-misses-in-the-submission-path-v2-checkpatch-fixes.patch
> selftests-new-very-basic-kernel-selftests-directory.patch
> c-r-procfs-add-start_data-end_data-start_brk-members-to-proc-pid-stat-v4-fix.patch
> c-r-prctl-add-pr_set_mm-codes-to-set-up-mm_struct-entries-fix.patch
> fixed-use-of-rounddown_pow_of_two-in-ramoops.patch
> notify_change-check-that-i_mutex-is-held.patch
> journal_add_journal_head-debug.patch
> mutex-subsystem-synchro-test-module-fix.patch
> slab-leaks3-default-y.patch
> put_bh-debug.patch
> 

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
