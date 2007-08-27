Date: Mon, 27 Aug 2007 13:15:10 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC]  Add node 'states' sysfs class attribute
In-Reply-To: <1188245333.5952.84.camel@localhost>
Message-ID: <Pine.LNX.4.64.0708271313570.5692@schroedinger.engr.sgi.com>
References: <200708242228.l7OMS5fU017948@imap1.linux-foundation.org>
 <1188236904.5952.72.camel@localhost>  <Pine.LNX.4.64.0708271203170.4667@schroedinger.engr.sgi.com>
 <1188245333.5952.84.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, mel@skynet.ie, y-goto@jp.fujitsu.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Aug 2007, Lee Schermerhorn wrote:

> > Yes that is important for software that wants to allocate per node 
> > structures. The possible mask shows which nodes could be activated later.
> 
> Good point.  Given that, I'm thinking we might want to limit the
> displayed masks--even the internal value of the mask--to something
> closer to what a particular platform architecture can support, even tho'
> the kernel might be configured for a much larger number.  I'll have to
> look into how to do this.

It is the responsibility of the arch code to set this up the right 
way AFAIK.

> > Leading words of all zeroes? nodemask_scnprintf calls bitmap_scnprintf(). 
> > Maybe it should call bitmap_scnlistprintf() instead?
> 
> For platforms with small numbers of possible nodes, that might look
> nicer.  

For large platforms this will avoid long node lists that warp around. So 
lets do it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
