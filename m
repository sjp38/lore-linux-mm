Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 8D34C6B0068
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 15:34:27 -0400 (EDT)
Date: Wed, 24 Oct 2012 19:34:26 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 1/2] kmem_cache: include allocators code directly into
 slab_common
In-Reply-To: <CAOJsxLHxo7zJk=aWrjmuaYsEkaChTCgXowtHxtuiabaOP3W3-Q@mail.gmail.com>
Message-ID: <0000013a9444c6ba-d26e7627-1890-40da-ae91-91e7c4a3d7e9-000000@email.amazonses.com>
References: <1351087158-8524-1-git-send-email-glommer@parallels.com> <1351087158-8524-2-git-send-email-glommer@parallels.com> <CAOJsxLHxo7zJk=aWrjmuaYsEkaChTCgXowtHxtuiabaOP3W3-Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>

On Wed, 24 Oct 2012, Pekka Enberg wrote:

> So I hate this patch with a passion. We don't have any fastpaths in
> mm/slab_common.c nor should we. Those should be allocator specific.

I have similar thoughts on the issue. Lets keep the fast paths allocator
specific until we find a better way to handle this issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
