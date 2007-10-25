Date: Thu, 25 Oct 2007 09:35:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/2] Export memblock migrate type to /sysfs
Message-Id: <20071025093531.d2357422.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1193243860.30836.22.camel@dyn9047017100.beaverton.ibm.com>
References: <1193243860.30836.22.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: melgor@ie.ibm.com, haveblue@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 24 Oct 2007 09:37:40 -0700
Badari Pulavarty <pbadari@us.ibm.com> wrote:

> Hi,
> 
> Now that grouping of pages by mobility is in mainline, I would like 
> to make use of it for selection memory blocks for hotplug memory remove.
> Following set of patches exports memblock's migrate type to /sysfs. 
> This would be useful for user-level agent for selecting memory blocks
> to try to remove.
> 
> 	[PATCH 1/2] Fix migratetype_names[] and make it available
> 	[PATCH 2/2] Add mem_type in /syfs to show memblock migrate type
> 
At first, I welcome this patch. Thanks :)
> Todo:
> 
> 	Currently, we decide the memblock's migrate type looking at
> first page of memblock. But on some architectures (x86_64), each
> memblock can contain multiple groupings of pages by mobility. Is it
> important to address ?

Hmm, that is a problem annoying me. There is 2 points.

1. In such arch, we'll have to use ZONE_MOVABLE for hot-removable.
2. But from view of showing information to users, more precice is better
   of course.

How about showing information as following ?
==
%cat ./memory/memory0/mem_type
 1 0 0 0 0
%
as 
 Reserved Unmovable Movable Reserve Isolate

==
This is not difficult and can show all information.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
