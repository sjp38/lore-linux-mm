Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 10C116B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 10:43:56 -0500 (EST)
Received: by mail-io0-f173.google.com with SMTP id g203so113177200iof.2
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 07:43:56 -0800 (PST)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id v4si14165684igd.0.2016.02.19.07.43.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 19 Feb 2016 07:43:55 -0800 (PST)
Date: Fri, 19 Feb 2016 09:43:54 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v1 8/8] mm: kasan: Initial memory quarantine
 implementation
In-Reply-To: <CACT4Y+Z60YxN6JKitsKLFfGFDFpVY3_rCPyz9m_3WtFeG+EbSQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1602190940320.8084@east.gentwo.org>
References: <cover.1453918525.git.glider@google.com> <1cec06645310eeb495bcae7bed0807dbf2235f3a.1453918525.git.glider@google.com> <20160201024715.GC32125@js1304-P5Q-DELUXE> <CAG_fn=W2C=aOgPQgkCi6ntA1tCMOaiF0LjbKtuo1TCFbH58HEg@mail.gmail.com>
 <CAAmzW4McCyLahXw2TV=OHBNwLSg2gq1Bq2n3mmaa7gLFEVGZ+w@mail.gmail.com> <CACT4Y+Z60YxN6JKitsKLFfGFDFpVY3_rCPyz9m_3WtFeG+EbSQ@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Joonsoo Kim <js1304@gmail.com>, Alexander Potapenko <glider@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrey Konovalov <adech.fo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Fri, 19 Feb 2016, Dmitry Vyukov wrote:

> No, this does not work. We've tried.
> The problem is fragmentation. When all memory is occupied by slab,
> it's already too late to reclaim memory. Free objects are randomly
> scattered over memory, so if you have just 1% of live objects, the
> chances are that you won't be able to reclaim any single page.

Yes that is why slab objects *need* to be *movable*!!!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
