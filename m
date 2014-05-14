Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 591676B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 16:10:22 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id rr13so53570pbb.7
        for <linux-mm@kvack.org>; Wed, 14 May 2014 13:10:22 -0700 (PDT)
Received: from mail-pb0-x233.google.com (mail-pb0-x233.google.com [2607:f8b0:400e:c01::233])
        by mx.google.com with ESMTPS id vv4si1468998pbc.451.2014.05.14.13.10.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 May 2014 13:10:21 -0700 (PDT)
Received: by mail-pb0-f51.google.com with SMTP id ma3so53689pbc.10
        for <linux-mm@kvack.org>; Wed, 14 May 2014 13:10:20 -0700 (PDT)
Date: Wed, 14 May 2014 13:10:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm: fix some indenting in cmpxchg_double_slab()
In-Reply-To: <20140514161644.GF18082@mwanda>
Message-ID: <alpine.DEB.2.02.1405141310080.9496@chino.kir.corp.google.com>
References: <20140514161644.GF18082@mwanda>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

On Wed, 14 May 2014, Dan Carpenter wrote:

> The return statement goes with the cmpxchg_double() condition so it
> needs to be indented another tab.
> 
> Also these days the fashion is to line function parameters up, and it
> looks nicer that way because then the "freelist_new" is not at the same
> indent level as the "return 1;".
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
