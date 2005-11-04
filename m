Date: Thu, 03 Nov 2005 17:16:55 -0800
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-ID: <58210000.1131067015@flay>
In-Reply-To: <20051104010021.4180A184531@thermo.lanl.gov>
References: <20051104010021.4180A184531@thermo.lanl.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Nelson <andy@thermo.lanl.gov>, torvalds@osdl.org
Cc: akpm@osdl.org, arjan@infradead.org, arjanv@infradead.org, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mel@csn.ul.ie, mingo@elte.hu, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

> Linus writes:
> 
>> Just face it - people who want memory hotplug had better know that 
>> beforehand (and let's be honest - in practice it's only going to work in 
>> virtualized environments or in environments where you can insert the new 
>> bank of memory and copy it over and remove the old one with hw support).
>> 
>> Same as hugetlb.
>> 
>> Nobody sane _cares_. Nobody sane is asking for these things. Only people 
>> with special needs are asking for it, and they know their needs.
> 
> 
> Hello, my name is Andy. I am insane. I am one of the CRAZY PEOPLE you wrote
> about.

To provide a slightly shorter version ... we had one customer running
similarly large number crunching things in Fortran. Their app ran 25%
faster with large pages (not a typo). Because they ran a variety of
jobs in batch mode, they need large pages sometimes, and small pages
at others - hence they need to dynamically resize the pool. 

That's the sort of thing we were trying to fix with dynamically sized
hugepage pools. It does make a huge difference to real-world customers.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
