Date: Tue, 3 Jun 2008 04:34:20 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 3/5] x86: lockless get_user_pages_fast
Message-ID: <20080603023419.GC5527@wotan.suse.de>
References: <20080529122050.823438000@nick.local0.net> <20080529122602.330656000@nick.local0.net> <1212081659.6308.10.camel@norville.austin.ibm.com> <20080602101530.GA7206@wotan.suse.de> <20080602212833.226146bc.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080602212833.226146bc.sfr@canb.auug.org.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Dave Kleikamp <shaggy@linux.vnet.ibm.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 02, 2008 at 09:28:33PM +1000, Stephen Rothwell wrote:
> Hi Nick,
> 
> On Mon, 2 Jun 2008 12:15:30 +0200 Nick Piggin <npiggin@suse.de> wrote:
> >
> > BTW. I do plan to ask Linus to merge this as soon as 2.6.27 opens.
> > Hope nobody objects (or if they do please speak up before then)
> 
> Any chance of getting this into linux-next then to see if it
> conflicts with/kills anything else?
> 
> If this is posted/reviewed/tested enough to be "finished" then put it in
> a tree (or quilt series) and submit it.

Hi Stephen,

Thanks for the offer... I was hoping for Andrew to pick it up (which
he now has).

I'm not sure how best to do mm/ related stuff, but I suspect we have
gone as smoothly as we are in large part due to Andrew's reviewing
and martialling mm patches so well.

Not saying that wouldn't happen if the patches went to linux-next,
but I'm quite happy with how -mm works for mm development, so I will
prefer to submit to -mm unless Andrew asks otherwise.

For other developments I'll keep linux-next in mind. I guess it will
be useful for me eg in the case where I change an arch defined prototype
that requires a big sweep of the tree.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
