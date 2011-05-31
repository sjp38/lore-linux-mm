Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2473F6B0011
	for <linux-mm@kvack.org>; Tue, 31 May 2011 11:10:38 -0400 (EDT)
Date: Tue, 31 May 2011 10:10:31 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [slubllv5 07/25] x86: Add support for cmpxchg_double
In-Reply-To: <4DDEF559.6040107@zytor.com>
Message-ID: <alpine.DEB.2.00.1105311009470.18755@router.home>
References: <20110516202605.274023469@linux.com> <20110516202625.197639928@linux.com> <4DDE9670.3060709@zytor.com> <alpine.DEB.2.00.1105261315350.26578@router.home> <4DDE9C01.2090104@zytor.com> <alpine.DEB.2.00.1105261615130.591@router.home>
 <4DDEF559.6040107@zytor.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

On Thu, 26 May 2011, H. Peter Anvin wrote:

> On 05/26/2011 02:16 PM, Christoph Lameter wrote:
> > +	asm volatile(LOCK_PREFIX_HERE "lock; cmpxchg16b (%%rsi);setz %1" \
>
> Just spotted this: LOCK_PREFIX_HERE "lock; " is kind of redundant, no?

cmpxchg_386 does that too. Got it from there I guess.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
