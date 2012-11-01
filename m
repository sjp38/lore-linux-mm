Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 56BB66B0083
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 17:03:22 -0400 (EDT)
Date: Thu, 1 Nov 2012 21:03:20 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: CK4 [00/15] Sl[auo]b: Common kmalloc caches V4
In-Reply-To: <CALF0-+Wmg+BbrzNBW0vUaskRJkL965CZh5mDvqYKj+z7m+iVWA@mail.gmail.com>
Message-ID: <0000013abdc90c92-f1c89a3b-326e-4b93-b77f-88bed6184015-000000@email.amazonses.com>
References: <0000013a934eed6d-a9c1b247-dbbc-485d-b7cf-89aa36dcca57-000000@email.amazonses.com> <CALF0-+UUREQZT1NEBq-V_04WBDOt6GccDkHB+zPXW6u6uhvj=Q@mail.gmail.com> <0000013abda5ae3c-f1f548fb-4878-4ae2-8f5a-bfad5922cf04-000000@email.amazonses.com>
 <CALF0-+Wmg+BbrzNBW0vUaskRJkL965CZh5mDvqYKj+z7m+iVWA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Thu, 1 Nov 2012, Ezequiel Garcia wrote:

> On Thu, Nov 1, 2012 at 5:24 PM, Christoph Lameter <cl@linux.com> wrote:
> > On Thu, 1 Nov 2012, Ezequiel Garcia wrote:
> >
> >> While testing this patchset, I found a BUG.
> >>
> >> All I did was "sudo mount -a" to mount my development partitions.
> >>
> >> [   25.366266] BUG: unable to handle kernel paging request at ffffffc0
> >> [   25.366419] IP: [<c10d93b2>] slab_unmergeable+0x12/0x30
> >
> > Arg. More sysfs trouble I guess. Sysfs is the cause for a lot of slub
> > fragility. Sigh.
> >
> > Can you rerun this with "slub_debug" as a kernel option?
>
> I will.
>
> Also I will test *without* a few patches I was playing around with...
> I should have done that before reporting :/
> Until then, please consider this noise, just in case.

Well found it. The create common boot functions patch (#2) did a list add
of a structure that was moved later during slub bootstrap. Fix will come
wiht V5.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
