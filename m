Received: by ug-out-1314.google.com with SMTP id c2so1099975ugf
        for <linux-mm@kvack.org>; Sun, 29 Jul 2007 10:52:12 -0700 (PDT)
Message-ID: <2c0942db0707291052r79bed95fv30ed6c3badf21338@mail.gmail.com>
Date: Sun, 29 Jul 2007 10:52:12 -0700
From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans for 2.6.23]
In-Reply-To: <46ACCF7A.1080207@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
	 <46AC9F2C.8090601@gmail.com>
	 <2c0942db0707290758p39fef2e8o68d67bec5c7ba6ab@mail.gmail.com>
	 <46ACAB45.6080307@gmail.com>
	 <2c0942db0707290820r2e31f40flb51a43846169a752@mail.gmail.com>
	 <46ACB40C.2040908@gmail.com>
	 <2c0942db0707290904n4356582dt91ab96b77db1e84e@mail.gmail.com>
	 <46ACC76A.3080303@gmail.com>
	 <2c0942db0707291019q14f309d0jab3bf083aa37d707@mail.gmail.com>
	 <46ACCF7A.1080207@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@gmail.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, david@lang.hm, Daniel Hazelton <dhazelton@enter.net>, Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 7/29/07, Rene Herman <rene.herman@gmail.com> wrote:
> On 07/29/2007 07:19 PM, Ray Lee wrote:
> For me, it is generally the case yes. We are still discussing this in the
> context of desktop machines and their problems with being slow as things
> have been swapped out and generally I expect a desktop to have plenty of
> swap which it's not regularly going to fillup significantly since then the
> machine's unworkably slow as a desktop anyway.

<Shrug> Well, that doesn't match my systems. My laptop has 400MB in swap:

ray@phoenix:~$ free
             total       used       free     shared    buffers     cached
Mem:        894208     883920      10288          0       3044     163224
-/+ buffers/cache:     717652     176556
Swap:      1116476     393132     723344

> > And once there's something already in swap, you now have a packing
> > problem when you want to swap something else out.
>
> Once we're crammed, it gets to be a different situation yes. As far as I'm
> concerned that's for another thread though. I'm spending too much time on
> LKML as it is...

No, it's not even when crammed. It's just when there are holes.
mm/swapfile.c does try to cluster things, but doesn't work too hard at
it as we don't want to spend all our time looking for a perfect fit
that may not exist.

Ray

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
