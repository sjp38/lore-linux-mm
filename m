Date: Tue, 31 Aug 2004 13:52:50 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: Kernel 2.6.8.1: swap storm of death - nr_requests > 1024 on swap partition
Message-ID: <20040831165250.GD11149@logos.cnet>
References: <20040829141718.GD10955@suse.de> <20040830165100.535e68e5.akpm@osdl.org> <20040831102342.GA3207@logos.cnet> <200408311950.09641.karl.vogel@seagha.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200408311950.09641.karl.vogel@seagha.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Karl Vogel <karl.vogel@seagha.com>
Cc: Andrew Morton <akpm@osdl.org>, karl.vogel@pandora.be, axboe@suse.de, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 31, 2004 at 07:50:07PM +0200, Karl Vogel wrote:
> On Tuesday 31 August 2004 12:23, Marcelo Tosatti wrote:
> > On Mon, Aug 30, 2004 at 04:51:00PM -0700, Andrew Morton wrote:
> > > Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
> > > > What you think of this, which tries to address your comments
> > >
> > > Suggest you pass the scan_control structure down into pageout(), stick
> > > `inflight' into struct scan_control and use some flag in scan_control to
> >
> > Done the scan_control modifications.
> 
> Took the patch for a spin.. it seems to behave ok here! No more OOMs.
> 
> Quick question: is it to be expected that when I run a calloc(500Mb) on my 
> system, when X is up and amarok is streaming live audio, that everything 
> (apps) freezes for a few seconds until the calloc task exits?!
> The apps probably get pushed out to swap, but I would think that since these 
> applications are running, that their pages are kept on the active list?! 
> Setting swappiness to 0 doesn't make a difference.
> 
> Is there a concept of a minimum working set size of an application? (kind of 
> the reverse of an RSS limit)

Not really. A hungry memory app can starve the rest of the system. 

One thing: what kernel version are you using? 

I've seen extreme decreases in performance (interactivity) with hungry memory apps 
with Rik's swap token code.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
