Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id CF3846B002C
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 05:47:06 -0400 (EDT)
Subject: RE: [PATCH] slub: remove a minus instruction in get_partial_node
From: "Alex,Shi" <alex.shi@intel.com>
In-Reply-To: <alpine.DEB.2.00.1110101210110.16264@router.home>
References: <1317290716.4188.1227.camel@debian>
	 <alpine.DEB.2.00.1109290917300.9382@router.home>
	 <6E3BC7F7C9A4BF4286DD4C043110F30B5FD97584A4@shsmsx502.ccr.corp.intel.com>
	 <alpine.DEB.2.00.1110030854270.9611@router.home>
	 <1318042113.27949.97.camel@debian>
	 <alpine.DEB.2.00.1110101210110.16264@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 11 Oct 2011 17:50:52 +0800
Message-ID: <1318326652.27949.725.camel@debian>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>, "Huang, Ying" <ying.huang@intel.com>

On Tue, 2011-10-11 at 01:11 +0800, Christoph Lameter wrote:
> On Sat, 8 Oct 2011, Alex,Shi wrote:
> 
> > On Mon, 2011-10-03 at 21:55 +0800, Christoph Lameter wrote:
> > > On Sun, 2 Oct 2011, Shi, Alex wrote:
> > >
> > > > > A slab on the partial lists always has objects available. Why would it be
> > > > > zero?
> > > >
> > > > Um, my mistaken. The reason should be: if code is here, the slab will be per cpu slab.
> > > > It is no chance to be in per cpu partial and no relationship with per cpu partial. So
> > > > no reason to use this value as a criteria for filling per cpu partial.
> > >
> > > I am not sure I understand you. The point of the code is to count the
> > > objects available in the per cpu partial pages so that we can limit the
> > > number of pages we fetch from the per node partial list.
> >
> > Maybe my understanding is incorrect for PCP. :)
> > What I thought is: when object == null, the page we got from node
> > partial list will be added into cpu slab. It has no chance to become per
> > cpu partial page. And it has no relationship with further per cpu
> > partial count checking. Since even 'available > cpu_partial/2', it
> > doesn't mean per cpu partial objects number > cpu_partial/2.
> 
> acquire_slab should not return NULL unless something seriously goes wrong.
> I think we can remove the]
> 
> 	if (!t)
> 
> statement to avoid futher confusion?

That is another story. 

Wondering if a page freeing by discard_slab impact this or not. I don't
fully understand the slub page alloc/free now, may study this later. :) 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
