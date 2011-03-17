Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D71CA8D0039
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 03:07:08 -0400 (EDT)
Date: 17 Mar 2011 03:07:05 -0400
Message-ID: <20110317070705.15100.qmail@science.horizon.com>
From: "George Spelvin" <linux@horizon.com>
Subject: Re: [PATCH 5/8] mm/slub: Factor out some common code.
In-Reply-To: <AANLkTikDAEuTcrgo0YcUO40A9x5jaL-d+ZPviCXANe3r@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@horizon.com, penberg@kernel.org
Cc: herbert@gondor.hengli.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com, penberg@cs.helsinki.fi, rientjes@google.com

> I certainly don't but I'd still like to ask you to change it to
> 'unsigned long'. That's a Linux kernel idiom and we're not going to
> change the whole kernel.

Damn, and I just prepared the following patch.  Should I, instead, do

--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -62,5 +62,5 @@ struct kmem_cache {
 /* 3) touched by every alloc & free from the backend */
 
-	unsigned int flags;		/* constant flags */
+	unsigned long flags;		/* constant flags */
 	unsigned int num;		/* # of objs per slab */
 
... because the original slab code uses an unsigned int.  To fix it
the other way (for SLAB_ flags only) is a patch like this:
