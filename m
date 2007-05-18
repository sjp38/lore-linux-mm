Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l4I475Um285488
	for <linux-mm@kvack.org>; Fri, 18 May 2007 14:07:05 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4I3oRFH087182
	for <linux-mm@kvack.org>; Fri, 18 May 2007 13:50:28 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4I3koCv021562
	for <linux-mm@kvack.org>; Fri, 18 May 2007 13:46:51 +1000
Message-ID: <464D21A6.2070103@linux.vnet.ibm.com>
Date: Fri, 18 May 2007 09:16:46 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: RSS controller v2 Test results (lmbench )
References: <464C95D4.7070806@linux.vnet.ibm.com> <20070517112357.7adc4763.akpm@linux-foundation.org>
In-Reply-To: <20070517112357.7adc4763.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pavel Emelianov <xemul@sw.ru>, Paul Menage <menage@google.com>, Kirill Korotaev <dev@sw.ru>, devel@openvz.org, Linux Containers <containers@lists.osdl.org>, linux kernel mailing list <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Herbert Poetzl <herbert@13thfloor.at>, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Thu, 17 May 2007 23:20:12 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> A meaningful container size does not hamper performance. I am in the process
>> of getting more results (with varying container sizes). Please let me know
>> what you think of the results? Would you like to see different benchmarks/
>> tests/configuration results?
>>
>> Any feedback, suggestions to move this work forward towards identifying
>> and correcting bottlenecks or to help improve it is highly appreciated.
> 
> <wakes up>
> 
> Memory reclaim tends not to consume much CPU.  Because in steady state it
> tends to be the case that the memory reclaim rate (and hopefully the
> scanning rate) is equal to the disk IO rate.
> 

With the memory controller, I suspect memory reclaim will become a function
of the memory the container tries to touch that lies outside its limit.
If a container requires 512 MB of memory and we configure the container
size as 256 MB, then we might see aggressive memory reclaim. We do provide
some statistics to help the user figure out if the reclaim is aggressive,
we'll try and add more statistics.

> Often the most successful way to identify performance problems in there is
> by careful code inspection followed by development of exploits.
> 

> Is this RSS controller built on Paul's stuff, or is it standalone?
> 

It's built on top of the containers infrastructure. Version 2 was posted
on top of containers v8.

> Where do we stand on all of this now anyway?  I was thinking of getting Paul's
> changes into -mm soon, see what sort of calamities that brings about.
> 

The RSS controller was posted by Pavel based on some initial patches by me,
so we are in agreement w.r.t approach to memory control. Vaidy is working
on a page cache controller, we are able to use the existing RSS infrastructure
for writing the page cache controller (unmapped). All the stake holders are
on cc, I would request them to speak out on the issues and help build a way
to take this forward.

I've been reviewing and testing Paul's containers v9 patches. As and when
I find more issues, I plan to send out fixes. It'll be good to have the
containers infrastructure in -mm, so that we can start posting controllers
against them for review and acceptance.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
