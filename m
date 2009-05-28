Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 785A96B005D
	for <linux-mm@kvack.org>; Thu, 28 May 2009 14:55:59 -0400 (EDT)
From: pageexec@freemail.hu
Date: Thu, 28 May 2009 20:56:55 +0200
MIME-Version: 1.0
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page allocator
Reply-to: pageexec@freemail.hu
Message-ID: <4A1EDE77.32340.EF6193F@pageexec.freemail.hu>
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7BIT
Content-description: Mail message body
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>, Ingo Molnar <mingo@elte.hu>
Cc: Rik van Riel <riel@redhat.com>, "Larry H." <research@subreption.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 28 May 2009 at 20:48, Alan Cox , Ingo Molnar wrote:

> last year while developing/debugging something else i also ran some kernel
> compilation tests and managed to dig out this one for you ('all' refers to
> all of PaX):
> 
> ------------------------------------------------------------------------------------------
> make -j4 2.6.24-rc7-i386-pax compiling 2.6.24-rc7-i386-pax (all with SANITIZE, no PARAVIRT)

addendum: i just checked and that version didn't omit GPF_ZERO handling therefore
the current version should have better performance, at least on this kind of workload
where lots of anonymous userland pages are instantiated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
