Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id E73146B0034
	for <linux-mm@kvack.org>; Wed,  4 Sep 2013 12:35:35 -0400 (EDT)
Message-ID: <00000140e9d43a3b-2c47e5ae-f3fe-4185-afad-1565367db74c-000000@email.amazonses.com>
Date: Wed, 4 Sep 2013 16:35:34 +0000
From: Christoph Lameter <cl@linux.com>
Subject: [3.12 0/2] Sl[auo]b: Unification patches for 3.12 V4
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

A set of patches for in 3.12. This includes further unification work.

V3->v4:
- Rediff.
- Drop the large kmalloc patch for seq.c

V2-V3:
- Fix build issues
- Put all the kmalloc unification patches in one patch since there were bisect issues.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
