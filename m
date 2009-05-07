Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4978B6B003D
	for <linux-mm@kvack.org>; Thu,  7 May 2009 10:27:15 -0400 (EDT)
Message-ID: <4A02EFD2.40707@zytor.com>
Date: Thu, 07 May 2009 07:27:30 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86: 46 bit PAE support
References: <20090505172856.6820db22@cuia.bos.redhat.com> <4A00ED83.1030700@zytor.com> <4A0180AB.20108@redhat.com> <20090507120103.GA1497@ucw.cz> <20090507141642.GJ481@elte.hu>
In-Reply-To: <20090507141642.GJ481@elte.hu>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Pavel Machek <pavel@ucw.cz>, Rik van Riel <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, mingo@redhat.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> 
> Yes, struct page is ~64 bytes, and 64*64 == 4096.
> 
> Alas, it's not a problem: my suggestion wasnt to simulate 64 TB of 
> RAM. My suggestion was to create a sparse physical memory map (in a 
> virtual machine) that spreads ~1GB of RAM all around the 64 TB 
> physical address space. That will test whether the kernel is able to 
> map and work with such physical addresses. (which will cover most of 
> the issues)
> 
> A good look at /debug/x86/dump_pagetables with such a system booted 
> up would be nice as well - to make sure every virtual memory range 
> is in its proper area, and that there's enough free space around 
> them.
> 

We're working on simulating this at Intel.  We should hopefully be able
to test this next week.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
