Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 8ED506B0036
	for <linux-mm@kvack.org>; Sat,  9 Aug 2014 07:31:43 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id f8so3598406wiw.3
        for <linux-mm@kvack.org>; Sat, 09 Aug 2014 04:31:42 -0700 (PDT)
Received: from mail3-relais-sop.national.inria.fr (mail3-relais-sop.national.inria.fr. [192.134.164.104])
        by mx.google.com with ESMTPS id gn8si7327449wib.23.2014.08.09.04.31.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 09 Aug 2014 04:31:42 -0700 (PDT)
Date: Sat, 9 Aug 2014 13:31:39 +0200 (CEST)
From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [next:master 9660/12021] mm/vmstat.c:1343:2-5: WARNING: Use
 BUG_ON
In-Reply-To: <53e5eeb3.j/1hw4T//eDPmwb+%fengguang.wu@intel.com>
Message-ID: <alpine.DEB.2.02.1408091329530.2016@localhost6.localdomain6>
References: <53e5eeb3.j/1hw4T//eDPmwb+%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild@01.org, cl@linux-foundation.org, akpm@linux-foundation.org, linux-mm@kvack.org

I suspect that using BUG_ON here is not a good idea, because the tested 
called function looks pretty important.  But I have forwarded it on in 
case someone thinks otherwise.

julia

On Sat, 9 Aug 2014, kbuild test robot wrote:

> TO: Christoph Lameter <cl@linux-foundation.org>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: Linux Memory Management List <linux-mm@kvack.org>
> 
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   6a062ecb62b37d6d36fa2e56052982565b0f5aac
> commit: f9054025fb65d0802098f18b153e4d720acd126e [9660/12021] on demand vmstat: Do not open code alloc_cpumask_var
> :::::: branch date: 27 hours ago
> :::::: commit date: 9 days ago
> 
> >> mm/vmstat.c:1343:2-5: WARNING: Use BUG_ON
> 
> Please consider folding the attached diff :-)
> 
> ---
> 0-DAY kernel build testing backend              Open Source Technology Center
> http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
