Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9OGYImx018409
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 12:34:18 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9OGYGLb082244
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 10:34:17 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9OGYGIW018579
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 10:34:16 -0600
Subject: [RFC][PATCH 0/2] Export memblock migrate type to /sysfs
From: Badari Pulavarty <pbadari@us.ibm.com>
Content-Type: text/plain
Date: Wed, 24 Oct 2007 09:37:40 -0700
Message-Id: <1193243860.30836.22.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, melgor@ie.ibm.com, haveblue@us.ibm.com
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

Now that grouping of pages by mobility is in mainline, I would like 
to make use of it for selection memory blocks for hotplug memory remove.
Following set of patches exports memblock's migrate type to /sysfs. 
This would be useful for user-level agent for selecting memory blocks
to try to remove.

	[PATCH 1/2] Fix migratetype_names[] and make it available
	[PATCH 2/2] Add mem_type in /syfs to show memblock migrate type

Todo:

	Currently, we decide the memblock's migrate type looking at
first page of memblock. But on some architectures (x86_64), each
memblock can contain multiple groupings of pages by mobility. Is it
important to address ?

Here is the output:

./memory/memory0/mem_type: Movable
./memory/memory1/mem_type: Movable
./memory/memory2/mem_type: Reserve
./memory/memory3/mem_type: Unmovable
./memory/memory4/mem_type: Movable
./memory/memory5/mem_type: Movable
./memory/memory6/mem_type: Movable
./memory/memory7/mem_type: Movable
./memory/memory8/mem_type: Reclaimable
./memory/memory9/mem_type: Unmovable
./memory/memory10/mem_type: Reclaimable
./memory/memory11/mem_type: Reclaimable
./memory/memory12/mem_type: Movable
./memory/memory13/mem_type: Movable
./memory/memory14/mem_type: Reclaimable
./memory/memory15/mem_type: Movable
./memory/memory16/mem_type: Reclaimable
./memory/memory17/mem_type: Reclaimable
./memory/memory18/mem_type: Reclaimable
./memory/memory19/mem_type: Reclaimable
./memory/memory20/mem_type: Reclaimable
./memory/memory21/mem_type: Reclaimable
./memory/memory22/mem_type: Reclaimable
./memory/memory23/mem_type: Reclaimable
./memory/memory24/mem_type: Reclaimable
./memory/memory25/mem_type: Reclaimable
./memory/memory26/mem_type: Reclaimable
./memory/memory27/mem_type: Reclaimable
./memory/memory28/mem_type: Reclaimable
./memory/memory29/mem_type: Reclaimable
./memory/memory30/mem_type: Reclaimable
./memory/memory31/mem_type: Reclaimable
./memory/memory32/mem_type: Reclaimable
./memory/memory33/mem_type: Reclaimable
./memory/memory34/mem_type: Reclaimable
./memory/memory35/mem_type: Reclaimable
./memory/memory36/mem_type: Reclaimable
./memory/memory37/mem_type: Reclaimable
./memory/memory38/mem_type: Reclaimable
./memory/memory39/mem_type: Reclaimable
./memory/memory40/mem_type: Reclaimable
./memory/memory41/mem_type: Movable
./memory/memory42/mem_type: Movable
./memory/memory43/mem_type: Movable
./memory/memory44/mem_type: Movable
./memory/memory45/mem_type: Movable
./memory/memory46/mem_type: Movable
./memory/memory47/mem_type: Movable
./memory/memory48/mem_type: Movable
./memory/memory49/mem_type: Movable

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
