Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7DB2D6B039F
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 00:28:21 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id m1so31697034pgd.13
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 21:28:21 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id b88si917834pli.199.2017.03.29.21.28.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 21:28:20 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v7 4/9] mm, THP, swap: Add get_huge_swap_page()
References: <20170328053209.25876-1-ying.huang@intel.com>
	<20170328053209.25876-5-ying.huang@intel.com>
	<20170329170800.GC31821@cmpxchg.org>
Date: Thu, 30 Mar 2017 12:28:17 +0800
In-Reply-To: <20170329170800.GC31821@cmpxchg.org> (Johannes Weiner's message
	of "Wed, 29 Mar 2017 13:08:00 -0400")
Message-ID: <87o9wjs80u.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

Johannes Weiner <hannes@cmpxchg.org> writes:

> On Tue, Mar 28, 2017 at 01:32:04PM +0800, Huang, Ying wrote:
>> @@ -527,6 +527,23 @@ static inline swp_entry_t get_swap_page(void)
>>  
>>  #endif /* CONFIG_SWAP */
>>  
>> +#ifdef CONFIG_THP_SWAP_CLUSTER
>> +static inline swp_entry_t get_huge_swap_page(void)
>> +{
>> +	swp_entry_t entry;
>> +
>> +	if (get_swap_pages(1, &entry, true))
>> +		return entry;
>> +	else
>> +		return (swp_entry_t) {0};
>> +}
>> +#else
>> +static inline swp_entry_t get_huge_swap_page(void)
>> +{
>> +	return (swp_entry_t) {0};
>> +}
>> +#endif
>
> Your introducing a function without a user, making it very hard to
> judge whether the API is well-designed for the callers or not.
>
> I pointed this out as a systemic problem with this patch series in v3,
> along with other stuff, but with the way this series is structured I'm
> having a hard time seeing whether you implemented my other feedback or
> whether your counter arguments to them are justified.
>
> I cannot review and ack these patches this way.

Sorry for inconvenience, I will send a new version to combine the
function definition and usage into one patch at least for you to
review.  But I think we can continue our discussion in the comments your
raised so far firstly, what do you think about that?

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
