Date: Tue, 9 Nov 2004 21:34:07 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] kswapd shall not sleep during page shortage
Message-ID: <20041109233407.GF8414@logos.cnet>
References: <20041109164642.GE7632@logos.cnet> <20041109121945.7f35d104.akpm@osdl.org> <20041109174125.GF7632@logos.cnet> <20041109133343.0b34896d.akpm@osdl.org> <20041109182622.GA8300@logos.cnet> <20041109142257.1d1411e1.akpm@osdl.org> <20041109203143.GC8414@logos.cnet> <20041109162801.7f7ca242.akpm@osdl.org> <20041109231654.GE8414@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041109231654.GE8414@logos.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>

On Tue, Nov 09, 2004 at 09:16:54PM -0200, Marcelo Tosatti wrote:
> On Tue, Nov 09, 2004 at 04:28:01PM -0800, Andrew Morton wrote:
> > Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
> > >
> > > Back to arguing in favour of my patch - it seemed to me that kswapd could 
> > >  go to sleep leaving allocators which can't reclaim pages themselves in a 
> > >  bad situation. 
> > 
> > Yes, but those processes would be sleeping in blk_congestion_wait() during,
> > say, a GFP_NOIO/GFP_NOFS allocation attempt. 
> 
> I was thinking about interrupts when I mentioned "allocators which can't reclaim 
> pages" :)
> 
> > And in that case, they may be
> > holding locks whcih prevent kswapd from being able to do any work either.
> 
> OK... Just out of curiosity:
> Isnt the "lock contention" at this level (filesystem) a relatively rare situation? 
> 
> It could be a NFS lock for example? What other kind of lock?

Rather stupid question - filesystem internal locks like i_sem - 
not NFS locks.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
