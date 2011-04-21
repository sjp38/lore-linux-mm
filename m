Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 893908D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 18:31:35 -0400 (EDT)
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <alpine.DEB.2.00.1104211517150.20201@chino.kir.corp.google.com>
References: <20110420102314.4604.A69D9226@jp.fujitsu.com>
	 <BANLkTi=mxWwLPEnB+rGg29b06xNUD0XvsA@mail.gmail.com>
	 <20110420161615.462D.A69D9226@jp.fujitsu.com>
	 <BANLkTimfpY3gq8oY6bPDajBW7JN6Hp+A0A@mail.gmail.com>
	 <20110420112020.GA31296@parisc-linux.org>
	 <BANLkTim+m-v-4k17HUSOYSbmNFDtJTgD6g@mail.gmail.com>
	 <1303308938.2587.8.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104200943580.9266@router.home>
	 <1303311779.2587.19.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104201018360.9266@router.home>
	 <alpine.DEB.2.00.1104201437180.31768@chino.kir.corp.google.com>
	 <1303401997.4025.8.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104211517150.20201@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 21 Apr 2011 17:31:31 -0500
Message-ID: <1303425091.4025.59.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Matthew Wilcox <matthew@wil.cx>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>, linux-arch@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>

On Thu, 2011-04-21 at 15:19 -0700, David Rientjes wrote:
> On Thu, 21 Apr 2011, James Bottomley wrote:
> 
> > diff --git a/mm/slub.c b/mm/slub.c
> > index 94d2a33..243bd9c 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -235,7 +235,11 @@ int slab_is_available(void)
> >  
> >  static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
> >  {
> > +#ifdef CONFIG_NUMA
> >  	return s->node[node];
> > +#else
> > +	return s->node[0];
> > +#endif
> >  }
> >  
> >  /* Verify that a pointer has an address that is valid within a slab page */
> 
> Looks like parisc may have been just fine before 7340cc84141d (slub: 
> reduce differences between SMP and NUMA), which was merged into 2.6.37?

That's possible.  I've had no bug reports from the debian 2.6.32 kernel,
which is the only other one that has SLUB by default.  The m68k guys
seem to think this is the cause of their problems too.

But the basic fact is that all our testing has been done on SLAB.  It
wasn't until debian asked us to looks at a 2.6.38 kernel that I
accidentally picked up SLUB by importing their config into my build
environment.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
