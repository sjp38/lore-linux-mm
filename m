Subject: Re: [-mm PATCH 4/8] Memory controller memory accounting (v2)
In-Reply-To: Your message of "Tue, 10 Jul 2007 14:11:18 +0530"
	<661de9470707100141h779e75eev9c09fdb2dfd09b8b@mail.gmail.com>
References: <661de9470707100141h779e75eev9c09fdb2dfd09b8b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20070710084427.3F74B1BF77E@siro.lan>
Date: Tue, 10 Jul 2007 17:44:27 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: svaidy@linux.vnet.ibm.com, akpm@linux-foundation.org, xemul@openvz.org, a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ebiederm@xmission.com, containers@lists.osdl.org, menage@google.com
List-ID: <linux-mm.kvack.org>

> On 7/10/07, YAMAMOTO Takashi <yamamoto@valinux.co.jp> wrote:
> > hi,
> >
> > > diff -puN mm/memory.c~mem-control-accounting mm/memory.c
> > > --- linux-2.6.22-rc6/mm/memory.c~mem-control-accounting       2007-07-05 13:45:18.000000000 -0700
> > > +++ linux-2.6.22-rc6-balbir/mm/memory.c       2007-07-05 13:45:18.000000000 -0700
> >
> > > @@ -1731,6 +1736,9 @@ gotten:
> > >               cow_user_page(new_page, old_page, address, vma);
> > >       }
> > >
> > > +     if (mem_container_charge(new_page, mm))
> > > +             goto oom;
> > > +
> > >       /*
> > >        * Re-check the pte - we dropped the lock
> > >        */
> >
> > it seems that the page will be leaked on error.
> 
> You mean meta_page right?

no.  i meant 'new_page'.

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
