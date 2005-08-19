Message-Id: <200508191304.j7JD4utA010195@laptop11.inf.utfsm.cl>
Subject: Re: [PATCH/RFT 4/5] CLOCK-Pro page replacement 
In-Reply-To: Message from Rusty Russell <rusty@rustcorp.com.au>
   of "Fri, 19 Aug 2005 17:27:06 +1000." <1124436426.23757.5.camel@localhost.localdomain>
Date: Fri, 19 Aug 2005 09:04:56 -0400
From: Horst von Brand <vonbrand@inf.utfsm.cl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Andrew Morton <akpm@osdl.org>, davem@davemloft.net, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rusty Russell <rusty@rustcorp.com.au> wrote:
> On Fri, 2005-08-19 at 00:10 -0700, Andrew Morton wrote:
> > Rusty Russell <rusty@rustcorp.com.au> wrote:
> > > I believe we just ignored sparc64.  That usually works for solving these
> > > kind of bugs. 8)
> > 
> > heh.  iirc, it was demonstrable on x86 also.
> 
> No.  gcc-2.95 on Sparc64 put uninititialized vars into the bss, ignoring
> the __attribute__((section(".data.percpu"))) directive.  x86 certainly
> doesn't have this, I just tested it w/2.95.
> 
> Really, it's Sparc64 + gcc-2.95.  Send an urgent telegram to the user
> telling them to upgrade.

I recently asked if gcc-2.95 was really still supported, and was told that
it is in common use for its speed...
-- 
Dr. Horst H. von Brand                   User #22616 counter.li.org
Departamento de Informatica                     Fono: +56 32 654431
Universidad Tecnica Federico Santa Maria              +56 32 654239
Casilla 110-V, Valparaiso, Chile                Fax:  +56 32 797513
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
