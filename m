Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7B2716B0085
	for <linux-mm@kvack.org>; Sat, 21 Feb 2009 11:26:06 -0500 (EST)
Message-ID: <49A02A23.8000308@cs.helsinki.fi>
Date: Sat, 21 Feb 2009 18:21:55 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] kmemcheck: rip out REP instruction emulation
References: <1235223364-2097-1-git-send-email-vegard.nossum@gmail.com> <1235223364-2097-3-git-send-email-vegard.nossum@gmail.com>
In-Reply-To: <1235223364-2097-3-git-send-email-vegard.nossum@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Vegard Nossum <vegard.nossum@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Vegard Nossum wrote:
> As it turns out, disabling the "fast strings" of the P4 fixed the
> REP single-stepping issue, so this code is not needed anymore.
> 
> Celebrate, for we just got rid of a LOT of complexity and pain.
> 
> Signed-off-by: Vegard Nossum <vegard.nossum@gmail.com>

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
