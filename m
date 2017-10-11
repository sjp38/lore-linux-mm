Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9BDDC6B0253
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 21:11:21 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z80so1080048pff.1
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 18:11:21 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id a5si9513880plp.763.2017.10.10.18.11.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 18:11:20 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm] mm, swap: Use page-cluster as max window of VMA based swap readahead
References: <20171010060855.17798-1-ying.huang@intel.com>
	<20171010082040.GA16508@bbox> <87r2ubo08t.fsf@yhuang-dev.intel.com>
	<20171010085524.GA16752@bbox>
Date: Wed, 11 Oct 2017 09:11:17 +0800
In-Reply-To: <20171010085524.GA16752@bbox> (Minchan Kim's message of "Tue, 10
	Oct 2017 17:55:24 +0900")
Message-ID: <871smao5e2.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

Minchan Kim <minchan@kernel.org> writes:

> On Tue, Oct 10, 2017 at 04:50:10PM +0800, Huang, Ying wrote:
>> Minchan Kim <minchan@kernel.org> writes:
>> 
>> > On Tue, Oct 10, 2017 at 02:08:55PM +0800, Huang, Ying wrote:
>> >> From: Huang Ying <ying.huang@intel.com>
>> >> 
>> >> When the VMA based swap readahead was introduced, a new knob
>> >> 
>> >>   /sys/kernel/mm/swap/vma_ra_max_order
>> >> 
>> >> was added as the max window of VMA swap readahead.  This is to make it
>> >> possible to use different max window for VMA based readahead and
>> >> original physical readahead.  But Minchan Kim pointed out that this
>> >> will cause a regression because setting page-cluster sysctl to zero
>> >> cannot disable swap readahead with the change.
>> >> 
>> >> To fix the regression, the page-cluster sysctl is used as the max
>> >> window of both the VMA based swap readahead and original physical swap
>> >> readahead.  If more fine grained control is needed in the future, more
>> >> knobs can be added as the subordinate knobs of the page-cluster
>> >> sysctl.
>> >> 
>> >> The vma_ra_max_order knob is deleted.  Because the knob was
>> >> introduced in v4.14-rc1, and this patch is targeting being merged
>> >> before v4.14 releasing, there should be no existing users of this
>> >> newly added ABI.
>> >> 
>> >> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> >> Cc: Rik van Riel <riel@redhat.com>
>> >> Cc: Shaohua Li <shli@kernel.org>
>> >> Cc: Hugh Dickins <hughd@google.com>
>> >> Cc: Fengguang Wu <fengguang.wu@intel.com>
>> >> Cc: Tim Chen <tim.c.chen@intel.com>
>> >> Cc: Dave Hansen <dave.hansen@intel.com>
>> >> Reported-by: Minchan Kim <minchan@kernel.org>
>> >
>> > It seems your script is Ccing only with Cc: tag, not other tags.
>> > Fix it so any participant of topic can get the mail.
>> 
>> I just used `git send-email`, no other scripts.  We need to fix `git send-email`?
>
> You can do it via cccmd.
>
> Just a reference:
>
> ~/bin/kcccmd
> sed -nre 's/^(Acked|Reviewed|Reported|Tested|Suggested)-by: //p' "$1"

Thanks, will use this script in the future.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
