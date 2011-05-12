Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 25A9B900001
	for <linux-mm@kvack.org>; Thu, 12 May 2011 15:58:56 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p4CJwrAG005497
	for <linux-mm@kvack.org>; Thu, 12 May 2011 12:58:54 -0700
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by hpaq12.eem.corp.google.com with ESMTP id p4CJw6sH002220
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 12 May 2011 12:58:52 -0700
Received: by pzk2 with SMTP id 2so899199pzk.9
        for <linux-mm@kvack.org>; Thu, 12 May 2011 12:58:47 -0700 (PDT)
Date: Thu, 12 May 2011 12:58:46 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: slub: Add statistics for this_cmpxchg_double failures
In-Reply-To: <alpine.DEB.2.00.1105120943570.24560@router.home>
Message-ID: <alpine.DEB.2.00.1105121257550.2407@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1103221333130.16870@router.home> <alpine.DEB.2.00.1105111349350.9346@chino.kir.corp.google.com> <alpine.DEB.2.00.1105120943570.24560@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org

On Thu, 12 May 2011, Christoph Lameter wrote:

> > I see this has been merged as 4fdccdfbb465, but it seems pretty pointless
> > unless you export the data to userspace with the necessary STAT_ATTR() and
> > addition in slab_attrs.
> 
> Right that slipped into a later patch that only dealt with statistics. But
> I will fold that into the earlier patch.
> 

I think since CMPXCHG_DOUBLE_CPU_FAIL is already merged as 4fdccdfbb465 
that my patch should be merged to export it?

Not sure what patch you intend to fold this into.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
