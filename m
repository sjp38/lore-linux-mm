Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D475D6B006C
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 03:39:57 -0500 (EST)
Date: Tue, 22 Nov 2011 00:39:54 -0800 (PST)
From: Christian Kujau <lists@nerdbynature.de>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
In-Reply-To: <1321948113.27077.24.camel@edumazet-laptop>
Message-ID: <alpine.DEB.2.01.1111220038060.8000@trent.utfs.org>
References: <20111121131531.GA1679@x4.trippels.de>   <1321884966.10470.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>   <20111121153621.GA1678@x4.trippels.de>   <1321890510.10470.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>   <20111121161036.GA1679@x4.trippels.de>
  <1321894353.10470.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>   <1321895706.10470.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>   <20111121173556.GA1673@x4.trippels.de>   <1321900743.10470.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  
 <20111121185215.GA1673@x4.trippels.de>  <20111121195113.GA1678@x4.trippels.de> <1321907275.13860.12.camel@pasglop>  <alpine.DEB.2.01.1111211617220.8000@trent.utfs.org>  <alpine.DEB.2.00.1111212105330.19606@router.home>
 <1321948113.27077.24.camel@edumazet-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>

On Tue, 22 Nov 2011 at 08:48, Eric Dumazet wrote:
> > --- linux-2.6.orig/mm/slub.c	2011-11-21 21:15:41.575673204 -0600
> > +++ linux-2.6/mm/slub.c	2011-11-21 21:16:33.442336849 -0600
> > @@ -1969,7 +1969,7 @@
> >  		page->pobjects = pobjects;
> >  		page->next = oldpage;
> > 
> > -	} while (this_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page) != oldpage);
> > +	} while (irqsafe_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page) != oldpage);
> >  	stat(s, CPU_PARTIAL_FREE);
> >  	return pobjects;
> >  }

Is this a patch to try for my PowerPC machine? With CONFIG_SLUB=y?

> For x86, I wonder if our !X86_FEATURE_CX16 support is correct on SMP
> machines.

I'm on UP, don't have any x68/SMP machines to test atm :(

Christian.
-- 
BOFH excuse #176:

vapors from evaporating sticky-note adhesives

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
