Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id C954F6B0292
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 13:54:19 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id m54so43720888qtb.9
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 10:54:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k6si5321251qkc.164.2017.06.29.10.54.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 10:54:19 -0700 (PDT)
Message-ID: <1498758853.6130.2.camel@redhat.com>
Subject: Re: [PATCH v2] mm: Add SLUB free list pointer obfuscation
From: Rik van Riel <riel@redhat.com>
Date: Thu, 29 Jun 2017 13:54:13 -0400
In-Reply-To: <CAGXu5jLLFKnboaLJKGcGT-Ra80ZzAf3jZ=zex6vd8uDQamBJxg@mail.gmail.com>
References: <20170623015010.GA137429@beast>
	 <CAGXu5jJEi_CS-CB=-4369TFRyeN4oQdmGS+HV-zoi4rSPpq3Jw@mail.gmail.com>
	 <alpine.DEB.2.20.1706291204460.17478@east.gentwo.org>
	 <CAGXu5jLLFKnboaLJKGcGT-Ra80ZzAf3jZ=zex6vd8uDQamBJxg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <labbott@redhat.com>, Daniel Micay <danielmicay@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Josh Triplett <josh@joshtriplett.org>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Tejun Heo <tj@kernel.org>, Daniel Mack <daniel@zonque.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Helge Deller <deller@gmx.de>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Thu, 2017-06-29 at 10:47 -0700, Kees Cook wrote:
> On Thu, Jun 29, 2017 at 10:05 AM, Christoph Lameter <cl@linux.com>
> wrote:
> > On Sun, 25 Jun 2017, Kees Cook wrote:
> > 
> > > The difference gets lost in the noise, but if the above is
> > > sensible,
> > > it's 0.07% slower. ;)
> > 
> > Hmmm... These differences add up. Also in a repetative benchmark
> > like that
> > you do not see the impact that the additional cacheline use in the
> > cpu
> > cache has on larger workloads. Those may be pushed over the edge of
> > l1 or
> > l2 capacity at some point which then causes drastic regressions.
> 
> Even if that is true, it may be worth it to some people to have the
> protection. Given that is significantly hampers a large class of heap
> overflow attacks[1], I think it's an important change to have. I'm
> not
> suggesting this be on by default, it's cleanly behind
> CONFIG-controlled macros, and is very limited in scope. If you can
> Ack
> it we can let system builders decide if they want to risk a possible
> performance hit. I'm pretty sure most distros would like to have this
> protection.

I could certainly see it being useful for all kinds of portable
and network-connected systems where security is simply much
more important than performance.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
