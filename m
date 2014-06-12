Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9DBF5900002
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 02:07:01 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id et14so626872pad.13
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 23:07:01 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id pc5si40416145pbc.169.2014.06.11.23.06.58
        for <linux-mm@kvack.org>;
        Wed, 11 Jun 2014 23:07:00 -0700 (PDT)
Date: Thu, 12 Jun 2014 15:10:56 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/3] slab common: Add functions for kmem_cache_node access
Message-ID: <20140612061056.GA19918@js1304-P5Q-DELUXE>
References: <20140611191510.082006044@linux.com>
 <20140611191518.964245135@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140611191518.964245135@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Jun 11, 2014 at 02:15:11PM -0500, Christoph Lameter wrote:
> These functions allow to eliminate repeatedly used code in both
> SLAB and SLUB and also allow for the insertion of debugging code
> that may be needed in the development process.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
