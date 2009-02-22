Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CC3076B003D
	for <linux-mm@kvack.org>; Sat, 21 Feb 2009 22:13:59 -0500 (EST)
Message-ID: <49A0C2D4.20009@zytor.com>
Date: Sat, 21 Feb 2009 19:13:24 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] kmemcheck: disable fast string operations on P4 CPUs
References: <1235223364-2097-1-git-send-email-vegard.nossum@gmail.com> <1235223364-2097-2-git-send-email-vegard.nossum@gmail.com>
In-Reply-To: <1235223364-2097-2-git-send-email-vegard.nossum@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Vegard Nossum <vegard.nossum@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Vegard Nossum wrote:
> This patch may allow us to remove the REP emulation code from
> kmemcheck.

> +#ifdef CONFIG_KMEMCHECK
> +	/*
> +	 * P4s have a "fast strings" feature which causes single-
> +	 * stepping REP instructions to only generate a #DB on
> +	 * cache-line boundaries.
> +	 *
> +	 * Ingo Molnar reported a Pentium D (model 6) and a Xeon
> +	 * (model 2) with the same problem.
> +	 */
> +	if (c->x86 == 15) {

If this is supposed to refer to the Intel P4 core, you should exclude
the post-P4 cores that also have x86 == 15 (e.g. Core 2 and Core i7).
If those are affected, too, they should be mentioned in the comment.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
