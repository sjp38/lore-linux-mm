Date: Thu, 18 May 2006 11:41:01 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Query re:  mempolicy for page cache pages
In-Reply-To: <1147976994.5195.123.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0605181139030.20956@schroedinger.engr.sgi.com>
References: <1147974599.5195.96.camel@localhost.localdomain>
 <200605182012.19570.ak@suse.de> <1147976994.5195.123.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andi Kleen <ak@suse.de>, linux-mm <linux-mm@kvack.org>, Steve Longerbeam <stevel@mvista.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Thu, 18 May 2006, Lee Schermerhorn wrote:

> Yes, for not overburdening any single node.  Paul Jackson's 
> "spread" patches address this.  Actually, for [some of] our platforms,
> we can hardware interleave some % of memory at the cache line level.
> This shows up as a memory-only node.  Some folks claim it would be
> beneficial to be able to specify a page cache policy to prefer this
> hardware interleaved node for the page cache.   I see that Ray
> Bryant once proposed a patch to define a separate global and 
> optional per process policy to be used for page cache pages. This
> also "died on the vine"...

I'd be very interested in some scheme to address the overburdening in a 
simple way. Replication may be useful in addition to spreading to limit 
the traffic on the NUMA interlink.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
