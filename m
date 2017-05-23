Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D99716B0279
	for <linux-mm@kvack.org>; Mon, 22 May 2017 21:35:25 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y65so148078215pff.13
        for <linux-mm@kvack.org>; Mon, 22 May 2017 18:35:25 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v63sor488217pgv.168.2017.05.22.18.35.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 May 2017 18:35:25 -0700 (PDT)
Date: Mon, 22 May 2017 18:35:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] mm/slub: Only define kmalloc_large_node_hook() for
 NUMA systems
In-Reply-To: <20170522144501.2d02b5799e07167dc5aecf3e@linux-foundation.org>
Message-ID: <alpine.DEB.2.10.1705221834440.13805@chino.kir.corp.google.com>
References: <20170519210036.146880-1-mka@chromium.org> <20170519210036.146880-2-mka@chromium.org> <alpine.DEB.2.10.1705221338100.30407@chino.kir.corp.google.com> <20170522205621.GL141096@google.com>
 <20170522144501.2d02b5799e07167dc5aecf3e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Matthias Kaehlcke <mka@chromium.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 22 May 2017, Andrew Morton wrote:

> > > Is clang not inlining kmalloc_large_node_hook() for some reason?  I don't 
> > > think this should ever warn on gcc.
> > 
> > clang warns about unused static inline functions outside of header
> > files, in difference to gcc.
> 
> I wish it wouldn't.  These patches just add clutter.
> 

Matthias, what breaks if you do this?

diff --git a/include/linux/compiler-clang.h b/include/linux/compiler-clang.h
index de179993e039..e1895ce6fa1b 100644
--- a/include/linux/compiler-clang.h
+++ b/include/linux/compiler-clang.h
@@ -15,3 +15,8 @@
  * with any version that can compile the kernel
  */
 #define __UNIQUE_ID(prefix) __PASTE(__PASTE(__UNIQUE_ID_, prefix), __COUNTER__)
+
+#ifdef inline
+#undef inline
+#define inline __attribute__((unused))
+#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
