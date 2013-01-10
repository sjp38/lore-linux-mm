Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id E22456B005A
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 14:00:54 -0500 (EST)
Message-Id: <0000013c25d61596-bb94c3c3-a974-4ca4-9212-ecab243176ba-000000@email.amazonses.com>
Date: Thu, 10 Jan 2013 19:00:53 +0000
From: Christoph Lameter <cl@linux.com>
Subject: REN2 [00/13] Sl[auo]b: Renaming etc for -next rebased to 3.8-rc3
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

These are patches that mostly rename variables and rearrange code. The first part has
been extensively reviewed. Please take as much as possible.

Also some bug fixes and a couple of patches that make allocators use common functions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
