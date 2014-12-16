Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id B63F96B0075
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 10:48:46 -0500 (EST)
Received: by mail-qg0-f41.google.com with SMTP id j5so10460690qga.14
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 07:48:46 -0800 (PST)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id f51si1187785qga.113.2014.12.16.07.48.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 16 Dec 2014 07:48:45 -0800 (PST)
Date: Tue, 16 Dec 2014 09:48:43 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/7] slub: Do not use c->page on free
In-Reply-To: <20141216161521.1f72e102@redhat.com>
Message-ID: <alpine.DEB.2.11.1412160948240.27999@gentwo.org>
References: <20141210163017.092096069@linux.com> <20141210163033.717707217@linux.com> <20141215080338.GE4898@js1304-P5Q-DELUXE> <alpine.DEB.2.11.1412150815210.20101@gentwo.org> <20141216024210.GB23270@js1304-P5Q-DELUXE> <CAPAsAGyGXSP-2eY1CQS1jDpJq89kwpCuJm4ZBa3cYDGkv_oTxA@mail.gmail.com>
 <20141216082555.GA6088@js1304-P5Q-DELUXE> <alpine.DEB.2.11.1412160852460.27498@gentwo.org> <20141216161521.1f72e102@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, akpm@linuxfoundation.org, rostedt@goodmis.org, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>

On Tue, 16 Dec 2014, Jesper Dangaard Brouer wrote:

> > Ok but now there is a multiplication in the fast path.
>
> Could we pre-calculate the value (page->objects * s->size) and e.g store it
> in struct kmem_cache, thus saving the imul ?

I think I just used the last available field for the page->address.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
