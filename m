Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0B3AE6B005A
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 07:37:51 -0400 (EDT)
Date: Fri, 25 Sep 2009 12:36:15 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: No more bits in vm_area_struct's vm_flags.
In-Reply-To: <4ABC7FBC.4050409@crca.org.au>
Message-ID: <Pine.LNX.4.64.0909251225150.7496@sister.anvils>
References: <4AB9A0D6.1090004@crca.org.au> <Pine.LNX.4.64.0909232056020.3360@sister.anvils>
 <4ABC7FBC.4050409@crca.org.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nigel Cunningham <ncunningham@crca.org.au>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 25 Sep 2009, Nigel Cunningham wrote:
> Hugh Dickins wrote:
> > 
> > Does TuxOnIce rely on CONFIG_MMU?  If so, then the TuxOnIce patch
> > could presumably reuse VM_MAPPED_COPY for now - but don't be
> > surprised if that's one we clean away later on.
> 
> Hmm. I'm not sure. The requirements are the same as for swsusp and
> uswsusp. Is there some tool to graph config dependencies?

If its requirements are the same as theirs, then I think yes,
TuxOnIce relies on  config MMU: because config HIBERNATION depends
on SWAP (kernel/power/Kconfig) and config SWAP depends on MMU
(init/Kconfig).

But I hesitated to assume that, because in the TuxOnIce patch I have
here for reference (e.g. when deciding it'll cause you unwelcome hassle
if I move swap_info_struct from swap.h to swapfile.c!), it looked as if
you support saving to an ordinary file, not just to a swap file?

> Is there some tool to graph config dependencies?

I don't know it, but would be nice, and maybe it does exist.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
