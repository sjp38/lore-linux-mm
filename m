Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 929716B0033
	for <linux-mm@kvack.org>; Fri,  5 Jul 2013 09:37:29 -0400 (EDT)
Date: Fri, 5 Jul 2013 13:37:28 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 1/5] mm/slab: Fix drain freelist excessively
In-Reply-To: <1372898006-6308-1-git-send-email-liwanp@linux.vnet.ibm.com>
Message-ID: <0000013faf0d3958-00e5e945-25d8-43c1-ac6e-3d3ad69b2718-000000@email.amazonses.com>
References: <1372898006-6308-1-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 4 Jul 2013, Wanpeng Li wrote:

> This patch fix the callers that pass # of objects. Make sure they pass #
> of slabs.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
