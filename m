Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3795B6B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 17:17:15 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id o7ILHC35021381
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 14:17:12 -0700
Received: from pwi3 (pwi3.prod.google.com [10.241.219.3])
	by hpaq12.eem.corp.google.com with ESMTP id o7ILHAwV020359
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 14:17:11 -0700
Received: by pwi3 with SMTP id 3so784509pwi.0
        for <linux-mm@kvack.org>; Wed, 18 Aug 2010 14:17:10 -0700 (PDT)
Date: Wed, 18 Aug 2010 14:17:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q Cleanup2 6/6] slub: Move gfpflag masking out of the
 hotpath
In-Reply-To: <alpine.DEB.2.00.1008181205260.7416@router.home>
Message-ID: <alpine.DEB.2.00.1008181416190.28227@chino.kir.corp.google.com>
References: <20100818162539.281413425@linux.com> <20100818162639.402753062@linux.com> <alpine.DEB.2.00.1008181205260.7416@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 18 Aug 2010, Christoph Lameter wrote:

> Subject: Missing hunk
> 
> The following hung was missing from the patch
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

When folded into patch 6/6:

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
