Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 127806B0071
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 15:04:52 -0400 (EDT)
Date: Fri, 8 Jun 2012 14:04:49 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 4/4] slub: deactivate freelist of kmem_cache_cpu all at
 once in deactivate_slab()
In-Reply-To: <1339176197-13270-4-git-send-email-js1304@gmail.com>
Message-ID: <alpine.DEB.2.00.1206081403380.28466@router.home>
References: <yes> <1339176197-13270-1-git-send-email-js1304@gmail.com> <1339176197-13270-4-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 9 Jun 2012, Joonsoo Kim wrote:

> Current implementation of deactivate_slab() which deactivate
> freelist of kmem_cache_cpu one by one is inefficient.
> This patch changes it to deactivate freelist all at once.
> But, there is no overall performance benefit,
> because deactivate_slab() is invoked infrequently.

Hmm, deactivate freelist can race with slab_free. Need to look at this in
detail.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
