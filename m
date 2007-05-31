Message-Id: <20070531002047.702473071@sgi.com>
Date: Wed, 30 May 2007 17:20:47 -0700
From: clameter@sgi.com
Subject: [RFC 0/4] CONFIG_STABLE to switch off development checks
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

A while back we talked about having the capability of switching off checks
like the one for kmalloc(0) for stable kernel releases. This is a first stab
at such functionality. It adds #ifdef CONFIG_STABLE for now. Maybe we can
come up with some better way to handle it later. There should alsol be some
way to set CONFIG_STABLE from the Makefile.

CONFIG_STABLE switches off

- kmalloc(0) check in both slab allocators
- SLUB banner
- Makes SLUB tolerate object corruption like SLAB (not sure if we really want
  to go down this route. See patch)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
