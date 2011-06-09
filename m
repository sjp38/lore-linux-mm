Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6BAE26B0078
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 08:56:50 -0400 (EDT)
Date: Thu, 9 Jun 2011 13:56:42 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 10/14] netvm: Set PF_MEMALLOC as appropriate during SKB
 processing
Message-ID: <20110609125642.GS5247@suse.de>
References: <1307606573-24704-1-git-send-email-mgorman@suse.de>
 <1307606573-24704-11-git-send-email-mgorman@suse.de>
 <BANLkTimUE9yb-DegdUk0BbbOGWoUhEBrqw@mail.gmail.com>
 <20110609113505.GR5247@suse.de>
 <BANLkTi=8jx8B8fR_+Z76UoTe_jhG9G-Tyw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTi=8jx8B8fR_+Z76UoTe_jhG9G-Tyw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Micha? Miros?aw <mirqus@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Thu, Jun 09, 2011 at 02:28:24PM +0200, Micha? Miros?aw wrote:
> 2011/6/9 Mel Gorman <mgorman@suse.de>:
> > On Thu, Jun 09, 2011 at 12:21:31PM +0200, Micha? Miros?aw wrote:
> >> 2011/6/9 Mel Gorman <mgorman@suse.de>:
> >> [...]
> >> > +/*
> >> > + * Limit which protocols can use the PFMEMALLOC reserves to those that are
> >> > + * expected to be used for communication with swap.
> >> > + */
> >> > +static bool skb_pfmemalloc_protocol(struct sk_buff *skb)
> >> > +{
> >> > +       switch (skb->protocol) {
> >> > +       case __constant_htons(ETH_P_ARP):
> >> > +       case __constant_htons(ETH_P_IP):
> >> > +       case __constant_htons(ETH_P_IPV6):
> >> > +       case __constant_htons(ETH_P_8021Q):
> >> > +               return true;
> >> > +       default:
> >> > +               return false;
> >> > +       }
> >> > +}
> >>
> >> This is not needed and wrong. Whatever list there will be, it's going
> >> to always miss some obscure setup (or not that obscure, like
> >> ATAoverEthernet).
> >>
> >
> > NBD is updated in the series to set the socket information
> > appropriately but the same cannot be said of AoE. The necessary
> > changes have been made IPv4 and IPv6 to handle pfmemalloc sockets
> > but the same cannot be necessarily said for the other protocols. Yes,
> > the check could be removed but leaving it there makes a clear statement
> > on what scenario can be reasonably expected to work.
> 
> Ok. Then the comment before skb_pfmemalloc_protocol() is misleading.
> It should say that this is a list of protocols which implement the
> required special handling of PFMEMALLOC skbs.
> 

That's a very reasonable suggestion. My thinking behind that comment
was a backwards because I only "expected" protocols that implemented
the special handling to be used for swap :/

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
