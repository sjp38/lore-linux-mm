Message-ID: <44611DC9.4090501@cyberone.com.au>
Date: Wed, 10 May 2006 08:55:05 +1000
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/3] throttle writers of shared mappings
References: <1146861313.3561.13.camel@lappy>	 <445CA22B.8030807@cyberone.com.au> <1146922446.3561.20.camel@lappy>	 <445CA907.9060002@cyberone.com.au> <1146929357.3561.28.camel@lappy>	 <Pine.LNX.4.64.0605072338010.18611@schroedinger.engr.sgi.com>	 <1147116034.16600.2.camel@lappy>	 <Pine.LNX.4.64.0605082234180.23795@schroedinger.engr.sgi.com> <1147207460.27680.20.camel@lappy> <44611DAD.8020801@cyberone.com.au>
In-Reply-To: <44611DAD.8020801@cyberone.com.au>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <clameter@sgi.com>, Linus Torvalds <torvalds@osdl.org>, Andi Kleen <ak@suse.de>, Rohit Seth <rohitseth@google.com>, Andrew Morton <akpm@osdl.org>, mbligh@google.com, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


Nick Piggin wrote:

> Peter Zijlstra wrote:
>
>> @@ -2304,8 +2308,11 @@ static inline int handle_pte_fault(struc
>> unlock:
>>     pte_unmap_unlock(pte, ptl);
>>     if (dirty_page) {
>> +        struct address_space *mapping = page_mapping(dirty_page);
>>         set_page_dirty(dirty_page);
>>         put_page(dirty_page);
>> +        if (mapping)
>> +            balance_dirty_pages_ratelimited_nr(mapping, 1);
>>  
>>
>
> Just use balance_dirty_pages()


Err.. balance_dirty_pages_ratelimited();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
