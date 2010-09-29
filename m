Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A1A9B6B0047
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 16:01:47 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o8TK1hOV032615
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 13:01:43 -0700
Received: from pvc21 (pvc21.prod.google.com [10.241.209.149])
	by wpaz29.hot.corp.google.com with ESMTP id o8TK1fqB028887
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 13:01:42 -0700
Received: by pvc21 with SMTP id 21so601612pvc.41
        for <linux-mm@kvack.org>; Wed, 29 Sep 2010 13:01:41 -0700 (PDT)
Date: Wed, 29 Sep 2010 13:01:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Slub cleanup5 2/3] SLUB: Pass active and inactive redzone flags
 instead of boolean to debug functions
In-Reply-To: <alpine.DEB.2.00.1009290713190.30155@router.home>
Message-ID: <alpine.DEB.2.00.1009291301060.9797@chino.kir.corp.google.com>
References: <20100928131025.319846721@linux.com> <20100928131057.084357922@linux.com> <alpine.DEB.2.00.1009281733430.9704@chino.kir.corp.google.com> <alpine.DEB.2.00.1009290713190.30155@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Sep 2010, Christoph Lameter wrote:

> Updated patch:
> 
> Subject: SLUB: Pass active and inactive redzone flags instead of boolean to debug functions
> 
> Pass the actual values used for inactive and active redzoning to the
> functions that check the objects. Avoids a lot of the ? : things to
> lookup the values in the functions.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
