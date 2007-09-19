Date: Wed, 19 Sep 2007 14:20:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 3/8] oom: save zonelist pointer for oom killer calls
In-Reply-To: <Pine.LNX.4.64.0709191353440.3136@schroedinger.engr.sgi.com>
Message-ID: <alpine.DEB.0.9999.0709191416380.30290@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709181950170.25510@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190350001.23538@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190350240.23538@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190350410.23538@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709191204590.2241@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709191330520.26978@chino.kir.corp.google.com> <Pine.LNX.4.64.0709191353440.3136@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, 19 Sep 2007, Christoph Lameter wrote:

> > Or we could, as you mentioned before, turn all_unreclaimable into an 
> > unsigned long and use it to set various bits.  That works pretty nicely.
> > 
> > I'm wondering if this OOM killer serialization is going to end up as a 
> > config option, though.
> 
> Are there any reasons not to serialize the OOM killer per zone?
> 

That's what this current patchset does, yes.  I agree that it is probably 
better done with a bit in struct zone, however.

By changing all_unreclaimable to an unsigned long flags member of struct 
zone, we'll simply need to check_bit() on a new ZONE_OOM flag when we scan 
through the zonelist instead of checking for matching zones from those 
that we saved in try_set_zone_oom().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
