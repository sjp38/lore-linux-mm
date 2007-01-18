From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Thu, 18 Jan 2007 17:43:13 +1100 (EST)
Subject: Re: [PATCH 5/29] Start calling simple PTI functions
In-Reply-To: <Pine.LNX.4.64.0701161103140.6637@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0701181729530.12779@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
 <20070113024606.29682.18276.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.64.0701161103140.6637@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Paul Davies <pauld@gelato.unsw.edu.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Jan 2007, Christoph Lameter wrote:

> On Sat, 13 Jan 2007, Paul Davies wrote:
>
>> @@ -308,6 +309,7 @@
>>  } while (0)
>>
>>  struct mm_struct {
>> +	pt_t page_table;					/* Page table */
>>  	struct vm_area_struct * mmap;		/* list of VMAs */
>
> Why are you changing the location of the page table pointer in mm struct?
This was part of an ugly and temporary hack to get our alternative page
table (a guarded page table) going.  I wrote an ugly hack to get the GPT
lookup happening on my machine, then passed it on to a PhD student
to deal with it (it still requires further work).  The lookup was
dependent upon the position in the struct.

It will be moved back next time I push the patches out.

Cheers

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
