Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4E5B76B01AC
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 17:36:24 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id o5ILaLY4004421
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 14:36:21 -0700
Received: from pwi4 (pwi4.prod.google.com [10.241.219.4])
	by kpbe20.cbf.corp.google.com with ESMTP id o5ILaJTn016055
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 14:36:20 -0700
Received: by pwi4 with SMTP id 4so682495pwi.1
        for <linux-mm@kvack.org>; Fri, 18 Jun 2010 14:36:19 -0700 (PDT)
Date: Fri, 18 Jun 2010 14:36:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: slub: Constants need UL
In-Reply-To: <alpine.DEB.2.00.1006151403070.10865@router.home>
Message-ID: <alpine.DEB.2.00.1006181434430.16115@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006151403070.10865@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 Jun 2010, Christoph Lameter wrote:

> Subject: SLUB: Constants need UL
> 
> UL suffix is missing in some constants. Conform to how slab.h uses constants.
> 
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
