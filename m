Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id B67716B005D
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 16:41:51 -0400 (EDT)
Date: Mon, 15 Oct 2012 20:41:50 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] SLUB: remove hard coded magic numbers from
 resiliency_test
In-Reply-To: <1350145885-6099-2-git-send-email-richard@rsk.demon.co.uk>
Message-ID: <0000013a66294083-76b27acc-ede7-45d7-849a-0932adecac14-000000@email.amazonses.com>
References: <1350145885-6099-1-git-send-email-richard@rsk.demon.co.uk> <1350145885-6099-2-git-send-email-richard@rsk.demon.co.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 13 Oct 2012, Richard Kennedy wrote:

> Use the always inlined function kmalloc_index to translate
> sizes to indexes, so that we don't have to have the slab indexes
> hard coded in two places.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
