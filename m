Date: Thu, 2 Sep 2004 05:05:06 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: Kernel 2.6.8.1: swap storm of death - nr_requests > 1024 on swap
 partition
In-Reply-To: <20040831172531.GA18184@logos.cnet>
Message-ID: <Pine.LNX.4.44.0409020502560.23477-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Karl Vogel <karl.vogel@seagha.com>, Andrew Morton <akpm@osdl.org>, karl.vogel@pandora.be, axboe@suse.de, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 31 Aug 2004, Marcelo Tosatti wrote:
> On Tue, Aug 31, 2004 at 08:24:31PM +0200, Karl Vogel wrote:
> > On Tuesday 31 August 2004 18:52, Marcelo Tosatti wrote:
> > > I've seen extreme decreases in performance (interactivity) with hungry
> > > memory apps with Rik's swap token code.
> > 
> > Decrease?!
> 
> Yep, its odd. Rik knows the exact reason.

Yes, it appears that the swap token patch works great on
systems where the workload consists of similar applications.
If you have a desktop, the swap token makes switching between
apps faster.  If you have a server, the swap token helps
increase throughput.

However, if you have one app that needs more memory than the
system has and the rest of the apps are all "friendly", then
the swap token can help the system hog steal resources from
the other processes.

This needs to be fixed somehow, but I'm at a conference now
so I don't think I'll get around to it this week ;)

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
