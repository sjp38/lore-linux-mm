Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C86436B02F4
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 13:47:29 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 188so14708541itx.9
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 10:47:29 -0700 (PDT)
Received: from mail-io0-x22d.google.com (mail-io0-x22d.google.com. [2607:f8b0:4001:c06::22d])
        by mx.google.com with ESMTPS id x1si3920178ite.85.2017.06.29.10.47.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 10:47:29 -0700 (PDT)
Received: by mail-io0-x22d.google.com with SMTP id r36so11373268ioi.1
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 10:47:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1706291204460.17478@east.gentwo.org>
References: <20170623015010.GA137429@beast> <CAGXu5jJEi_CS-CB=-4369TFRyeN4oQdmGS+HV-zoi4rSPpq3Jw@mail.gmail.com>
 <alpine.DEB.2.20.1706291204460.17478@east.gentwo.org>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 29 Jun 2017 10:47:27 -0700
Message-ID: <CAGXu5jLLFKnboaLJKGcGT-Ra80ZzAf3jZ=zex6vd8uDQamBJxg@mail.gmail.com>
Subject: Re: [PATCH v2] mm: Add SLUB free list pointer obfuscation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <labbott@redhat.com>, Daniel Micay <danielmicay@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Josh Triplett <josh@joshtriplett.org>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Tejun Heo <tj@kernel.org>, Daniel Mack <daniel@zonque.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Helge Deller <deller@gmx.de>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Thu, Jun 29, 2017 at 10:05 AM, Christoph Lameter <cl@linux.com> wrote:
> On Sun, 25 Jun 2017, Kees Cook wrote:
>
>> The difference gets lost in the noise, but if the above is sensible,
>> it's 0.07% slower. ;)
>
> Hmmm... These differences add up. Also in a repetative benchmark like that
> you do not see the impact that the additional cacheline use in the cpu
> cache has on larger workloads. Those may be pushed over the edge of l1 or
> l2 capacity at some point which then causes drastic regressions.

Even if that is true, it may be worth it to some people to have the
protection. Given that is significantly hampers a large class of heap
overflow attacks[1], I think it's an important change to have. I'm not
suggesting this be on by default, it's cleanly behind
CONFIG-controlled macros, and is very limited in scope. If you can Ack
it we can let system builders decide if they want to risk a possible
performance hit. I'm pretty sure most distros would like to have this
protection.

Thanks for looking it over!

-Kees

[1] http://resources.infosecinstitute.com/exploiting-linux-kernel-heap-corruptions-slub-allocator/

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
