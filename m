Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8D0AE6B004F
	for <linux-mm@kvack.org>; Sun, 12 Jul 2009 03:44:17 -0400 (EDT)
Date: Sun, 12 Jul 2009 09:57:31 +0200
From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Subject: Re: [BUG 2.6.30] Bad page map in process
Message-ID: <20090712095731.3090ef56@siona>
In-Reply-To: <Pine.LNX.4.64.0907101900570.27223@sister.anvils>
References: <Pine.LNX.4.64.0907081250110.15633@axis700.grange>
	<Pine.LNX.4.64.0907101900570.27223@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Guennadi Liakhovetski <g.liakhovetski@gmx.de>, linux-mm@kvack.org, kernel@avr32linux.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 10 Jul 2009 19:34:06 +0100 (BST)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:

> I've not looked up avr32 pte layout, is 13f26ed4 good or bad?
> I hope avr32 people can tell more about the likely cause.

It looks OK for a user mapping, assuming you have at least 64MB of
SDRAM (the SDRAM starts at 0x10000000) -- all the normal userspace flags
are set and all the kernel-only flags are unset. It's marked as
executable, so it could be that the segfault was caused by the CPU
executing the wrong code.

The virtual address 0x4377f876 is a bit higher than what you normally
see on avr32 systems, but there's not necessarily anything wrong with
it -- userspace goes up to 0x80000000.

Btw, is preempt enabled when you see this?

Haavard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
