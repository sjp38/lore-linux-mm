Received: from krystal.dyndns.org ([76.65.100.197])
          by tomts43-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20070709214427.RSBR5730.tomts43-srv.bellnexxia.net@krystal.dyndns.org>
          for <linux-mm@kvack.org>; Mon, 9 Jul 2007 17:44:27 -0400
Date: Mon, 9 Jul 2007 17:44:26 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [patch 00/10] [RFC] SLUB patches for more functionality, performance and maintenance
Message-ID: <20070709214426.GC1026@Krystal>
References: <20070708034952.022985379@sgi.com> <p73y7hrywel.fsf@bingen.suse.de> <Pine.LNX.4.64.0707090845520.13792@schroedinger.engr.sgi.com> <46925B5D.8000507@google.com> <Pine.LNX.4.64.0707091055090.16207@schroedinger.engr.sgi.com> <4692A1D0.50308@mbligh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: 8BIT
In-Reply-To: <4692A1D0.50308@mbligh.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Bligh <mbligh@mbligh.org>
Cc: Christoph Lameter <clameter@sgi.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

* Martin Bligh (mbligh@mbligh.org) wrote:
> Christoph Lameter wrote:
> >On Mon, 9 Jul 2007, Martin Bligh wrote:
> >
> >>Those numbers came from Mathieu Desnoyers (LTTng) if you
> >>want more details.
> >
> >Okay the source for these numbers is in his paper for the OLS 2006: Volume 
> >1 page 208-209? I do not see the exact number that you referred to there.
> 

Hrm, the reference page number is wrong: it is in OLS 2006, Vol. 1 page
216 (section 4.5.2 Scalability). I originally pulled out the page number
from my local paper copy. oops.


> Nope, he was a direct co-author on the paper, was
> working here, and measured it.
> 
> >He seems to be comparing spinlock acquire / release vs. cmpxchg. So I 
> >guess you got your material from somewhere else?
> >

I ran a test specifically for this paper where I got this result
comparing the local irq enable/disable to local cmpxchg.

> >Also the cmpxchg used there is the lockless variant. cmpxchg 29 cycles w/o 
> >lock prefix and 112 with lock prefix.

Yep, I volountarily used the variant without lock prefix because the
data is per cpu and I disable preemption.

> >
> >I see you reference another paper by Desnoyers: 
> >http://tree.celinuxforum.org/CelfPubWiki/ELC2006Presentations?action=AttachFile&do=get&target=celf2006-desnoyers.pdf
> >
> >I do not see anything relevant there. Where did those numbers come from?
> >
> >The lockless cmpxchg is certainly an interesting idea. Certain for some 
> >platforms I could disable preempt and then do a lockless cmpxchg.
> 

Yes, preempt disabling or, eventually, the new thread migration
disabling I just proposed as an RFC on LKML. (that would make -rt people
happier)

> Mathieu, can you give some more details? Obviously the exact numbers
> will vary by archicture, machine size, etc, but it's a good point
> for discussion.
> 

Sure, also note that the UP cmpxchg (see asm-$ARCH/local.h in 2.6.22) is
faster on architectures like powerpc and MIPS where it is possible to
remove some memory barriers.

See 2.6.22 Documentation/local_ops.txt for a thorough discussion. Don't
hesitate ping me if you have more questions.

Regards,

Mathieu


-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
