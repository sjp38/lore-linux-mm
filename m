Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id DE5A183200
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 14:39:01 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id e5so73654232pgk.1
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 11:39:01 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id a5si4131387plh.190.2017.03.08.11.39.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 11:39:00 -0800 (PST)
Date: Wed, 8 Mar 2017 11:39:00 -0800
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH] mm,hugetlb: compute page_size_log properly
Message-ID: <20170308193900.GC32070@tassilo.jf.intel.com>
References: <1488992761-9464-1-git-send-email-dave@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1488992761-9464-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: akpm@linux-foundation.org, mhocko@suse.com, mtk.manpages@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

> One example of the problems with extra layers what this patch fixes:
> mmap_pgoff() should never be using SHM_HUGE_* logic. This was
> introduced by:
> 
>    091d0d55b28 (shm: fix null pointer deref when userspace specifies invalid hugepage size)
> 
> It is obviously harmless but lets just rip out the whole thing --
> the shmget.2 manpage will need updating, as it should not be
> describing kernel internals.

The SHM_* defines were supposed to be exported to user space,
but somehow they didn't make it into uapi.

But something like this is useful, it's a much nicer 
interface for users than to hard code the bit position

So I would rather if you move it to uapi instead of 
removing. What the kernel uses internally doesn't
really matter.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
