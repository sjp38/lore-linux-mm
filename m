Message-ID: <46EECAA0.9080300@kolumbus.fi>
Date: Mon, 17 Sep 2007 21:42:40 +0300
From: =?ISO-8859-15?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] hugetlb: Try to grow hugetlb pool for MAP_SHARED
 mappings
References: <20070917163935.32557.50840.stgit@kernel>	 <20070917164009.32557.4348.stgit@kernel>  <46EEB7C1.70806@kolumbus.fi> <1190050936.15024.89.camel@localhost.localdomain>
In-Reply-To: <1190050936.15024.89.camel@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, libhugetlbfs-devel@lists.sourceforge.net, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@skynet.ie>, Bill Irwin <bill.irwin@oracle.com>, Ken Chen <kenchen@google.com>, Dave McCracken <dave.mccracken@oracle.com>
List-ID: <linux-mm.kvack.org>

Adam Litke wrote:
> On Mon, 2007-09-17 at 20:22 +0300, Mika Penttila wrote:
>   
>>> +void return_unused_surplus_pages(void)
>>> +{
>>> +	static int nid = -1;
>>> +	int delta;
>>> +	struct page *page;
>>> +
>>> +	delta = unused_surplus_pages - resv_huge_pages;
>>> +
>>> +	while (delta) {
>>>   
>>>       
>> Shouldn't this be while (delta >= 0) ?
>>     
>
> unused_surplus_pages is always >= resv_huge_pages so delta cannot go
> negative.  But for clarity it makes sense to apply the change you
> suggest.  Thanks for responding.
>
>   
I think unused_surplus_pages accounting isn't quite right. It gets 
always decremented in dequeue_huge_page() but incremented only if we 
haven't enough free pages at reserve time.

--Mika

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
