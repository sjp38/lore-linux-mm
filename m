Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 0B6016B002B
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 20:53:18 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so6140912pbb.14
        for <linux-mm@kvack.org>; Mon, 15 Oct 2012 17:53:18 -0700 (PDT)
Date: Mon, 15 Oct 2012 17:53:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] SLUB: remove hard coded magic numbers from
 resiliency_test
In-Reply-To: <0000013a66294083-76b27acc-ede7-45d7-849a-0932adecac14-000000@email.amazonses.com>
Message-ID: <alpine.DEB.2.00.1210151753060.31712@chino.kir.corp.google.com>
References: <1350145885-6099-1-git-send-email-richard@rsk.demon.co.uk> <1350145885-6099-2-git-send-email-richard@rsk.demon.co.uk> <0000013a66294083-76b27acc-ede7-45d7-849a-0932adecac14-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Richard Kennedy <richard@rsk.demon.co.uk>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 15 Oct 2012, Christoph Lameter wrote:

> > Use the always inlined function kmalloc_index to translate
> > sizes to indexes, so that we don't have to have the slab indexes
> > hard coded in two places.
> 
> Acked-by: Christoph Lameter <cl@linux.com>
> 

Shouldn't this be using get_slab() instead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
