Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id BE1D46B0034
	for <linux-mm@kvack.org>; Wed, 11 Sep 2013 10:40:19 -0400 (EDT)
Date: Wed, 11 Sep 2013 14:40:18 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 08/16] slab: use well-defined macro, virt_to_slab()
In-Reply-To: <1377161065-30552-9-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <000001410d773210-0bb9ebcc-7573-4031-bcf9-80f12754bc9e-000000@email.amazonses.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com> <1377161065-30552-9-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 22 Aug 2013, Joonsoo Kim wrote:

> This is trivial change, just use well-defined macro.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
