Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id AD8326B005D
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 05:59:29 -0400 (EDT)
Date: Thu, 6 Aug 2009 17:59:05 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <20090806095905.GA30410@localhost>
References: <20090805024058.GA8886@localhost> <4A79C70C.6010200@redhat.com> <9EECC02A4CC333418C00A85D21E89326B651C1FE@azsmsx502.amr.corp.intel.com> <4A79D88E.2040005@redhat.com> <9EECC02A4CC333418C00A85D21E89326B651C21C@azsmsx502.amr.corp.intel.com> <4A7AA0CF.2020700@redhat.com> <20090806092516.GA18425@localhost> <4A7AA3FF.9070808@redhat.com> <20090806093507.GA24669@localhost> <4A7AA999.8050309@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A7AA999.8050309@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, Rik van Riel <riel@redhat.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 06, 2009 at 05:59:53PM +0800, Avi Kivity wrote:
> On 08/06/2009 12:35 PM, Wu Fengguang wrote:
> > On Thu, Aug 06, 2009 at 05:35:59PM +0800, Avi Kivity wrote:
> >    
> >> On 08/06/2009 12:25 PM, Wu Fengguang wrote:
> >>      
> >>>> So you're effectively running a 256M guest on a 128M host?
> >>>>
> >>>> Do cgroups have private active/inactive lists?
> >>>>
> >>>>          
> >>> Yes, and they reuse the same page reclaim routines with the global
> >>> LRU lists.
> >>>
> >>>        
> >> Then this looks like a bug in the shadow accessed bit handling.
> >>      
> >
> > Yes. One question is: why only stack pages hurts if it is a
> > general page reclaim problem?
> >    
> 
> Do we know for a fact that only stack pages suffer, or is it what has 
> been noticed?

It shall be the first case: "These pages are nearly all stack pages.",
Jeff said.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
