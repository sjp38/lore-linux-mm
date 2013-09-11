Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id DB1D76B0031
	for <linux-mm@kvack.org>; Wed, 11 Sep 2013 10:17:58 -0400 (EDT)
Date: Wed, 11 Sep 2013 14:17:57 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: Make allocations with GFP_ZERO slightly more
 efficient
In-Reply-To: <1378857771.15187.4.camel@joe-AO722>
Message-ID: <000001410d62c020-44437965-d471-4125-af3c-cfd19b393de8-000000@email.amazonses.com>
References: <1378857771.15187.4.camel@joe-AO722>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 10 Sep 2013, Joe Perches wrote:

> Use the likely mechanism already around valid
> pointer tests to better choose when to memset
> to 0 allocations with __GFP_ZERO

Ok but that is not that important since the first ptr check is only for
debuggin.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
