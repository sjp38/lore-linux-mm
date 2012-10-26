Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 79A906B0072
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 10:15:11 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id k14so3398416oag.14
        for <linux-mm@kvack.org>; Fri, 26 Oct 2012 07:15:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0000013a9444c6ba-d26e7627-1890-40da-ae91-91e7c4a3d7e9-000000@email.amazonses.com>
References: <1351087158-8524-1-git-send-email-glommer@parallels.com>
	<1351087158-8524-2-git-send-email-glommer@parallels.com>
	<CAOJsxLHxo7zJk=aWrjmuaYsEkaChTCgXowtHxtuiabaOP3W3-Q@mail.gmail.com>
	<0000013a9444c6ba-d26e7627-1890-40da-ae91-91e7c4a3d7e9-000000@email.amazonses.com>
Date: Fri, 26 Oct 2012 23:15:10 +0900
Message-ID: <CAAmzW4O1EAFxHf1tRaFzg-opPLzMboAdo-vbUFkyo=ZdQp9rmw@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] kmem_cache: include allocators code directly into slab_common
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>

2012/10/25 Christoph Lameter <cl@linux.com>:
> On Wed, 24 Oct 2012, Pekka Enberg wrote:
>
>> So I hate this patch with a passion. We don't have any fastpaths in
>> mm/slab_common.c nor should we. Those should be allocator specific.
>
> I have similar thoughts on the issue. Lets keep the fast paths allocator
> specific until we find a better way to handle this issue.

Okay. I see.
How about applying LTO not to the whole kernel code, but just to
slab_common.o + sl[aou]b.o?
I think that it may be possible, isn't it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
