Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id B1FBC6B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 16:41:24 -0500 (EST)
Message-ID: <5127E601.6080202@redhat.com>
Date: Fri, 22 Feb 2013 16:41:21 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [Lsf-pc] [LSF/MM TOPIC][ATTEND] topics I'd like to discuss
References: <51279035.5050304@redhat.com>
In-Reply-To: <51279035.5050304@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: Linux Memory Management List <linux-mm@kvack.org>, Larry Woodman <lwoodman@redhat.com>

On 02/22/2013 10:35 AM, Larry Woodman wrote:
> 1.) Using mmu notifiers to set up the page tables for integrated
> devices(GPUs) and allowing the generic
>       kernel pagefault handler to resolve translations for those devices.

This functionality is also desired by people who want to run
memory coherency over infiniband and some other very fast
network fabrics, as well as by the people who want to offload
work to specialized cores in their system.

Since there are multiple use cases for this kind of functionality,
I believe that it is important we get the infrastructure right,
and discussing this topic at LSF/MM sounds like a good idea.

> 2.) Replication of pagecache pages on NUMA nodes.

What about this would you like to discuss?

Is there some proposal of code to do this?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
