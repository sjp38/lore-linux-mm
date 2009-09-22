Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3FF056B004D
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 02:13:50 -0400 (EDT)
Subject: Re: [PATCH 0/3] compcache: in-memory compressed swapping v4
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <1253595414-2855-1-git-send-email-ngupta@vflare.org>
References: <1253595414-2855-1-git-send-email-ngupta@vflare.org>
Date: Tue, 22 Sep 2009 09:13:50 +0300
Message-Id: <1253600030.30406.2.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Marcin Slusarz <marcin.slusarz@gmail.com>, Ed Tomlinson <edt@aei.ca>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-mm-cc <linux-mm-cc@laptop.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-09-22 at 10:26 +0530, Nitin Gupta wrote:
>  drivers/staging/Kconfig                   |    2 +
>  drivers/staging/Makefile                  |    1 +
>  drivers/staging/ramzswap/Kconfig          |   21 +
>  drivers/staging/ramzswap/Makefile         |    3 +
>  drivers/staging/ramzswap/ramzswap.txt     |   51 +
>  drivers/staging/ramzswap/ramzswap_drv.c   | 1462 +++++++++++++++++++++++++++++
>  drivers/staging/ramzswap/ramzswap_drv.h   |  173 ++++
>  drivers/staging/ramzswap/ramzswap_ioctl.h |   50 +
>  drivers/staging/ramzswap/xvmalloc.c       |  533 +++++++++++
>  drivers/staging/ramzswap/xvmalloc.h       |   30 +
>  drivers/staging/ramzswap/xvmalloc_int.h   |   86 ++
>  include/linux/swap.h                      |    5 +
>  mm/swapfile.c                             |   34 +
>  13 files changed, 2451 insertions(+), 0 deletions(-)

This diffstat is not up to date, I think.

Greg, would you mind taking this driver into staging? There are some
issues that need to be ironed out for it to be merged to kernel proper
but I think it would benefit from being exposed to mainline.

Nitin, you probably should also submit a patch that adds a TODO file
similar to other staging drivers to remind us that swap notifiers and
the CONFIG_ARM thing need to be resolved.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
