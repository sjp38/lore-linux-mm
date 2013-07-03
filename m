Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 7A4ED6B0036
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 09:55:21 -0400 (EDT)
Date: Wed, 3 Jul 2013 13:55:20 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 3/5] mm/slab: Fix /proc/slabinfo unwriteable for
 slab
In-Reply-To: <1372812593-7617-3-git-send-email-liwanp@linux.vnet.ibm.com>
Message-ID: <0000013fa4d0e060-54cc0d26-3ddf-48bb-a868-1fb5b41ea5fb-000000@email.amazonses.com>
References: <1372812593-7617-1-git-send-email-liwanp@linux.vnet.ibm.com> <1372812593-7617-3-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 3 Jul 2013, Wanpeng Li wrote:

> Slab have some tunables like limit, batchcount, and sharedfactor can be
> tuned through function slabinfo_write. Commit (b7454ad3: mm/sl[au]b: Move
> slabinfo processing to slab_common.c) uncorrectly change /proc/slabinfo
> unwriteable for slab, this patch fix it by revert to original mode.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
