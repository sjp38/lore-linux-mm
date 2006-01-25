Received: by uproxy.gmail.com with SMTP id k40so112392ugc
        for <linux-mm@kvack.org>; Wed, 25 Jan 2006 02:30:03 -0800 (PST)
Message-ID: <84144f020601250230s2d5da5d9jf11f754f184d495b@mail.gmail.com>
Date: Wed, 25 Jan 2006 12:30:03 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [RFC] non-refcounted pages, application to slab?
In-Reply-To: <20060125093909.GE32653@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20060125093909.GE32653@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Nick,

On 1/25/06, Nick Piggin <npiggin@suse.de> wrote:
> This is probably not worthwhile for most cases, but slab did strike me
> as a potential candidate (however the complication here is that some
> code I think uses the refcount of underlying pages of slab allocations
> eg nommu code). So it is not a complete patch, but I wonder if anyone
> thinks the savings might be worth the complexity?
>
> Is there any particular code that is really heavy on slab allocations?
> That isn't mostly handled by the slab's internal freelists?

I certainly hope not. For heavy users, the slab allocator should grow
caches enough to satisfy most allocations from the them. Also, I think
we want to keep the reference counting for slab pages so that we can
use kmalloc'd memory in the block layer.

                                Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
