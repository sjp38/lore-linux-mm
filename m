Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CBDC46B0011
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:42:42 -0400 (EDT)
Date: Thu, 26 May 2011 13:42:39 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [slubllv5 07/25] x86: Add support for cmpxchg_double
In-Reply-To: <4DDE9C01.2090104@zytor.com>
Message-ID: <alpine.DEB.2.00.1105261340570.26578@router.home>
References: <20110516202605.274023469@linux.com> <20110516202625.197639928@linux.com> <4DDE9670.3060709@zytor.com> <alpine.DEB.2.00.1105261315350.26578@router.home> <4DDE9C01.2090104@zytor.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

On Thu, 26 May 2011, H. Peter Anvin wrote:

> On 05/26/2011 11:17 AM, Christoph Lameter wrote:
> > On Thu, 26 May 2011, H. Peter Anvin wrote:
> >
> >>> +config CMPXCHG_DOUBLE
> >>> +	def_bool X86_64 || (X86_32 && !M386)
> >>> +
> >>
> >> CMPXCHG16B is not a baseline feature for the Linux x86-64 build, and
> >> CMPXCHG8G is a Pentium, not a 486, feature.
> >>
> >> Nacked-by: H. Peter Anvin <hpa@zytor.com>
> >
> > Hmmm... We may have to call it CONFIG_CMPXCHG_DOUBLE_POSSIBLE then?
> >
> > Because the slub code tests the flag in the processor and will not use the
> > cmpxchg16b from the allocator if its not there. It will then fallback to
> > using a bit lock in page struct.
> >
>
> Well, if it is just about being "possible" then it should simply be true
> for all of x86.  There is no reason to exclude i386 (which is all your
> above predicate does, it is exactly equivalent to !M386).

Ok. Possible means that the code for cmpxchg16b/8b will be compiled in.
Then how do I exclude the code if someone compiles a kernel for a
processor that certainly does not support these instructions?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
