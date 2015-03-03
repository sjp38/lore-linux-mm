Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id BAA486B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 11:42:10 -0500 (EST)
Received: by mail-qg0-f42.google.com with SMTP id z60so12982650qgd.1
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 08:42:10 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id e5si989649qga.58.2015.03.03.08.42.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 03 Mar 2015 08:42:09 -0800 (PST)
Date: Tue, 3 Mar 2015 10:42:07 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] slub memory quarantine
In-Reply-To: <54F5D5CC.6070901@samsung.com>
Message-ID: <alpine.DEB.2.11.1503031041340.14643@gentwo.org>
References: <54F57716.80809@samsung.com> <CACT4Y+YQ3cuUvRrT_19RbxFVWHGnzviSFi0-ud88jq9g9jUZog@mail.gmail.com> <54F5D5CC.6070901@samsung.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Sasha Levin <sasha.levin@oracle.com>, Dmitry Chernenkov <dmitryc@google.com>, Konstantin Khlebnikov <koct9i@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, 3 Mar 2015, Andrey Ryabinin wrote:

> On 03/03/2015 12:10 PM, Dmitry Vyukov wrote:
> > Please hold on with this.
> > Dmitry Chernenkov is working on a quarantine that works with both slub
> > and slab, does not cause spurious OOMs and does not depend on
> > slub-debug which has unacceptable performance (acquires global lock).
>
> I think that it's a separate issue. KASan already depend on slub_debug - it required for redzones/user tracking.
> I think that some parts slub debugging (like user tracking and this quarantine)
> could be moved (for CONFIG_KASAN=y) to the fast path without any locking.

In general these features need to be ifdeffed out since they add
significant overhead for the data structures and execution paths.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
