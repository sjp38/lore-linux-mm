Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 766CE6B005C
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 21:37:52 -0400 (EDT)
Received: by dakp5 with SMTP id p5so163871dak.14
        for <linux-mm@kvack.org>; Wed, 20 Jun 2012 18:37:51 -0700 (PDT)
Date: Wed, 20 Jun 2012 18:37:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slab: do not call compound_head() in page_get_cache()
In-Reply-To: <1340233273-10994-1-git-send-email-walken@google.com>
Message-ID: <alpine.DEB.2.00.1206201837320.7850@chino.kir.corp.google.com>
References: <1340233273-10994-1-git-send-email-walken@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, 20 Jun 2012, Michel Lespinasse wrote:

> page_get_cache() does not need to call compound_head(), as its unique
> caller virt_to_slab() already makes sure to return a head page.
> 
> Additionally, removing the compound_head() call makes page_get_cache()
> consistent with page_get_slab().
> 
> Signed-off-by: Michel Lespinasse <walken@google.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
