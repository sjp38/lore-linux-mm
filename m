Date: Fri, 11 May 2007 10:09:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] memory hotremove patch take 2 [01/10] (counter of
 removable page)
Message-Id: <20070511100947.470a764d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0705101058260.10002@schroedinger.engr.sgi.com>
References: <20070509115506.B904.Y-GOTO@jp.fujitsu.com>
	<20070509120132.B906.Y-GOTO@jp.fujitsu.com>
	<Pine.LNX.4.64.0705101058260.10002@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: y-goto@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Thu, 10 May 2007 11:00:31 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Wed, 9 May 2007, Yasunori Goto wrote:
> 
> >  
> > +unsigned int nr_free_movable_pages(void)
> > +{
> > +	unsigned long nr_pages = 0;
> > +	struct zone *zone;
> > +	int nid;
> > +
> > +	for_each_online_node(nid) {
> > +		zone = &(NODE_DATA(nid)->node_zones[ZONE_MOVABLE]);
> > +		nr_pages += zone_page_state(zone, NR_FREE_PAGES);
> > +	}
> > +	return nr_pages;
> > +}
> 
> 
> Hmmmm... This is redoing what the vm counters already provide
> 
> Could you add
> 
> NR_MOVABLE_PAGES etc.
> 
> instead and then let the ZVC counter logic take care of the rest?
> 
Okay, we'll try ZVC.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
