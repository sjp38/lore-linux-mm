Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 98CF16B006E
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 11:31:52 -0400 (EDT)
Date: Tue, 30 Oct 2012 15:31:51 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 1/2] kmem_cache: include allocators code directly into
 slab_common
In-Reply-To: <CAAmzW4O1EAFxHf1tRaFzg-opPLzMboAdo-vbUFkyo=ZdQp9rmw@mail.gmail.com>
Message-ID: <0000013ab24cd7ac-1c5345d6-5fea-4459-942e-b6deccd1a6f1-000000@email.amazonses.com>
References: <1351087158-8524-1-git-send-email-glommer@parallels.com> <1351087158-8524-2-git-send-email-glommer@parallels.com> <CAOJsxLHxo7zJk=aWrjmuaYsEkaChTCgXowtHxtuiabaOP3W3-Q@mail.gmail.com> <0000013a9444c6ba-d26e7627-1890-40da-ae91-91e7c4a3d7e9-000000@email.amazonses.com>
 <CAAmzW4O1EAFxHf1tRaFzg-opPLzMboAdo-vbUFkyo=ZdQp9rmw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: andi@firstfloor.org
Cc: Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, JoonSoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>

On Fri, 26 Oct 2012, JoonSoo Kim wrote:

> 2012/10/25 Christoph Lameter <cl@linux.com>:
> > On Wed, 24 Oct 2012, Pekka Enberg wrote:
> >
> >> So I hate this patch with a passion. We don't have any fastpaths in
> >> mm/slab_common.c nor should we. Those should be allocator specific.
> >
> > I have similar thoughts on the issue. Lets keep the fast paths allocator
> > specific until we find a better way to handle this issue.
>
> Okay. I see.
> How about applying LTO not to the whole kernel code, but just to
> slab_common.o + sl[aou]b.o?
> I think that it may be possible, isn't it?

Well.... Andi: Is that possible?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
