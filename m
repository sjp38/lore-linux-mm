Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 7E7EB6B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 21:47:52 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so43919989ioi.2
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 18:47:52 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id k125si8367965ioe.203.2015.09.09.18.47.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 09 Sep 2015 18:47:51 -0700 (PDT)
Date: Wed, 9 Sep 2015 20:47:50 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Store Buffers (was Re: Is it OK to pass non-acquired objects to
 kfree?)
In-Reply-To: <20150910011028.GY4029@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.11.1509092047060.3588@east.gentwo.org>
References: <CACT4Y+b_wDnC3mONjmq+F9kaw1_L_8z=E__1n25ZgLhx-biEmQ@mail.gmail.com> <alpine.DEB.2.11.1509091036590.19663@east.gentwo.org> <CACT4Y+a6rjbEoP7ufgyJimjx3qVh81TToXjL9Rnj-bHNregZXg@mail.gmail.com> <alpine.DEB.2.11.1509091251150.20311@east.gentwo.org>
 <20150909184415.GJ4029@linux.vnet.ibm.com> <alpine.DEB.2.11.1509091346230.20665@east.gentwo.org> <20150909203642.GO4029@linux.vnet.ibm.com> <alpine.DEB.2.11.1509091812500.21983@east.gentwo.org> <20150910000847.GV4029@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1509091917560.22381@east.gentwo.org> <20150910011028.GY4029@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>

On Wed, 9 Sep 2015, Paul E. McKenney wrote:

> > But then again kfree() contains a barrier() which would block the compiler
> > from moving anything into the free path.
>
> That barrier() is implicit in the fact that kfree() is an external
> function?  Or are my eyes failing me?

kfree at some point calls slab_free(). That function has a barrier. All
free operations go through it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
