Date: Tue, 17 Jan 2006 22:38:03 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [RFC] Additional features for zone reclaim
In-Reply-To: <43CDBCBF.8080309@yahoo.com.au>
Message-ID: <Pine.LNX.4.62.0601172237390.30858@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0601171507580.28915@schroedinger.engr.sgi.com>
 <43CDBCBF.8080309@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: ak@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 18 Jan 2006, Nick Piggin wrote:

> Christoph Lameter wrote:
> > This patch adds the ability to shrink the cache if a zone runs out of
> > memory or to start swapping out pages on a node. The slab shrink
> > has some issues since it is global and not related to the zone.
> > One could add support for zone specifications to the shrinker to
> > make that work. Got a patch halfway done that would modify all
> > shrinkers to take an additional zone parameters. But is that worth it?
> > 
> 
> I have a patch somewhere that does that. Never worked out if it
> was worth it or not.

Could you sent it to me? Maybe it can save me some work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
