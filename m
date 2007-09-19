Date: Wed, 19 Sep 2007 13:54:56 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 3/8] oom: save zonelist pointer for oom killer calls
In-Reply-To: <alpine.DEB.0.9999.0709191330520.26978@chino.kir.corp.google.com>
Message-ID: <Pine.LNX.4.64.0709191353440.3136@schroedinger.engr.sgi.com>
References: <alpine.DEB.0.9999.0709181950170.25510@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190350001.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190350240.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190350410.23538@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709191204590.2241@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709191330520.26978@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, 19 Sep 2007, David Rientjes wrote:

> On Wed, 19 Sep 2007, Christoph Lameter wrote:
> 
> > Still think that a simple flag in the zone would be much easier to realize 
> > and would avoid the kzalloc.
> > 
> 
> That would require another member to be added to struct zone, probably a 
> spinlock_t that we would use as a spin_trylock() when in 
> try_set_zone_oom().

> Or we could, as you mentioned before, turn all_unreclaimable into an 
> unsigned long and use it to set various bits.  That works pretty nicely.
> 
> I'm wondering if this OOM killer serialization is going to end up as a 
> config option, though.

Are there any reasons not to serialize the OOM killer per zone?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
