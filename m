Subject: Re: [PATCH 2.6.13] lockless pagecache 2/7
References: <4317F071.1070403@yahoo.com.au> <4317F0F9.1080602@yahoo.com.au>
	<4317F136.4040601@yahoo.com.au>
	<1125666486.30867.11.camel@localhost.localdomain>
From: Andi Kleen <ak@suse.de>
Date: 02 Sep 2005 22:41:31 +0200
In-Reply-To: <1125666486.30867.11.camel@localhost.localdomain>
Message-ID: <p73k6hzqk1w.fsf@verdi.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Linux Memory Management <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Alan Cox <alan@lxorguk.ukuu.org.uk> writes:

> On Gwe, 2005-09-02 at 16:29 +1000, Nick Piggin wrote:
> > 2/7
> > Implement atomic_cmpxchg for i386 and ppc64. Is there any
> > architecture that won't be able to implement such an operation?
> 
> i386, sun4c, ....

Actually we have cmpxchg on i386 these days - we don't support
any SMP i386s so it's just done non atomically.
 
> Yeah quite a few. I suspect most MIPS also would have a problem in this
> area.

cmpxchg can be done with LL/SC can't it? Any MIPS should have that.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
