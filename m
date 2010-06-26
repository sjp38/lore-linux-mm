Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id AEA3C6B01B0
	for <linux-mm@kvack.org>; Sat, 26 Jun 2010 19:31:47 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id o5QNVi9l006191
	for <linux-mm@kvack.org>; Sat, 26 Jun 2010 16:31:44 -0700
Received: from pvd12 (pvd12.prod.google.com [10.241.209.204])
	by hpaq6.eem.corp.google.com with ESMTP id o5QNVfEZ021852
	for <linux-mm@kvack.org>; Sat, 26 Jun 2010 16:31:42 -0700
Received: by pvd12 with SMTP id 12so168181pvd.3
        for <linux-mm@kvack.org>; Sat, 26 Jun 2010 16:31:41 -0700 (PDT)
Date: Sat, 26 Jun 2010 16:31:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q 05/16] SLUB: Constants need UL
In-Reply-To: <20100625212104.072820103@quilx.com>
Message-ID: <alpine.DEB.2.00.1006261631250.27174@chino.kir.corp.google.com>
References: <20100625212026.810557229@quilx.com> <20100625212104.072820103@quilx.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Fri, 25 Jun 2010, Christoph Lameter wrote:

> UL suffix is missing in some constants. Conform to how slab.h uses constants.
> 
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
