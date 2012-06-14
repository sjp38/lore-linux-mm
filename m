Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 8F0856B005C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 06:16:58 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so1501576ghr.14
        for <linux-mm@kvack.org>; Thu, 14 Jun 2012 03:16:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120613152525.596813300@linux.com>
References: <20120613152451.465596612@linux.com>
	<20120613152525.596813300@linux.com>
Date: Thu, 14 Jun 2012 13:16:57 +0300
Message-ID: <CAOJsxLE-7XCzbAi-M=sBkPymAj25yNGvAs6ea-ZyaEbDJo3+cA@mail.gmail.com>
Subject: Re: Common [19/20] Allocate kmem_cache structure in slab_common.c
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

On Wed, Jun 13, 2012 at 6:25 PM, Christoph Lameter <cl@linux.com> wrote:
> Move kmem_cache memory allocation and the checks for success out of the
> slab allocators into the common code.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>

This patch seems to cause hard lockup on my laptop on boot.

P.S. While bisecting this, I also saw some other oopses so I think
this series needs some more testing before we can put it in
linux-next...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
