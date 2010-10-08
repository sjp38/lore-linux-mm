Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 88CC26B0089
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 14:06:27 -0400 (EDT)
Date: Fri, 8 Oct 2010 12:56:03 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [resend][PATCH] mm: increase RECLAIM_DISTANCE to 30
In-Reply-To: <20101008165930.GH5327@balbir.in.ibm.com>
Message-ID: <alpine.DEB.2.00.1010081255010.32749@router.home>
References: <20101008104852.803E.A69D9226@jp.fujitsu.com> <20101008090427.GB5327@balbir.in.ibm.com> <alpine.DEB.2.00.1010081044530.30029@router.home> <20101008165930.GH5327@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Rob Mueller <robm@fastmail.fm>, linux-kernel@vger.kernel.org, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 8 Oct 2010, Balbir Singh wrote:

> * Christoph Lameter <cl@linux.com> [2010-10-08 10:45:16]:
>
> > On Fri, 8 Oct 2010, Balbir Singh wrote:
> >
> > > I am not sure if this makes sense, since RECLAIM_DISTANCE is supposed
> > > to be a hardware parameter. Could you please help clarify what the
> > > access latency of a node with RECLAIM_DISTANCE 20 to that of a node
> > > with RECLAIM_DISTANCE 30 is? Has the hardware definition of reclaim
> > > distance changed?
> >
> > 10 is the local distance. So 30 should be 3x the latency that a local
> > access takes.
> >
>
> Does this patch then imply that we should do zone_reclaim only for 3x
> nodes and not 2x nodes as we did earlier.

It implies that zone reclaim is going to be automatically enabled if the
maximum latency to the memory farthest away is 3 times or more that of a
local memory access.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
