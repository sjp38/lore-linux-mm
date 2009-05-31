Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C79B66B004F
	for <linux-mm@kvack.org>; Sun, 31 May 2009 08:24:03 -0400 (EDT)
Message-ID: <4A2275EF.2050409@cs.helsinki.fi>
Date: Sun, 31 May 2009 15:19:59 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page	allocator
References: <20090530082048.GM29711@oblivion.subreption.com> <20090530173428.GA20013@elte.hu> <20090530180333.GH6535@oblivion.subreption.com> <20090530182113.GA25237@elte.hu> <20090530184534.GJ6535@oblivion.subreption.com> <20090530190828.GA31199@elte.hu> <4A21999E.5050606@redhat.com> <84144f020905301353y2f8c232na4c5f9dfb740eec4@mail.gmail.com> <20090531001052.40ac57d2@lxorguk.ukuu.org.uk> <84144f020905302314w12c4c7f8jc8241e36c847f53e@mail.gmail.com> <20090531121636.GC10598@oblivion.subreption.com>
In-Reply-To: <20090531121636.GC10598@oblivion.subreption.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Larry H. wrote:
>> No, there's nothing wrong with ksize() I am aware of. Yes, Larry has
>> been saying it is but hasn't provided any evidence so far.
> 
> Excuse me, do you have an attention or reading disorder? Compound pages
> and SLOB anyone? Duplication of test branches for pointer validation?

I don't see a bug there. I cc'd Matt Mackall who is the author of SLOB. 
I am sure he will be able to spot the bug if it in fact exists (which I 
seriously doubt).

Feel free to prove me wrong by sending a patch to fix SLOB. But until 
then, please stop spamming my inbox. Thanks!

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
