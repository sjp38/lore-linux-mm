Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E213A6B01B2
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 02:20:55 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o586KrGI023888
	for <linux-mm@kvack.org>; Mon, 7 Jun 2010 23:20:53 -0700
Received: from pxi1 (pxi1.prod.google.com [10.243.27.1])
	by wpaz29.hot.corp.google.com with ESMTP id o586KprO017911
	for <linux-mm@kvack.org>; Mon, 7 Jun 2010 23:20:52 -0700
Received: by pxi1 with SMTP id 1so1959951pxi.8
        for <linux-mm@kvack.org>; Mon, 07 Jun 2010 23:20:51 -0700 (PDT)
Date: Mon, 7 Jun 2010 23:20:48 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC V2 SLEB 01/14] slab: Introduce a constant for a unspecified
 node.
In-Reply-To: <AANLkTikOKy6ZQQh2zORJDvGDE0golvyzsvlvDj-P5cur@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1006072319330.31780@chino.kir.corp.google.com>
References: <20100521211452.659982351@quilx.com> <20100521211537.530913777@quilx.com> <alpine.DEB.2.00.1006071443120.10905@chino.kir.corp.google.com> <alpine.DEB.2.00.1006071729560.12482@router.home>
 <AANLkTikOKy6ZQQh2zORJDvGDE0golvyzsvlvDj-P5cur@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, Pekka Enberg wrote:

> > Ok will do that in the next release.
> 
> Patches 1-5 are queued for 2.6.36 so please send an incremental patch
> on top of 'slub/cleanups' branch of slab.git.
> 

An incremental patch in this case would change everything that the 
original patch did, so it'd probably be best to simply revert and queue 
the updated version.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
