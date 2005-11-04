Message-ID: <436AB902.3000309@yahoo.com.au>
Date: Fri, 04 Nov 2005 12:27:30 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
References: <20051104010021.4180A184531@thermo.lanl.gov> <58210000.1131067015@flay>
In-Reply-To: <58210000.1131067015@flay>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Andy Nelson <andy@thermo.lanl.gov>, torvalds@osdl.org, akpm@osdl.org, arjan@infradead.org, arjanv@infradead.org, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mel@csn.ul.ie, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

Martin J. Bligh wrote:

> 
> To provide a slightly shorter version ... we had one customer running
> similarly large number crunching things in Fortran. Their app ran 25%
> faster with large pages (not a typo). Because they ran a variety of
> jobs in batch mode, they need large pages sometimes, and small pages
> at others - hence they need to dynamically resize the pool. 
> 
> That's the sort of thing we were trying to fix with dynamically sized
> hugepage pools. It does make a huge difference to real-world customers.
> 

Aren't HPC users very easy? In fact, probably the easiest because they
generally not very kernel intensive (apart from perhaps some batches of
IO at the beginning and end of the jobs).

A reclaimable zone should provide exactly what they need. I assume the
sysadmin can give some reasonable upper and lower estimates of the
memory requirements.

They don't need to dynamically resize the pool because it is all being
allocated to pagecache anyway, so all jobs are satisfied from the
reclaimable zone.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
