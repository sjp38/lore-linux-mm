Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 705D36B02B4
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 13:14:01 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 8so159629464ity.10
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 10:14:01 -0700 (PDT)
Received: from mail-it0-x233.google.com (mail-it0-x233.google.com. [2607:f8b0:4001:c0b::233])
        by mx.google.com with ESMTPS id p21si15197762ioi.295.2017.07.26.10.14.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 10:14:00 -0700 (PDT)
Received: by mail-it0-x233.google.com with SMTP id v127so16664711itd.0
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 10:14:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1707261154140.9167@nuc-kabylake>
References: <20170706002718.GA102852@beast> <cdd42a1b-ce15-df8c-6bd1-b0943275986f@linux.com>
 <CAGXu5jKRDhvqj0TU10W10hsdixN2P+hHzpYfSVvOFZy=hW72Mg@mail.gmail.com>
 <alpine.DEB.2.20.1707260906230.6341@nuc-kabylake> <CAGXu5jLkOjDKSZ48jOyh2voP17xXMeEnqzV_=8dGSvFmqdCZCA@mail.gmail.com>
 <alpine.DEB.2.20.1707261154140.9167@nuc-kabylake>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 26 Jul 2017 10:13:59 -0700
Message-ID: <CAGXu5jLNeO-WmaQXp9z-+iw2sha-DXixtQ-fjQmahUkh0Hvxeg@mail.gmail.com>
Subject: Re: [v3] mm: Add SLUB free list pointer obfuscation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Alexander Popov <alex.popov@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Josh Triplett <josh@joshtriplett.org>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Tejun Heo <tj@kernel.org>, Daniel Mack <daniel@zonque.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Helge Deller <deller@gmx.de>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, Tycho Andersen <tycho@docker.com>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Wed, Jul 26, 2017 at 9:55 AM, Christopher Lameter <cl@linux.com> wrote:
> On Wed, 26 Jul 2017, Kees Cook wrote:
>
>> >> What happens if, instead of BUG_ON, we do:
>> >>
>> >> if (unlikely(WARN_RATELIMIT(object == fp, "double-free detected"))
>> >>         return;
>> >
>> > This may work for the free fastpath but the set_freepointer function is
>> > use in multiple other locations. Maybe just add this to the fastpath
>> > instead of to this fucnction?
>>
>> Do you mean do_slab_free()?
>
> Yes inserting these lines into do_slab_free() would simple ignore the
> double free operation in the fast path and that would be safe.
>
> Although in either case we are adding code to the fastpath...

While I'd like it unconditionally, I think Alexander's proposal was to
put it behind CONFIG_SLAB_FREELIST_HARDENED.

BTW, while I've got your attention, can you Ack the other patch? I
sent a v4 for the pointer obfuscation, which we really need:
https://lkml.org/lkml/2017/7/26/4

Thanks!

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
