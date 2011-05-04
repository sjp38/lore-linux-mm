Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 710D76B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 17:14:33 -0400 (EDT)
Date: Wed, 4 May 2011 14:13:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] nommu: add page_align to mmap
Message-Id: <20110504141353.842409e1.akpm@linux-foundation.org>
In-Reply-To: <1303888334-16062-1-git-send-email-lliubbo@gmail.com>
References: <1303888334-16062-1-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, dhowells@redhat.com, lethal@linux-sh.org, gerg@uclinux.org, walken@google.com, daniel-gl@gmx.net, vapier@gentoo.org, Geert Uytterhoeven <geert@linux-m68k.org>

On Wed, 27 Apr 2011 15:12:14 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> Currently on nommu arch mmap(),mremap() and munmap() doesn't do page_align()
> which is incorrect and not consist with mmu arch.
> This patch fix it.
> 

Can you explain this fully please?  What was the user-observeable
behaviour before the patch, and after?

And some input from nommu maintainers would be nice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
