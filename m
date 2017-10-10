Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 381096B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 04:55:28 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p2so31393237pfk.0
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 01:55:28 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id f3si8648619plf.562.2017.10.10.01.55.26
        for <linux-mm@kvack.org>;
        Tue, 10 Oct 2017 01:55:27 -0700 (PDT)
Date: Tue, 10 Oct 2017 17:55:24 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -mm] mm, swap: Use page-cluster as max window of VMA
 based swap readahead
Message-ID: <20171010085524.GA16752@bbox>
References: <20171010060855.17798-1-ying.huang@intel.com>
 <20171010082040.GA16508@bbox>
 <87r2ubo08t.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87r2ubo08t.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

On Tue, Oct 10, 2017 at 04:50:10PM +0800, Huang, Ying wrote:
> Minchan Kim <minchan@kernel.org> writes:
> 
> > On Tue, Oct 10, 2017 at 02:08:55PM +0800, Huang, Ying wrote:
> >> From: Huang Ying <ying.huang@intel.com>
> >> 
> >> When the VMA based swap readahead was introduced, a new knob
> >> 
> >>   /sys/kernel/mm/swap/vma_ra_max_order
> >> 
> >> was added as the max window of VMA swap readahead.  This is to make it
> >> possible to use different max window for VMA based readahead and
> >> original physical readahead.  But Minchan Kim pointed out that this
> >> will cause a regression because setting page-cluster sysctl to zero
> >> cannot disable swap readahead with the change.
> >> 
> >> To fix the regression, the page-cluster sysctl is used as the max
> >> window of both the VMA based swap readahead and original physical swap
> >> readahead.  If more fine grained control is needed in the future, more
> >> knobs can be added as the subordinate knobs of the page-cluster
> >> sysctl.
> >> 
> >> The vma_ra_max_order knob is deleted.  Because the knob was
> >> introduced in v4.14-rc1, and this patch is targeting being merged
> >> before v4.14 releasing, there should be no existing users of this
> >> newly added ABI.
> >> 
> >> Cc: Johannes Weiner <hannes@cmpxchg.org>
> >> Cc: Rik van Riel <riel@redhat.com>
> >> Cc: Shaohua Li <shli@kernel.org>
> >> Cc: Hugh Dickins <hughd@google.com>
> >> Cc: Fengguang Wu <fengguang.wu@intel.com>
> >> Cc: Tim Chen <tim.c.chen@intel.com>
> >> Cc: Dave Hansen <dave.hansen@intel.com>
> >> Reported-by: Minchan Kim <minchan@kernel.org>
> >
> > It seems your script is Ccing only with Cc: tag, not other tags.
> > Fix it so any participant of topic can get the mail.
> 
> I just used `git send-email`, no other scripts.  We need to fix `git send-email`?

You can do it via cccmd.

Just a reference:

~/bin/kcccmd
sed -nre 's/^(Acked|Reviewed|Reported|Tested|Suggested)-by: //p' "$1"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
