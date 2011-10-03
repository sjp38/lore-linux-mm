Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B097A9000DF
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 09:55:32 -0400 (EDT)
Date: Mon, 3 Oct 2011 08:55:29 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: RE: [PATCH] slub: remove a minus instruction in get_partial_node
In-Reply-To: <6E3BC7F7C9A4BF4286DD4C043110F30B5FD97584A4@shsmsx502.ccr.corp.intel.com>
Message-ID: <alpine.DEB.2.00.1110030854270.9611@router.home>
References: <1317290716.4188.1227.camel@debian> <alpine.DEB.2.00.1109290917300.9382@router.home> <6E3BC7F7C9A4BF4286DD4C043110F30B5FD97584A4@shsmsx502.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Alex" <alex.shi@intel.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>, "Huang, Ying" <ying.huang@intel.com>

On Sun, 2 Oct 2011, Shi, Alex wrote:

> > A slab on the partial lists always has objects available. Why would it be
> > zero?
>
> Um, my mistaken. The reason should be: if code is here, the slab will be per cpu slab.
> It is no chance to be in per cpu partial and no relationship with per cpu partial. So
> no reason to use this value as a criteria for filling per cpu partial.

I am not sure I understand you. The point of the code is to count the
objects available in the per cpu partial pages so that we can limit the
number of pages we fetch from the per node partial list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
