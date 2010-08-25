Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 99C2E6B020C
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 19:19:05 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o7PNJ3x7020829
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 16:19:04 -0700
Received: from pvg4 (pvg4.prod.google.com [10.241.210.132])
	by kpbe14.cbf.corp.google.com with ESMTP id o7PNJ2aO013184
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 16:19:02 -0700
Received: by pvg4 with SMTP id 4so525603pvg.27
        for <linux-mm@kvack.org>; Wed, 25 Aug 2010 16:19:02 -0700 (PDT)
Date: Wed, 25 Aug 2010 16:18:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: linux-next: Tree for August 25 (mm/slub)
In-Reply-To: <alpine.DEB.2.00.1008251405590.22117@router.home>
Message-ID: <alpine.DEB.2.00.1008251618400.31521@chino.kir.corp.google.com>
References: <20100825132057.c8416bef.sfr@canb.auug.org.au> <20100825094559.bc652afe.randy.dunlap@oracle.com> <alpine.DEB.2.00.1008251405590.22117@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Aug 2010, Christoph Lameter wrote:

> Subject: slub: Add dummy functions for the !SLUB_DEBUG case
> 
> Provide the fall back functions to empty hooks if SLUB_DEBUG is not set.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
