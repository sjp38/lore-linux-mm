Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id C3B666B0185
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 19:07:22 -0400 (EDT)
Received: by mail-ie0-f182.google.com with SMTP id rp18so442591iec.13
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 16:07:22 -0700 (PDT)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id ad4si398872igd.13.2014.06.11.16.07.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 16:07:22 -0700 (PDT)
Received: by mail-ig0-f171.google.com with SMTP id h18so3534831igc.4
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 16:07:21 -0700 (PDT)
Date: Wed, 11 Jun 2014 16:07:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] slab common: Add functions for kmem_cache_node
 access
In-Reply-To: <20140611191518.964245135@linux.com>
Message-ID: <alpine.DEB.2.02.1406111607090.27885@chino.kir.corp.google.com>
References: <20140611191510.082006044@linux.com> <20140611191518.964245135@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 11 Jun 2014, Christoph Lameter wrote:

> These functions allow to eliminate repeatedly used code in both
> SLAB and SLUB and also allow for the insertion of debugging code
> that may be needed in the development process.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
