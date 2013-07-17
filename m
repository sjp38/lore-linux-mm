Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 6538A6B0031
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 17:15:00 -0400 (EDT)
Message-ID: <0000013fee7c6945-114e9c97-1a81-40ad-88c2-c49bd7cab4f3-000000@email.amazonses.com>
Date: Wed, 17 Jul 2013 21:14:59 +0000
From: Christoph Lameter <cl@linux.com>
Subject: C1 [0/2] Sl[auo]b: Common kmalloc V1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Two patches that provide a common kmalloc framework in slab.h and remove code from include/linux/sl?b_def.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
