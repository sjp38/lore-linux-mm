Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 61DB66B0032
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 11:49:26 -0400 (EDT)
Message-ID: <00000140785e0f03-a6e95e4a-4723-4d05-9ef0-5b88fb577fec-000000@email.amazonses.com>
Date: Tue, 13 Aug 2013 15:49:24 +0000
From: Christoph Lameter <cl@linux.com>
Subject: [3.12 0/3] Sl[auo]b: Some patches for 3.12 V3
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

A set of patches for potential merge in 3.12. This includes further unification work.

V2-V3:
- Fix build issues
- Put all the kmalloc unification patches in one patch since there were bisect issues.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
