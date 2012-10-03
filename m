Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 47DF66B006E
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 11:06:14 -0400 (EDT)
Date: Wed, 3 Oct 2012 15:06:13 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: CK2 [07/15] slab: Use common kmalloc_index/kmalloc_size
 functions
In-Reply-To: <CAAmzW4Mct3brt8PqSvHSGVsw1h+tSz4moWdAc7Prv1CbZ+KwWA@mail.gmail.com>
Message-ID: <0000013a2729aa97-6c6d374d-619a-45b7-879e-ea4316844531-000000@email.amazonses.com>
References: <20120928191715.368450474@linux.com> <0000013a0e5680ef-15d433d3-311b-47cd-a767-daa8e377612f-000000@email.amazonses.com> <CAAmzW4Mct3brt8PqSvHSGVsw1h+tSz4moWdAc7Prv1CbZ+KwWA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Wed, 3 Oct 2012, JoonSoo Kim wrote:

> Now, I am just reading the codes and I cannot find a defintion of the
> kmalloc_caches in slab.c.
> Please let me know where I can find definition of kmalloc_caches for slab.c.

Its gone.... ;-) Did not pay enough attention to the early patches in
the last round it seems. Some hunks were moving around. Added the new
names to this patch and then removed them in the patch that moves the
definition to slab_common.c.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
