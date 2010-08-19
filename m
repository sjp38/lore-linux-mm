Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 130EB6B02BF
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 17:02:37 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o7JL29eg008959
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 14:02:09 -0700
Received: from pxi5 (pxi5.prod.google.com [10.243.27.5])
	by wpaz17.hot.corp.google.com with ESMTP id o7JL27BK023743
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 14:02:07 -0700
Received: by pxi5 with SMTP id 5so1033895pxi.14
        for <linux-mm@kvack.org>; Thu, 19 Aug 2010 14:02:07 -0700 (PDT)
Date: Thu, 19 Aug 2010 14:02:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q Cleanup3 5/6] slub: Extract hooks for memory checkers from
 hotpaths
In-Reply-To: <20100819203439.351107542@linux.com>
Message-ID: <alpine.DEB.2.00.1008191401500.18994@chino.kir.corp.google.com>
References: <20100819203324.549566024@linux.com> <20100819203439.351107542@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Aug 2010, Christoph Lameter wrote:

> Extract the code that memory checkers and other verification tools use from
> the hotpaths. Makes it easier to add new ones and reduces the disturbances
> of the hotpaths.
> 
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
