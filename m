Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id DB38A6B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 17:37:15 -0500 (EST)
Message-ID: <5127F319.2090302@redhat.com>
Date: Fri, 22 Feb 2013 17:37:13 -0500
From: Larry Woodman <lwoodman@redhat.com>
Reply-To: lwoodman@redhat.com
MIME-Version: 1.0
Subject: Re: [Lsf-pc] [LSF/MM TOPIC][ATTEND] topics I'd like to discuss
References: <51279035.5050304@redhat.com> <5127E601.6080202@redhat.com>
In-Reply-To: <5127E601.6080202@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org, Linux Memory Management List <linux-mm@kvack.org>

On 02/22/2013 04:41 PM, Rik van Riel wrote:
> On 02/22/2013 10:35 AM, Larry Woodman wrote:
>> 1.) Using mmu notifiers to set up the page tables for integrated
>> devices(GPUs) and allowing the generic
>>       kernel pagefault handler to resolve translations for those 
>> devices.
>
> This functionality is also desired by people who want to run
> memory coherency over infiniband and some other very fast
> network fabrics, as well as by the people who want to offload
> work to specialized cores in their system.
>
> Since there are multiple use cases for this kind of functionality,
> I believe that it is important we get the infrastructure right,
> and discussing this topic at LSF/MM sounds like a good idea.
Agreed.
>
>> 2.) Replication of pagecache pages on NUMA nodes.
>
> What about this would you like to discuss?
The tradeoffs between local memory access for frequently referenced 
read-only/executable
pages like shared library text and the additional memory consumption 
associated replicating
pages on multiple NUMA nodes.
>
> Is there some proposal of code to do this?
Not yet, I implemented replication of filesystem cache memory on each 
NUMA node
several years ago for a UNIX kernel when NUMA systems first appeared.  
At that
time both memory and caches were much smaller than they are now so the 
tradeoffs
between local memory access and inducing page reclamation were different 
than they
are now.  However there was a significant performance boost on memory 
rich systems
running applications with bloated text sections.

Larry


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
