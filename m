Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 427F06B005A
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 10:50:28 -0400 (EDT)
Date: Wed, 3 Oct 2012 14:50:27 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: CK2 [03/15] slub: Use a statically allocated kmem_cache boot
 structure for bootstrap
In-Reply-To: <CAAmzW4NW4LgXOxXQvRVgBhJ2Vxyijx0bugGDPgBjz2kUY=DAuA@mail.gmail.com>
Message-ID: <0000013a271b3b7b-b25dfc16-ebaf-41b8-8595-b4496833a84a-000000@email.amazonses.com>
References: <20120928191715.368450474@linux.com> <0000013a0e5f601a-e8401015-afdb-4958-b562-0d1d5d2d6f15-000000@email.amazonses.com> <CAAmzW4NW4LgXOxXQvRVgBhJ2Vxyijx0bugGDPgBjz2kUY=DAuA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Tue, 2 Oct 2012, JoonSoo Kim wrote:

> This addition should go to previous patch "create common functions for
> boot slab creation".

Ok. That will be the case in V3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
