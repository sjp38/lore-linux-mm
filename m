Date: Tue, 11 Sep 2007 17:25:59 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH -mm] mm: Fix memory hotplug + sparsemem build.
Message-ID: <20070911082559.GA19732@linux-sh.org>
References: <20070911072507.GB19260@linux-sh.org> <20070911170921.F137.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070911170921.F137.Y-GOTO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Goto-san,

On Tue, Sep 11, 2007 at 05:18:01PM +0900, Yasunori Goto wrote:
> >  	if (onlined_pages)
> > -		node_set_state(zone->node, N_HIGH_MEMORY);
> > +		node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
> >  
> >  	setup_per_zone_pages_min();
> 
> Thanks Paul-san. 
> 
> I also have another issue around here.
> (Kswapd doesn't run on memory less node now. It should run when
>  the node has memory.)
> 
> I would like to merge them like following if you don't mind.
> 
Looks fine to me!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
