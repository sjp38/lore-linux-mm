Date: Mon, 14 May 2007 11:52:01 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/2] Have kswapd keep a minimum order free other than
 order-0
In-Reply-To: <20070514182456.GA9006@skynet.ie>
Message-ID: <Pine.LNX.4.64.0705141151330.11602@schroedinger.engr.sgi.com>
References: <20070514173218.6787.56089.sendpatchset@skynet.skynet.ie>
 <20070514173238.6787.57003.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0705141058590.11319@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0705141111400.11411@schroedinger.engr.sgi.com>
 <20070514182456.GA9006@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: apw@shadowen.org, nicolas.mailhot@laposte.net, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 14 May 2007, Mel Gorman wrote:

> On (14/05/07 11:13), Christoph Lameter didst pronounce:
> > I think the slub fragment may have to be this way? This calls 
> > raise_kswapd_order on each kmem_cache_create with the order of the cache 
> > that was created thus insuring that the min_order is correctly.
> > 
> > Signed-off-by: Christoph Lameter <clameter@sgi.com>
> > 
> 
> Good plan. Revised patch as follows;

Acked-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
