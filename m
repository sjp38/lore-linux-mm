Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A086E6006F5
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 14:10:36 -0400 (EDT)
Subject: Re: [PATCH v4 08/12] Inject asynchronous page fault into a guest
 if page is swapped out.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1278612561.1900.170.camel@laptop>
References: <1278433500-29884-1-git-send-email-gleb@redhat.com>
	 <1278433500-29884-9-git-send-email-gleb@redhat.com>
	 <20100708155920.GA13855@amt.cnet>  <20100708180525.GA11885@redhat.com>
	 <1278612561.1900.170.camel@laptop>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 08 Jul 2010 20:10:31 +0200
Message-ID: <1278612631.1900.171.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 2010-07-08 at 20:09 +0200, Peter Zijlstra wrote:
> On Thu, 2010-07-08 at 21:05 +0300, Gleb Natapov wrote:
> > > > +   /* do alloc atomic since if we are going to sleep anyway we
> > > > +      may as well sleep faulting in page */
> > > > +   work =3D kmem_cache_zalloc(async_pf_cache, GFP_ATOMIC);
> > > > +   if (!work)
> > > > +           return 0;
> > >=20
> > > GFP_KERNEL is fine for this context.
> > But it can sleep, no? The comment explains why I don't want to sleep
> > here.=20
>=20
> In that case, use 0, no use wasting __GFP_HIGH on something that doesn't
> actually need it.

Ah, I just saw we have GFP_NOWAIT for that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
