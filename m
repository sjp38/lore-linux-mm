Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 74CFD6B0279
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 14:43:36 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id i71so63512268itf.2
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 11:43:36 -0700 (PDT)
Received: from mail-io0-x22a.google.com (mail-io0-x22a.google.com. [2607:f8b0:4001:c06::22a])
        by mx.google.com with ESMTPS id g24si3879169ioi.72.2017.07.07.11.43.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jul 2017 11:43:35 -0700 (PDT)
Received: by mail-io0-x22a.google.com with SMTP id r36so472747ioi.1
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 11:43:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1707071205490.14728@east.gentwo.org>
References: <20170706002718.GA102852@beast> <alpine.DEB.2.20.1707060841170.23867@east.gentwo.org>
 <CAGXu5jKHkKgF90LXbFvrc3fa2PAaaaYHvCbiBM-9aN16TrHL=g@mail.gmail.com>
 <alpine.DEB.2.20.1707061052380.26079@east.gentwo.org> <1499363602.26846.3.camel@redhat.com>
 <CAGXu5jKQJ=9B-uXV-+BB7Y0EQJ_Xpr3OvUHr6c57TceFvNkxbw@mail.gmail.com>
 <alpine.DEB.2.20.1707070844100.11769@east.gentwo.org> <CAGXu5jLmU2vrP2ftQd=EvC7-OEzV+Nm7zYEf=6C0kZuoUEBXvA@mail.gmail.com>
 <alpine.DEB.2.20.1707071205490.14728@east.gentwo.org>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 7 Jul 2017 11:43:33 -0700
Message-ID: <CAGXu5jKgE94uEbGG5vSLrbFLQ_PWySS5eO0_4CZ1azPSqqeF9g@mail.gmail.com>
Subject: Re: [PATCH v3] mm: Add SLUB free list pointer obfuscation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Josh Triplett <josh@joshtriplett.org>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Tejun Heo <tj@kernel.org>, Daniel Mack <daniel@zonque.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Helge Deller <deller@gmx.de>, Linux-MM <linux-mm@kvack.org>, Tycho Andersen <tycho@docker.com>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Fri, Jul 7, 2017 at 10:06 AM, Christoph Lameter <cl@linux.com> wrote:
> On Fri, 7 Jul 2017, Kees Cook wrote:
>
>> If we also added a >0 offset, that would make things even less
>> deterministic. Though I wonder if it would make the performance impact
>> higher. The XOR patch right now is very light.
>
> There would be barely any performance impact if you keep the offset within
> a cacheline since most objects start on a cacheline boundary. The
> processor has to fetch the cacheline anyways.

Sure, this seems like a nice additional bit of hardening, even if
we're limited to a cacheline. I'd still want to protect the spray and
index attacks though (which the XOR method covers), but we can do
both. We should keep them distinct patches, though. If you'll Ack the
XOR patch, I can poke at adding offset randomization?

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
