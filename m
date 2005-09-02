Subject: Re: [PATCH 2.6.13] lockless pagecache 2/7
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <4318C28A.5010000@yahoo.com.au>
References: <4317F071.1070403@yahoo.com.au> <4317F0F9.1080602@yahoo.com.au>
	 <4317F136.4040601@yahoo.com.au>
	 <1125666486.30867.11.camel@localhost.localdomain>
	 <p73k6hzqk1w.fsf@verdi.suse.de>  <4318C28A.5010000@yahoo.com.au>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Sat, 03 Sep 2005 00:57:51 +0100
Message-Id: <1125705471.30867.40.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andi Kleen <ak@suse.de>, Linux Memory Management <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sad, 2005-09-03 at 07:22 +1000, Nick Piggin wrote:
> > Actually we have cmpxchg on i386 these days - we don't support
> > any SMP i386s so it's just done non atomically.
> 
> Yes, I guess that's what Alan must have meant.

Well I was thinking about things like pre-empt. Also the x86 cmpxchg()
is defined for non i386 processors to allow certain things to use it
(ACPI, DRM etc) which know they won't be on a 386. The implementation in
this case will blow up on a 386 and the __HAVE_ARCH_CMPXCHG remains
false.

> but I suspect that SMP isn't supported on those CPUs without ll/sc,
> and thus an atomic_cmpxchg could be emulated by disabling interrupts.

It's obviously emulatable on any platform - the question is at what
cost. For x86 it probably isn't a big problem as there are very very few
people who need to build for 386 any more and there is already a big
penalty for such chips.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
