Message-ID: <4672A4C1.1070909@shadowen.org>
Date: Fri, 15 Jun 2007 15:40:01 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [RFC] memory unplug v5 [5/6] page unplug
References: <20070614155630.04f8170c.kamezawa.hiroyu@jp.fujitsu.com> <20070614160458.62e20cbd.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.0.99.0706142303460.1729@chino.kir.corp.google.com> <Pine.LNX.4.64.0706150732510.7400@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0706150732510.7400@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Thu, 14 Jun 2007, David Rientjes wrote:
> 
>>> +	struct zone *zone = NULL;
>>> +	struct page *page;
>>> +	for (pfn = start_pfn;
>>> +             pfn < end_pfn;
>>> +	     pfn += MAX_ORDER_NR_PAGES) {
>>> +#ifdef CONFIG_HOLES_IN_ZONE
>>> +		int i;
>>> +		for (i = 0; i < MAX_ORDER_NR_PAGES; i++) {
>>> +			if (pfn_valid_within(pfn + i))
>>> +				break;
>>> +		}
>>> +		if (i == MAX_ORDER_NR_PAGES)
>>> +			continue;
>>> +		page = pfn_to_page(pfn + i);
>>> +#else
>>> +		page = pfn_to_page(pfn);
>>> +#endif
>> Please extract this out to inlined functions that are conditional are 
>> CONFIG_HOLES_IN_ZONE.
> 
> And we need to deal with HOLES_IN_ZONE because the sparsemem virtual 
> memmap patchset was not merged and therefore we cannot get rid of 
> VIRTUAL_MEM_MAP.
> 
> Andy, any progress? Do you want me to do another patchset?

I believe I've got the latest.  I'll sort out the feedback over the
weekend and get a new patchset out, to Andrew.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
