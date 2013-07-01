Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id BC00E6B0033
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 11:48:10 -0400 (EDT)
Date: Mon, 1 Jul 2013 15:48:09 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] mm/slab: Sharing s_next and s_stop between slab and
 slub
In-Reply-To: <alpine.DEB.2.02.1306241421560.25343@chino.kir.corp.google.com>
Message-ID: <0000013f9aeb70c6-f6dad22c-bb88-4313-8602-538a3f5cedf5-000000@email.amazonses.com>
References: <1372069394-26167-1-git-send-email-liwanp@linux.vnet.ibm.com> <1372069394-26167-2-git-send-email-liwanp@linux.vnet.ibm.com> <alpine.DEB.2.02.1306241421560.25343@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 24 Jun 2013, David Rientjes wrote:

> On Mon, 24 Jun 2013, Wanpeng Li wrote:
>
> > This patch shares s_next and s_stop between slab and slub.
> >
>
> Just about the entire kernel includes slab.h, so I think you'll need to
> give these slab-specific names instead of exporting "s_next" and "s_stop"
> to everybody.

He put the export into mm/slab.h. The headerfile is only included by
mm/sl?b.c .

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
