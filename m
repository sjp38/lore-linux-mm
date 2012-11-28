Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 5A5CF6B004D
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 11:23:01 -0500 (EST)
Message-Id: <0000013b47d41614-9dc97580-13f5-4dbe-b01b-64502a2498f5-000000@email.amazonses.com>
Date: Wed, 28 Nov 2012 16:22:59 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK5 [0/6] Sl[auo]b: Common patches for 3.8 merge window
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

Patches from my tree that I have not seen in Pekka's slab/next or in mainstream.

One bugfix and a limited set of patches from the CK5 patchset that I think are safe
for merge. Those posted repeatedly for 6 month or so now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
