Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 1B8A76B00CA
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 05:40:14 -0400 (EDT)
Message-ID: <1349170840.10698.14.camel@jlt4.sipsolutions.net>
Subject: slab vs. slub kmem cache name inconsistency
From: Johannes Berg <johannes@sipsolutions.net>
Date: Tue, 02 Oct 2012 11:40:40 +0200
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

Hi,

I just noticed that slub's kmem_cache_create() will kstrdup() the name,
while slab doesn't. That's a little confusing, since when you look at
slub you can easily get away with passing a string you built on the
stack, while that will then lead to very strange results (and possibly
crashes?) with slab. The slab kernel-doc string always says this:

 * @name must be valid until the cache is destroyed. This implies that
 * the module calling this has to destroy the cache before getting unloaded.

Is there any reason for this difference, or should slab also kstrdup(),
or should slub not do it? Or maybe slub should have a "oops, name is on
stack" warning/check?

johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
