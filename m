Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4AC2D280267
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 20:27:12 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so14674276pdb.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 17:27:12 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id bx2si4379070pab.141.2015.07.14.17.27.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 17:27:11 -0700 (PDT)
Received: by pacan13 with SMTP id an13so13709385pac.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 17:27:11 -0700 (PDT)
Date: Wed, 15 Jul 2015 09:27:43 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH V2] checkpatch: Add some <foo>_destroy functions to
 NEEDLESS_IF tests
Message-ID: <20150715002743.GB742@swordfish>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
 <20150609142523.b717dba6033ee08de997c8be@linux-foundation.org>
 <1433894769.2730.87.camel@perches.com>
 <1433911166.2730.98.camel@perches.com>
 <1433915549.2730.107.camel@perches.com>
 <20150714160300.e59bec100e2ba090bc5e2107@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150714160300.e59bec100e2ba090bc5e2107@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joe Perches <joe@perches.com>, Julia Lawall <julia.lawall@lip6.fr>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com

On (07/14/15 16:03), Andrew Morton wrote:
> > Sergey Senozhatsky has modified several destroy functions that can
> > now be called with NULL values.
> > 
> >  - kmem_cache_destroy()
> >  - mempool_destroy()
> >  - dma_pool_destroy()
> > 
> > Update checkpatch to warn when those functions are preceded by an if.
> > 
> > Update checkpatch to --fix all the calls too only when the code style
> > form is using leading tabs.
> > 
> > from:
> > 	if (foo)
> > 		<func>(foo);
> > to:
> > 	<func>(foo);
> 
> There's also zpool_destroy_pool() and zs_destroy_pool().  Did we decide
> they're not worth bothering about?

Correct. Those two are very unlikely will see any significant number
of users so, I think, we can drop the patches that touch zspool and
zsmalloc destructors.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
