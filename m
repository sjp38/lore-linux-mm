Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id AAA10161
	for <linux-mm@kvack.org>; Sun, 27 Oct 2002 00:32:43 -0700 (PDT)
Message-ID: <3DBB9699.4F07BA71@digeo.com>
Date: Sun, 27 Oct 2002 00:32:41 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.42-mm2
References: <3DA7C3A5.98FCC13E@digeo.com> <20021013101949.GB2032@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> This patch does 5 things:
> 
> (1) when the OOM killer fails and the system panics, calls
>         show_free_areas()
> (2) reorganizes show_free_areas() to use for_each_zone()
> (3) adds per-cpu stats to show_free_areas()
> (4) tags output from show_free_areas() with node and zone information
> (5) initializes zone->per_cpu_pageset[cpu].pcp[temperature].reserved
>         in free_area_init_core()

hm.  I just ran out of swap and got oom-killed.

Would it make sense to call show_free_areas() for _all_ oom-killings?

I think so.  At least during the development cycle.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
