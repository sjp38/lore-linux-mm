Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 07E946B0044
	for <linux-mm@kvack.org>; Sat,  4 Aug 2012 13:01:08 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so3566695pbb.14
        for <linux-mm@kvack.org>; Sat, 04 Aug 2012 10:01:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120803192150.539500555@linux.com>
References: <20120803192052.448575403@linux.com>
	<20120803192150.539500555@linux.com>
Date: Sun, 5 Aug 2012 02:01:07 +0900
Message-ID: <CAAmzW4NSf0+eGmuprSZtPGp2u-PXzS_YKD3WdE0-zs41kscbKQ@mail.gmail.com>
Subject: Re: Common10 [05/20] Move list_add() to slab_common.c
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

2012/8/4 Christoph Lameter <cl@linux.com>:
> Move the code to append the new kmem_cache to the list of slab caches to
> the kmem_cache_create code in the shared code.
>

Now, we need to list_del() in kmem_cache_destroy() for SLOB,
although later patch will remove it again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
