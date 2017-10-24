Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 94F346B028B
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 11:34:16 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p87so18729400pfj.21
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 08:34:16 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id t1si326130pgc.703.2017.10.24.08.34.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Oct 2017 08:34:15 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm] mm, swap: Fix false error message in __swp_swapcount()
References: <20171024024700.23679-1-ying.huang@intel.com>
	<20171024083809.lrw23yumkassclgm@dhcp22.suse.cz>
	<87vaj4poff.fsf@yhuang-dev.intel.com>
	<20171024153037.gjemriarubzoqai5@dhcp22.suse.cz>
Date: Tue, 24 Oct 2017 23:34:11 +0800
In-Reply-To: <20171024153037.gjemriarubzoqai5@dhcp22.suse.cz> (Michal Hocko's
	message of "Tue, 24 Oct 2017 17:30:37 +0200")
Message-ID: <87mv4gpnkc.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Chen <tim.c.chen@linux.intel.com>, Minchan Kim <minchan@kernel.org>, stable@vger.kernel.org, Christian Kujau <lists@nerdbynature.de>

Michal Hocko <mhocko@kernel.org> writes:

> On Tue 24-10-17 23:15:32, Huang, Ying wrote:
>> Hi, Michal,
>> 
>> Michal Hocko <mhocko@kernel.org> writes:
>> 
>> > On Tue 24-10-17 10:47:00, Huang, Ying wrote:
>> >> From: Ying Huang <ying.huang@intel.com>
>> >> 
>> >> __swp_swapcount() is used in __read_swap_cache_async().  Where the
>> >> invalid swap entry (offset > max) may be supplied during swap
>> >> readahead.  But __swp_swapcount() will print error message for these
>> >> expected invalid swap entry as below, which will make the users
>> >> confusing.
>> >   ^^
>> > confused... And I have to admit this changelog has left me confused as
>> > well. What is an invalid swap entry in the readahead? Ohh, let me
>> > re-real Fixes: commit. It didn't really help "We can avoid needlessly
>> > allocating page for swap slots that are not used by anyone.  No pages
>> > have to be read in for these slots."
>> >
>> > Could you be more specific about when and how this happens please?
>> 
>> Sorry for confusing.
>> 
>> When page fault occurs for a swap entry, the original swap readahead
>> (not new VMA base swap readahead) may readahead several swap entries
>> after the fault swap entry.  The readahead algorithm calculates some of
>> the swap entries to readahead via increasing the offset of the fault
>> swap entry without checking whether they are beyond the end of the swap
>> device and it rely on the __swp_swapcount() and swapcache_prepare() to
>> check it.  Although __swp_swapcount() checks for the swap entry passed
>> in, it will complain with error message for the expected invalid swap
>> entry.  This makes the end user confusing.
>> 
>> Is this a little clearer.
>
> yes, this makes more sense (modulo the same typo ;)). Can you make this
> information into the changelog please? Thanks.

Oh, Yes!  I should fix it.  Sure, I will add this into the changelog.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
