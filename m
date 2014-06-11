Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 39F546B0189
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 19:15:34 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id a13so6870074igq.4
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 16:15:34 -0700 (PDT)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id vp10si43513255icb.57.2014.06.11.16.15.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 16:15:33 -0700 (PDT)
Received: by mail-ig0-f173.google.com with SMTP id r2so5089616igi.12
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 16:15:33 -0700 (PDT)
Date: Wed, 11 Jun 2014 16:15:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/3] slab: Use get_node() and kmem_cache_node()
 functions
In-Reply-To: <20140611191519.182409067@linux.com>
Message-ID: <alpine.DEB.2.02.1406111614590.27885@chino.kir.corp.google.com>
References: <20140611191510.082006044@linux.com> <20140611191519.182409067@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 11 Jun 2014, Christoph Lameter wrote:

> Use the two functions to simplify the code avoiding numerous explicit
> checks coded checking for a certain node to be online.
> 
> Get rid of various repeated calculations of kmem_cache_node structures.
> 

You're not bragging about your diffstat that removes more lines than it 
removes that show why this change is helpful :)

 mm/slab.c |  167 +++++++++++++++++++++++++++++------------------------------------
 1 file changed, 77 insertions(+), 90 deletions(-)

> Signed-off-by: Christoph Lameter <cl@linux.com>
> 

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
