Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D9A5B6B004D
	for <linux-mm@kvack.org>; Tue,  5 May 2009 04:05:54 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id f25so2923801rvb.26
        for <linux-mm@kvack.org>; Tue, 05 May 2009 01:05:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <49FED524.9020602@gmail.com>
References: <49FED524.9020602@gmail.com>
Date: Tue, 5 May 2009 15:05:58 +0700
Message-ID: <f284c33d0905050105r5c0d8d37l68cad8cce6ffb54d@mail.gmail.com>
Subject: Re: Memory Concepts [+Newbie]
From: Mulyadi Santosa <mulyadi.santosa@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Marcos Roriz <marcosrorizinf@gmail.com>
Cc: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi...

On Mon, May 4, 2009 at 6:44 PM, Marcos Roriz <marcosrorizinf@gmail.com> wrote:
> The ZONE_NORMAL zone refer only to kernel direct memory mapped, that means
> only to kernel pages and kernel programs (such as daemons)?

as the name implies, it means a memory area where kernel can directly
address it without a need to do temporary mapping.

For the user space programs, it has somewhat loose connection. When
kernel try to serve memory request from user space, it could get free
pages from either zone normal or highmem (depending on the priority).
Once these oages are "connected " to user space via PTE (page table
entry), they are directly accessible by user space program.


> Why is the ZONE_NORMAL so large (896 MB)? How to deal with low memory
> systems?

first of all, you need to understand the default virtual memory split
for x86 32 bit system, that is 3:1. Meaning, user mode has 3 GB, while
kernel has 1 GB. Inside this 1GB address space, not all address range
can be used. Some of them are used for temporary mapping, vmalloc
mapping and so on. Short story, you're left with 896 MB address space.

For low memory system, the address space is still 1 GB. But in
reality, only a little is used to map the RAM. So in hand we have
large address space, but it doesn't mean all those addresses are used.

> The ZONE_HIGHMEM zone refer to kernel not mapped directly, so that includes
> userspace programs right?

Kindly refer to my explanations above :) Again, user space program
doesn't really care about zone normal or highmem.

regards,

Mulyadi.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
