Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 34D306B0011
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 11:48:21 -0400 (EDT)
Message-ID: <4DE65DB6.4050801@zytor.com>
Date: Wed, 01 Jun 2011 08:41:42 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [slubllv5 07/25] x86: Add support for cmpxchg_double
References: <20110516202605.274023469@linux.com>  <20110516202625.197639928@linux.com> <4DDE9670.3060709@zytor.com>  <alpine.DEB.2.00.1105261315350.26578@router.home>  <4DDE9C01.2090104@zytor.com>  <alpine.DEB.2.00.1105261615130.591@router.home> <1306445159.2543.25.camel@edumazet-laptop> <alpine.DEB.2.00.1105311012420.18755@router.home> <4DE50632.90906@zytor.com> <alpine.DEB.2.00.1105311058030.19928@router.home> <4DE576EA.6070906@zytor.com> <alpine.DEB.2.00.1105311846230.31190@router.home> <4DE57FBB.8040408@zytor.com> <alpine.DEB.2.00.1106010910430.22901@router.home>
In-Reply-To: <alpine.DEB.2.00.1106010910430.22901@router.home>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

On 06/01/2011 07:13 AM, Christoph Lameter wrote:
>>
>> Per your own description:
>>
>> "CMPXCHG_DOUBLE only compiles in detection support. It needs to be set
>> if there is a chance that processor supports these instructions."
>>
>> That condition is always TRUE, so no Kconfig is needed.
> 
> There are several early processors (especially from AMD it seems) that do
> not support cmpxchg16b. If one builds a kernel specifically for the early
> cpus then the support does not need to be enabled.
> 

We don't support building kernels specifically for those early CPUs as
far as I know.  Besides, it is a very small set.  Even if we did, the
conditional as you have specified it is wrong, and I mean "not even in
the general ballpark of correct".

> This is also an issue going beyond x86. Other platforms mostly do not
> support double word cmpxchg so the code for this feature also does not
> need to be included for those builds.

That's fine; just set it unconditionally for x86.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
