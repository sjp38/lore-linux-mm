Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id D8A6B6B0031
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 17:23:13 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un1so11550810pbc.29
        for <linux-mm@kvack.org>; Mon, 24 Jun 2013 14:23:13 -0700 (PDT)
Date: Mon, 24 Jun 2013 14:23:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] mm/slab: Sharing s_next and s_stop between slab and
 slub
In-Reply-To: <1372069394-26167-2-git-send-email-liwanp@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1306241421560.25343@chino.kir.corp.google.com>
References: <1372069394-26167-1-git-send-email-liwanp@linux.vnet.ibm.com> <1372069394-26167-2-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 24 Jun 2013, Wanpeng Li wrote:

> This patch shares s_next and s_stop between slab and slub.
> 

Just about the entire kernel includes slab.h, so I think you'll need to 
give these slab-specific names instead of exporting "s_next" and "s_stop" 
to everybody.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
