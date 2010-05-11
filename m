Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D189E6B023B
	for <linux-mm@kvack.org>; Tue, 11 May 2010 00:56:58 -0400 (EDT)
Subject: Re: [PATCH 19/25] lmb: Add array resizing support
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <AANLkTinOVSpCXdkkcCHMdN-HWsImE7_Gcbgg5plnNMss@mail.gmail.com>
References: <1273484339-28911-1-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-12-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-13-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-14-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-15-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-16-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-17-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-18-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-19-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-20-git-send-email-benh@kernel.crashing.org>
	 <AANLkTinOVSpCXdkkcCHMdN-HWsImE7_Gcbgg5plnNMss@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 11 May 2010 14:56:05 +1000
Message-ID: <1273553765.21352.1.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Yinghai Lu <yhlu.kernel@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org
List-ID: <linux-mm.kvack.org>

On Mon, 2010-05-10 at 16:59 -0700, Yinghai Lu wrote:
> you need to pass base, base+size with lmb_double_array()
> 
> otherwise when you are using lmb_reserve(base, size), double_array()
> array could have chance to get
> new buffer that is overlapped with [base, base + size).
> 
> to keep it simple, should check_double_array() after lmb_reserve,
> lmb_add, lmb_free (yes, that need it too).
> that was suggested by Michael Ellerman.
> 

No. You may notice that I addressed this problem by moving the
call to lmb_double_array() to -after- we record the entry in
the array, so it shouldn't be able to pickup the same one.

I dislike the idea of sprinkling the check for resize everywhere at the
top level.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
