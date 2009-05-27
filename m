Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B29D96B00A4
	for <linux-mm@kvack.org>; Wed, 27 May 2009 18:34:01 -0400 (EDT)
Date: Thu, 28 May 2009 00:34:21 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090527223421.GA9503@elte.hu>
References: <20090520183045.GB10547@oblivion.subreption.com> <4A15A8C7.2030505@redhat.com> <20090522073436.GA3612@elte.hu> <20090522113809.GB13971@oblivion.subreption.com> <20090523124944.GA23042@elte.hu> <4A187BDE.5070601@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A187BDE.5070601@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: "Larry H." <research@subreption.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>


* Rik van Riel <riel@redhat.com> wrote:

> Ingo Molnar wrote:
>
>> What you are missing is that your patch makes _no technical 
>> sense_ if you allow the same information to leak over the kernel 
>> stack. Kernel stacks can be freed and reused, swapped out and 
>> thus 'exposed'.
>
> Kernel stacks may be freed and reused, but Larry's latest patch 
> takes care of that by clearing them at page free time.
>
> As for being swapped out - I do not believe that kernel stacks can 
> ever be swapped out in Linux.

yes, i referred to that as an undesirable option - because it slows 
down pthread_create() quite substantially.

This needs before/after pthread_create() benchmark results.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
