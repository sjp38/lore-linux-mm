Date: Tue, 4 Apr 2006 07:24:54 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 6/6] Swapless V1: Revise main migration logic
In-Reply-To: <20060404195820.4adc09d7.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0604040721460.26235@schroedinger.engr.sgi.com>
References: <20060404065739.24532.95451.sendpatchset@schroedinger.engr.sgi.com>
 <20060404065810.24532.30027.sendpatchset@schroedinger.engr.sgi.com>
 <20060404195820.4adc09d7.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, lee.schermerhorn@hp.com, lhms-devel@lists.sourceforge.net, taka@valinux.co.jp, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

On Tue, 4 Apr 2006, KAMEZAWA Hiroyuki wrote:

> >  	 */
> > -	if (!mapping || page_mapcount(page) + nr_refs != page_count(page))
> > -		return -EAGAIN;
> > +	if (!page->mapping ||
> > +		page_mapcount(page) + nr_refs + !!mapping != page_count(page))
> > +			return -EAGAIN;
> >  
> I think this hidden !!mapping refcnt is not easy to read.
> 
> How about modifying caller istead of callee ?
> 
> in migrate_page()
> ==
> if (page->mapping) 
> 	rc = migrate_page_remove_reference(newpage, page, 2)
> else
> 	rc = migrate_page_remove_reference(newpage, page, 1);
> ==
> 
> If you dislike this 'if', plz do as you like.

Good idea.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
