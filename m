Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 48F7F6B02C4
	for <linux-mm@kvack.org>; Fri,  5 May 2017 18:12:44 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id s58so6900653qtb.1
        for <linux-mm@kvack.org>; Fri, 05 May 2017 15:12:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q46si5908627qtb.158.2017.05.05.15.12.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 May 2017 15:12:43 -0700 (PDT)
Date: Sat, 6 May 2017 01:12:35 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v10 4/6] mm: function to offer a page block on the free
 list
Message-ID: <20170506011012-mutt-send-email-mst@kernel.org>
References: <1493887815-6070-5-git-send-email-wei.w.wang@intel.com>
 <201705050851.KJdDIPUA%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201705050851.KJdDIPUA%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: Wei Wang <wei.w.wang@intel.com>, kbuild-all@01.org, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com

On Fri, May 05, 2017 at 08:21:34AM +0800, kbuild test robot wrote:
> Hi Wei,
> 
> [auto build test WARNING on linus/master]
> [also build test WARNING on v4.11 next-20170504]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Wei-Wang/Extend-virtio-balloon-for-fast-de-inflating-fast-live-migration/20170505-052958
> reproduce: make htmldocs
> 
> All warnings (new ones prefixed by >>):
> 
>    WARNING: convert(1) not found, for SVG to PDF conversion install ImageMagick (https://www.imagemagick.org)
>    arch/x86/include/asm/uaccess_32.h:1: warning: no structured comments found
> >> mm/page_alloc.c:4663: warning: No description found for parameter 'zone'
> >> mm/page_alloc.c:4663: warning: No description found for parameter 'order'
> >> mm/page_alloc.c:4663: warning: No description found for parameter 'migratetype'
> >> mm/page_alloc.c:4663: warning: No description found for parameter 'page'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
>    include/net/cfg80211.h:1738: warning: No description found for parameter 'report_results'
>    include/net/cfg80211.h:1738: warning: Excess struct/union/enum/typedef member 'results_wk' description in 'cfg80211_sched_scan_request'
> 
> vim +/zone +4663 mm/page_alloc.c

the issue is actually aboe this line: it is:

/**

which is reserved for kernel-doc.

Either format properly for kernel-doc, or use simple /*
to start comments.


>   4647	 * Heuristically get a page block in the system that is unused.
>   4648	 * It is possible that pages from the page block are used immediately after
>   4649	 * report_unused_page_block() returns. It is the caller's responsibility
>   4650	 * to either detect or prevent the use of such pages.
>   4651	 *
>   4652	 * The free list to check: zone->free_area[order].free_list[migratetype].
>   4653	 *
>   4654	 * If the caller supplied page block (i.e. **page) is on the free list, offer
>   4655	 * the next page block on the list to the caller. Otherwise, offer the first
>   4656	 * page block on the list.
>   4657	 *
>   4658	 * Return 0 when a page block is found on the caller specified free list.
>   4659	 */
>   4660	int report_unused_page_block(struct zone *zone, unsigned int order,
>   4661				     unsigned int migratetype, struct page **page)
>   4662	{
> > 4663		struct zone *this_zone;
>   4664		struct list_head *this_list;
>   4665		int ret = 0;
>   4666		unsigned long flags;
>   4667	
>   4668		/* Sanity check */
>   4669		if (zone == NULL || page == NULL || order >= MAX_ORDER ||
>   4670		    migratetype >= MIGRATE_TYPES)
>   4671			return -EINVAL;
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
