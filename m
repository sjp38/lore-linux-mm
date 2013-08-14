Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 5C3D66B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 12:39:07 -0400 (EDT)
Date: Wed, 14 Aug 2013 16:39:06 +0000
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [3.12 1/3] Move kmallocXXX functions to common code
In-Reply-To: <520B9AB0.7010209@fastmail.fm>
Message-ID: <000001407db1e7c4-40866f2d-32c7-470a-a81a-94db87cdafa7-000000@email.amazonses.com>
References: <20130813154940.741769876@linux.com> <00000140785e1062-89326db9-3999-43c1-b081-284dd49b3d9b-000000@email.amazonses.com> <520B9AB0.7010209@fastmail.fm>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@fastmail.fm>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Wed, 14 Aug 2013, Pekka Enberg wrote:

> The introduction kmalloc_large() needs to happen in a
> separate patch. What exactly is the benefit of adding the
> new API, btw? Why don't people just use the page allocator
> directly?

The advantage of kmalloc_large is that is has the same calling convention
as kmalloc. get_free_pages() etc require page addresses and return
unsigned longs meaning that conversions are required.

kmalloc_large functionality is already in use by slob and slub and
therefore is easy to make commonly available.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
