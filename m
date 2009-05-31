Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C64FD5F0001
	for <linux-mm@kvack.org>; Sat, 30 May 2009 22:04:43 -0400 (EDT)
Date: Sat, 30 May 2009 19:04:43 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] Use kzfree in tty buffer management to enforce data
 sanitization
In-Reply-To: <20090531015537.GA8941@oblivion.subreption.com>
Message-ID: <alpine.LFD.2.01.0905301902530.3435@localhost.localdomain>
References: <20090531015537.GA8941@oblivion.subreption.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>



On Sat, 30 May 2009, Larry H. wrote:
>
> This patch doesn't affect fastpaths.

This patch is ugly as hell.

You already know the size of the data to clear.

If we actually wanted this (and I am in _no_way_ saying we do), the only 
sane thing to do is to just do

	memset(buf->data, 0, N_TTY_BUF_SIZE);
	if (PAGE_SIZE != N_TTY_BUF_SIZE)
		kfree(...)
	else
		free_page(...)


but quite frankly, I'm not convinced about these patches at all.

I'm also not in the least convinced about how you just dismiss everybodys 
concerns.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
