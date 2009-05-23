Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8B5E76B0055
	for <linux-mm@kvack.org>; Sat, 23 May 2009 18:42:24 -0400 (EDT)
Message-ID: <4A187BDE.5070601@redhat.com>
Date: Sat, 23 May 2009 18:42:38 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page	allocator
References: <20090520183045.GB10547@oblivion.subreption.com> <4A15A8C7.2030505@redhat.com> <20090522073436.GA3612@elte.hu> <20090522113809.GB13971@oblivion.subreption.com> <20090523124944.GA23042@elte.hu>
In-Reply-To: <20090523124944.GA23042@elte.hu>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: "Larry H." <research@subreption.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:

> What you are missing is that your patch makes _no technical sense_ 
> if you allow the same information to leak over the kernel stack. 
> Kernel stacks can be freed and reused, swapped out and thus 
> 'exposed'.

Kernel stacks may be freed and reused, but Larry's latest
patch takes care of that by clearing them at page free
time.

As for being swapped out - I do not believe that kernel
stacks can ever be swapped out in Linux.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
