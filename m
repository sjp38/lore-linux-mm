Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id EBCAF6B005A
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 10:55:57 -0400 (EDT)
Date: Wed, 3 Oct 2012 14:55:56 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: CK2 [04/15] slab: Use the new create_boot_cache function to
 simplify bootstrap
In-Reply-To: <CAAmzW4OZU0hBejhiFHJZpOF+sZssvXZgndQ8VubVtwqTN-Jz6w@mail.gmail.com>
Message-ID: <0000013a27203e8c-40e994cf-7a34-443a-a334-28b2f84e091c-000000@email.amazonses.com>
References: <20120928191715.368450474@linux.com> <0000013a0e56fa0c-93586f2d-5062-42f6-90b1-3e5e24a9ad53-000000@email.amazonses.com> <CAAmzW4OZU0hBejhiFHJZpOF+sZssvXZgndQ8VubVtwqTN-Jz6w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Tue, 2 Oct 2012, JoonSoo Kim wrote:

> With this patch, the slab allocator doesn't properly calculate an
> alignment value for SLAB_HWCACHE_ALIGN flag.
> Do we need to shuffle patches?

The last two hunks belong into the following patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
