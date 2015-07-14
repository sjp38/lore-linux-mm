Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id BB0E56B0285
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 19:03:02 -0400 (EDT)
Received: by pdbqm3 with SMTP id qm3so13163788pdb.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 16:03:02 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ju8si4121351pbb.43.2015.07.14.16.03.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 16:03:02 -0700 (PDT)
Date: Tue, 14 Jul 2015 16:03:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V2] checkpatch: Add some <foo>_destroy functions to
 NEEDLESS_IF tests
Message-Id: <20150714160300.e59bec100e2ba090bc5e2107@linux-foundation.org>
In-Reply-To: <1433915549.2730.107.camel@perches.com>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
	<20150609142523.b717dba6033ee08de997c8be@linux-foundation.org>
	<1433894769.2730.87.camel@perches.com>
	<1433911166.2730.98.camel@perches.com>
	<1433915549.2730.107.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Julia Lawall <julia.lawall@lip6.fr>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com

On Tue, 09 Jun 2015 22:52:29 -0700 Joe Perches <joe@perches.com> wrote:

> Sergey Senozhatsky has modified several destroy functions that can
> now be called with NULL values.
> 
>  - kmem_cache_destroy()
>  - mempool_destroy()
>  - dma_pool_destroy()
> 
> Update checkpatch to warn when those functions are preceded by an if.
> 
> Update checkpatch to --fix all the calls too only when the code style
> form is using leading tabs.
> 
> from:
> 	if (foo)
> 		<func>(foo);
> to:
> 	<func>(foo);

There's also zpool_destroy_pool() and zs_destroy_pool().  Did we decide
they're not worth bothering about?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
