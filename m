Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id AEC626B005A
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 16:15:36 -0500 (EST)
Message-Id: <0000013b961f5543-d0b52ed3-3373-4957-83e4-c4bec464d134-000000@email.amazonses.com>
Date: Thu, 13 Dec 2012 21:15:34 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Ren [00/12] Sl[auo]b: Renaming etc for late merge
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

These are patches that mostly rename variables and rearrange some code.

Some bug fixes and a couple of patches that make allocators use common functions.

It is probably best if these would be merged after all the other patches are in
because any other patchset sets will likely require rebasing after this was merged.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
