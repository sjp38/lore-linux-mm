Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C966E6B01CD
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 07:31:59 -0400 (EDT)
Date: Tue, 22 Jun 2010 20:31:36 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] kmemleak: config-options: Default buffer size for kmemleak
Message-ID: <20100622113135.GB20140@linux-sh.org>
References: <AANLkTimb7rP0rS0OU8nan5uNEhHx_kEYL99ImZ3c8o0D@mail.gmail.com> <1277189909-16376-1-git-send-email-sankar.curiosity@gmail.com> <4C20702C.1080405@cs.helsinki.fi> <1277196403-20836-1-git-send-email-sankar.curiosity@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1277196403-20836-1-git-send-email-sankar.curiosity@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Sankar P <sankar.curiosity@gmail.com>
Cc: penberg@cs.helsinki.fi, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org, lrodriguez@atheros.com, catalin.marinas@arm.com, rnagarajan@novell.com, teheo@novell.com, linux-mm@kvack.org, paulmck@linux.vnet.ibm.com, mingo@elte.hu, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 22, 2010 at 02:16:43PM +0530, Sankar P wrote:
> If we try to find the memory leaks in kernel that is
> compiled with 'make defconfig', the default buffer size
> of DEBUG_KMEMLEAK_EARLY_LOG_SIZE seem to be inadequate.
> 
> Change the buffer size from 400 to 1000,
> which is sufficient for most cases.
> 
Or you could just bump it up in your config where you seem to be hitting
this problem. The default of 400 is sufficient for most people, so
bloating it up for a corner case seems a bit premature. Perhaps
eventually we'll have no choice and have to tolerate the bloat, as we did
with LOG_BUF_SHIFT, but it's not obvious that we've hit that point with
kmemleak yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
