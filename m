Message-ID: <481227FF.5000802@firstfloor.org>
Date: Fri, 25 Apr 2008 20:50:39 +0200
From: Andi Kleen <andi@firstfloor.org>
MIME-Version: 1.0
Subject: Re: [patch 13/18] hugetlb: support boot allocate different sizes
References: <20080423015302.745723000@nick.local0.net> <20080423015431.027712000@nick.local0.net> <20080425184041.GH9680@us.ibm.com>
In-Reply-To: <20080425184041.GH9680@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

Nishanth Aravamudan wrote:

> When would this be the case (the list is already init'd)?

It can happen inside the series before all the final checks are in
with multiple arguments. In theory it could be removed at the end,
but then it doesn't hurt.

> 
>>  	for (i = 0; i < h->max_huge_pages; ++i) {
>>  		if (h->order >= MAX_ORDER) {
>> @@ -594,7 +597,7 @@ static void __init hugetlb_init_hstate(s
>>  		} else if (!alloc_fresh_huge_page(h))
>>  			break;
>>  	}
>> -	h->max_huge_pages = h->free_huge_pages = h->nr_huge_pages = i;
>> +	h->max_huge_pages = i;
> 
> Why don't we need to set these other values anymore?

Because the low level functions handle them already (as a simple grep
would have told you)

> I think it's use should be restricted to the sysctl as much as possible
> (and the sysctl's should be updated to only do work if write is set).
> Does that seem sane to you?

Fundamental rule of programming: Information should be only kept at a
single place if possible.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
