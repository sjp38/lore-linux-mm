Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 8BBED6B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 10:25:47 -0400 (EDT)
Date: Wed, 19 Jun 2013 14:25:46 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: do not put a slab to cpu partial list when
 cpu_partial is 0
In-Reply-To: <1371623635-26575-1-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <0000013f5cd3b621-8f7f97fb-f97e-4498-9e1e-40feaa7be0b7-000000@email.amazonses.com>
References: <1371623635-26575-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 19 Jun 2013, Joonsoo Kim wrote:

> In free path, we don't check number of cpu_partial, so one slab can
> be linked in cpu partial list even if cpu_partial is 0. To prevent this,
> we should check number of cpu_partial in put_cpu_partial().

Acked-by: Christoph Lameeter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
