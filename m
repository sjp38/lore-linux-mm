Date: Thu, 7 Jun 2007 22:58:57 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: memory unplug v4  [2/6] lru isolation race fix
In-Reply-To: <20070608145818.980ec5b4.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0706072257550.28618@schroedinger.engr.sgi.com>
References: <20070608143531.411c76df.kamezawa.hiroyu@jp.fujitsu.com>
 <20070608143953.93719b3e.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0706072248310.28618@schroedinger.engr.sgi.com>
 <20070608145818.980ec5b4.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Fri, 8 Jun 2007, KAMEZAWA Hiroyuki wrote:

> > Use get_page_unless_zero?
> > 
> Oh, its better macro. thank you.
> 
> Then, the whole code will be....
> ==
>  		if (PageLRU(page)) {
>                         if (get_page_unless_zero(page)) {

		if (PageLRU(page) && get_page_unless_zero(page))

but I am nit picking...

> 				ret = 0;
> 	                        ClearPageLRU(page);
>         	                if (PageActive(page))
>                 	                del_page_from_active_list(zone, page);
>                         	else
>                                 	del_page_from_inactive_list(zone, page);
>                         	list_add_tail(&page->lru, pagelist);
>                 	}
> 		}
> ==
> Is this ok ?

Looks better. But it will have to pass by Hugh too I guess...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
