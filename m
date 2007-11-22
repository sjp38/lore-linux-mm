Date: Thu, 22 Nov 2007 12:37:41 -0500
From: Marcelo Tosatti <marcelo@kvack.org>
Subject: Re: [PATCH] mem notifications v2
Message-ID: <20071122173741.GA4990@dmt>
References: <20071121195316.GA21481@dmt> <20071122114532.E9E1.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071122114532.E9E1.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kosaki <kosaki.motohiro@jp.fujitsu.com>
Cc: Marcelo Tosatti <marcelo@kvack.org>, linux-mm@kvack.org, Daniel =?utf-8?B?U3DomqNn?= <daniel.spang@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 22, 2007 at 12:07:32PM +0900, kosaki wrote:
> Hi Marcelo,
> 
> I am interesting your patch.
> 
> and I have some stupid question.
> please tell me.
> 
> 
> >  static struct class *mem_class;
> > --- linux-2.6.24-rc2-mm1.orig/include/linux/swap.h	2007-11-14 23:51:28.000000000 -0200
> > +++ linux-2.6.24-rc2-mm1/include/linux/swap.h	2007-11-21 15:40:23.000000000 -0200
> > @@ -169,6 +169,8 @@
> >  /* Definition of global_page_state not available yet */
> >  #define nr_free_pages() global_page_state(NR_FREE_PAGES)
> >  
> > +#define total_anon_pages() (global_page_state(NR_ANON_PAGES) \
> > +			    + total_swap_pages - total_swapcache_pages)
> 
> Why you use total_swap_pages?
> Are your intent watching swapon/spwapoff syscall? 
> 
> or, s/total_swapcache_pages/nr_swap_pages/ ?

Oops.

total_anon_pages() is supposed to return the total number of anonymous pages
(including swapped out ones), so that should be: 

#define total_anon_pages() (global_page_state(NR_ANON_PAGES) + \
                           (total_swap_pages-nr_swap_pages)  - \
                            total_swapcache_pages

> > @@ -1199,7 +1208,7 @@
> >  	throttle_vm_writeout(sc->gfp_mask);
> >  	return nr_reclaimed;
> >  }
> > -
> > + 
> >  /*
> >   * This is the direct reclaim path, for page-allocating processes.  We only
> >   * try to reclaim pages from zones which will satisfy the caller's allocation
> 
> cut here, please.

Fixed, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
