Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 3D3AF6B0072
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 16:24:45 -0400 (EDT)
Date: Thu, 1 Nov 2012 20:24:43 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: CK4 [00/15] Sl[auo]b: Common kmalloc caches V4
In-Reply-To: <CALF0-+UUREQZT1NEBq-V_04WBDOt6GccDkHB+zPXW6u6uhvj=Q@mail.gmail.com>
Message-ID: <0000013abda5ae3c-f1f548fb-4878-4ae2-8f5a-bfad5922cf04-000000@email.amazonses.com>
References: <0000013a934eed6d-a9c1b247-dbbc-485d-b7cf-89aa36dcca57-000000@email.amazonses.com> <CALF0-+UUREQZT1NEBq-V_04WBDOt6GccDkHB+zPXW6u6uhvj=Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Thu, 1 Nov 2012, Ezequiel Garcia wrote:

> While testing this patchset, I found a BUG.
>
> All I did was "sudo mount -a" to mount my development partitions.
>
> [   25.366266] BUG: unable to handle kernel paging request at ffffffc0
> [   25.366419] IP: [<c10d93b2>] slab_unmergeable+0x12/0x30

Arg. More sysfs trouble I guess. Sysfs is the cause for a lot of slub
fragility. Sigh.

Can you rerun this with "slub_debug" as a kernel option?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
