Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A58206B004F
	for <linux-mm@kvack.org>; Sun, 31 May 2009 07:46:44 -0400 (EDT)
Date: Sun, 31 May 2009 04:49:01 -0700
From: "Larry H." <research@subreption.com>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090531114901.GA10598@oblivion.subreption.com>
References: <20090530180333.GH6535@oblivion.subreption.com> <20090530182113.GA25237@elte.hu> <20090530184534.GJ6535@oblivion.subreption.com> <20090530190828.GA31199@elte.hu> <4A21999E.5050606@redhat.com> <84144f020905301353y2f8c232na4c5f9dfb740eec4@mail.gmail.com> <20090530213311.GM6535@oblivion.subreption.com> <20090531001318.093e3665@lxorguk.ukuu.org.uk> <20090530231813.GP6535@oblivion.subreption.com> <4A2223FE.3000309@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A2223FE.3000309@cs.helsinki.fi>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 09:30 Sun 31 May     , Pekka Enberg wrote:
> Larry H. wrote:
>> OK, I'm going to squeeze some time and provide patches that perform the
>> same my original page bit ones did, but using kzfree. Behold code like
>> in the tty buffer management, which uses the page allocator directly for
>> allocations greater than PAGE_SIZE in length. That needs special
>> treatment, and is exactly the reason I've proposed unconditional
>> sanitization since the original patches were rejected.
>
> You might want to also do the patch Alan suggested for the security 
> conscious people. That is, do a memset() in every page free and wrap that 
> under CONFIG_SECURITY_PARANOIA or something. There's no reason the kzfree() 
> patches and that can't co-exist.

I know you came late into the discussion, but if you had invested a
minute checking the thread, you would have spotted a patch in which a
Kconfig option was used to disable the sensitive page flag effects as whole.
The very first one.

I'm not wasting my time re-workign a patch which has been already
rejected. Go ahead and do it in your own time if you wish, it's GPL
anyway.

	Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
