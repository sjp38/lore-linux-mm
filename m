Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 94BEB6B0258
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 12:37:05 -0400 (EDT)
Received: by qgt47 with SMTP id 47so40048474qgt.2
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 09:37:05 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id j31si13842994qgj.124.2015.09.10.09.37.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 10 Sep 2015 09:37:04 -0700 (PDT)
Date: Thu, 10 Sep 2015 11:37:02 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Store Buffers (was Re: Is it OK to pass non-acquired objects to
 kfree?)
In-Reply-To: <55F13387.4030803@suse.cz>
Message-ID: <alpine.DEB.2.11.1509101136210.9501@east.gentwo.org>
References: <CACT4Y+b_wDnC3mONjmq+F9kaw1_L_8z=E__1n25ZgLhx-biEmQ@mail.gmail.com> <alpine.DEB.2.11.1509091036590.19663@east.gentwo.org> <CACT4Y+a6rjbEoP7ufgyJimjx3qVh81TToXjL9Rnj-bHNregZXg@mail.gmail.com> <alpine.DEB.2.11.1509091251150.20311@east.gentwo.org>
 <20150909184415.GJ4029@linux.vnet.ibm.com> <alpine.DEB.2.11.1509091346230.20665@east.gentwo.org> <20150909203642.GO4029@linux.vnet.ibm.com> <alpine.DEB.2.11.1509091812500.21983@east.gentwo.org> <20150910000847.GV4029@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1509091917560.22381@east.gentwo.org> <20150910011028.GY4029@linux.vnet.ibm.com> <alpine.DEB.2.11.1509092047060.3588@east.gentwo.org> <55F13387.4030803@suse.cz>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Dmitry Vyukov <dvyukov@google.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>

On Thu, 10 Sep 2015, Vlastimil Babka wrote:

> > kfree at some point calls slab_free(). That function has a barrier. All
> > free operations go through it.
>
> SLAB doesn't have such barrier AFAICS. It will put the object on per-cpu cache
> and that's it. Only flushing the full cache takes a spin lock.

SLAB disables and enables interrupts. Isnt that also considered a form of
barrier?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
