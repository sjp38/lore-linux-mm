Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1FEB06B0390
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 23:32:42 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j4so12335549pfc.8
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 20:32:42 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id v1si350927pfj.283.2017.03.31.20.32.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Mar 2017 20:32:41 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v7 4/9] mm, THP, swap: Add get_huge_swap_page()
References: <20170328053209.25876-1-ying.huang@intel.com>
	<20170328053209.25876-5-ying.huang@intel.com>
	<20170329170800.GC31821@cmpxchg.org>
	<87o9wjs80u.fsf@yhuang-dev.intel.com>
	<20170331152418.GA9410@cmpxchg.org>
Date: Sat, 01 Apr 2017 11:32:38 +0800
In-Reply-To: <20170331152418.GA9410@cmpxchg.org> (Johannes Weiner's message of
	"Fri, 31 Mar 2017 11:24:18 -0400")
Message-ID: <87lgrkreeh.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

Johannes Weiner <hannes@cmpxchg.org> writes:

> On Thu, Mar 30, 2017 at 12:28:17PM +0800, Huang, Ying wrote:
>> Johannes Weiner <hannes@cmpxchg.org> writes:
>> > On Tue, Mar 28, 2017 at 01:32:04PM +0800, Huang, Ying wrote:
>> >> @@ -527,6 +527,23 @@ static inline swp_entry_t get_swap_page(void)
>> >>  
>> >>  #endif /* CONFIG_SWAP */
>> >>  
>> >> +#ifdef CONFIG_THP_SWAP_CLUSTER
>> >> +static inline swp_entry_t get_huge_swap_page(void)
>> >> +{
>> >> +	swp_entry_t entry;
>> >> +
>> >> +	if (get_swap_pages(1, &entry, true))
>> >> +		return entry;
>> >> +	else
>> >> +		return (swp_entry_t) {0};
>> >> +}
>> >> +#else
>> >> +static inline swp_entry_t get_huge_swap_page(void)
>> >> +{
>> >> +	return (swp_entry_t) {0};
>> >> +}
>> >> +#endif
>> >
>> > Your introducing a function without a user, making it very hard to
>> > judge whether the API is well-designed for the callers or not.
>> >
>> > I pointed this out as a systemic problem with this patch series in v3,
>> > along with other stuff, but with the way this series is structured I'm
>> > having a hard time seeing whether you implemented my other feedback or
>> > whether your counter arguments to them are justified.
>> >
>> > I cannot review and ack these patches this way.
>> 
>> Sorry for inconvenience, I will send a new version to combine the
>> function definition and usage into one patch at least for you to
>> review.
>
> We tried this before. I reviewed the self-contained patch and you
> incorporated the feedback into the split-out structure that made it
> impossible for me to verify the updates.
>
> I'm not sure why you insist on preserving this series format. It's not
> good for review, and it's not good for merging and git history.

I had thought some reviewers would prefer the original series format.
But I will use your suggested format in the future, unless more
reviewers prefer the original format.

Best Regards,
Huang, Ying

>> But I think we can continue our discussion in the comments your
>> raised so far firstly, what do you think about that?
>
> Yeah, let's finish the discussions before -v8.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
