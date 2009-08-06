Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 565356B005A
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 05:25:22 -0400 (EDT)
Date: Thu, 6 Aug 2009 17:25:16 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <20090806092516.GA18425@localhost>
References: <20090805024058.GA8886@localhost> <4A79C70C.6010200@redhat.com> <9EECC02A4CC333418C00A85D21E89326B651C1FE@azsmsx502.amr.corp.intel.com> <4A79D88E.2040005@redhat.com> <9EECC02A4CC333418C00A85D21E89326B651C21C@azsmsx502.amr.corp.intel.com> <4A7AA0CF.2020700@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A7AA0CF.2020700@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, Rik van Riel <riel@redhat.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 06, 2009 at 05:22:23PM +0800, Avi Kivity wrote:
> On 08/05/2009 10:18 PM, Dike, Jeffrey G wrote:
> >> How did you create that 128M memory compartment?
> >>
> >> Did you use cgroups on the host system?
> >>      
> >
> > Yup.
> >
> >    
> >> How much memory do you give your virtual machine?
> >>
> >> That is, how much memory does it think it has?
> >>      
> >
> > 256M.
> >    
> 
> So you're effectively running a 256M guest on a 128M host?
> 
> Do cgroups have private active/inactive lists?

Yes, and they reuse the same page reclaim routines with the global
LRU lists.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
