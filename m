Date: Tue, 12 Oct 2004 09:17:49 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [RFC] memory defragmentation to satisfy high order allocations
Message-ID: <20041012121749.GA10428@logos.cnet>
References: <20041012105657.D1D0670463@sv1.valinux.co.jp> <1509480000.1097591191@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1509480000.1097591191@[10.10.2.4]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: IWAMOTO Toshihiro <iwamoto@valinux.co.jp>, Hirokazu Takahashi <taka@valinux.co.jp>, haveblue@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 12, 2004 at 07:26:32AM -0700, Martin J. Bligh wrote:
> >> > iwamoto> I don't think requiring swap is a big deal.  If you don't have a
> >> > iwamoto> dedicated swap device, which case I think unusual, you can swapon a
> >> > iwamoto> regular file.
> >> 
> >> Sure its not a big deal, but nicer if it doesnt require swap.
> > 
> >> For memory defragmentation it is a big deal.
> > 
> > Why?  IMO, it isn't very rewarding to tune memory
> > migration/defragmentation performance as they involve memory copy
> > anyway.
> > 
> > Or, do you want memory defragmentation everywhere, including embedded
> > systems?
> 
> Lots of systems nowadays don't have swap configured, not just embedded.
> What do we gain from making defrag slower and harder to use, by forcing
> it to use swap? Isn't pushing it into the swapcache sufficient?

Hi Martin,

Yes pushing it to swapcache is sufficient - but doing so requires swap
map space (the "index" for swapcache pages is retrieved from swap map space 
position).

As I posted in the other message I'm working on a idr-based cache (migration cache)
which should solve things.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
