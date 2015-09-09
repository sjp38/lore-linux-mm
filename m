Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id A12216B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 19:31:04 -0400 (EDT)
Received: by qkap81 with SMTP id p81so11782288qka.2
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 16:31:04 -0700 (PDT)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id a51si10626366qge.64.2015.09.09.16.31.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 09 Sep 2015 16:31:04 -0700 (PDT)
Date: Wed, 9 Sep 2015 18:31:02 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Is it OK to pass non-acquired objects to kfree?
In-Reply-To: <20150909203642.GO4029@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.11.1509091823360.21983@east.gentwo.org>
References: <CACT4Y+bvaJ6cC_=A1VGx=cT_bkB-teXNud0Wgt33E1AtBYNTSg@mail.gmail.com> <alpine.DEB.2.11.1509090901480.18992@east.gentwo.org> <CACT4Y+ZpToAmaboGDvFhgWUqtnUcJACprg=XSTkrJYE4DQ1jcA@mail.gmail.com> <alpine.DEB.2.11.1509090930510.19262@east.gentwo.org>
 <CACT4Y+b_wDnC3mONjmq+F9kaw1_L_8z=E__1n25ZgLhx-biEmQ@mail.gmail.com> <alpine.DEB.2.11.1509091036590.19663@east.gentwo.org> <CACT4Y+a6rjbEoP7ufgyJimjx3qVh81TToXjL9Rnj-bHNregZXg@mail.gmail.com> <alpine.DEB.2.11.1509091251150.20311@east.gentwo.org>
 <20150909184415.GJ4029@linux.vnet.ibm.com> <alpine.DEB.2.11.1509091346230.20665@east.gentwo.org> <20150909203642.GO4029@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>

On Wed, 9 Sep 2015, Paul E. McKenney wrote:

> Either way, Dmitry's tool got a hit on real code using the slab
> allocators.  If that hit is a false positive, then clearly Dmitry
> needs to fix his tool, however, I am not (yet) convinced that it is a
> false positive.  If it is not a false positive, we might well need to
> articulate the rules for use of the slab allocators.

Could I get a clear definiton as to what exactly is positive? Was this
using SLAB, SLUB or SLOB?

> > This would all use per cpu data. As soon as a handoff is required within
> > the allocators locks are being used. So I would say no.
>
> As in "no, it is not necessary for the caller of kfree() to invoke barrier()
> in this example", right?

Actually SLUB contains a barrier already in kfree(). Has to be there
because of the way the per cpu pointer is being handled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
