Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0F07A6B006A
	for <linux-mm@kvack.org>; Sun, 31 May 2009 02:34:15 -0400 (EDT)
Message-ID: <4A2223FE.3000309@cs.helsinki.fi>
Date: Sun, 31 May 2009 09:30:22 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page	allocator
References: <20090530082048.GM29711@oblivion.subreption.com> <20090530173428.GA20013@elte.hu> <20090530180333.GH6535@oblivion.subreption.com> <20090530182113.GA25237@elte.hu> <20090530184534.GJ6535@oblivion.subreption.com> <20090530190828.GA31199@elte.hu> <4A21999E.5050606@redhat.com> <84144f020905301353y2f8c232na4c5f9dfb740eec4@mail.gmail.com> <20090530213311.GM6535@oblivion.subreption.com> <20090531001318.093e3665@lxorguk.ukuu.org.uk> <20090530231813.GP6535@oblivion.subreption.com>
In-Reply-To: <20090530231813.GP6535@oblivion.subreption.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Larry H. wrote:
> OK, I'm going to squeeze some time and provide patches that perform the
> same my original page bit ones did, but using kzfree. Behold code like
> in the tty buffer management, which uses the page allocator directly for
> allocations greater than PAGE_SIZE in length. That needs special
> treatment, and is exactly the reason I've proposed unconditional
> sanitization since the original patches were rejected.

You might want to also do the patch Alan suggested for the security 
conscious people. That is, do a memset() in every page free and wrap 
that under CONFIG_SECURITY_PARANOIA or something. There's no reason the 
kzfree() patches and that can't co-exist.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
