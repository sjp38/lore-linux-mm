Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5FAC76B0070
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 09:53:12 -0500 (EST)
Received: by mail-ie0-f178.google.com with SMTP id tp5so13012815ieb.37
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 06:53:12 -0800 (PST)
Received: from resqmta-po-12v.sys.comcast.net (resqmta-po-12v.sys.comcast.net. [2001:558:fe16:19:96:114:154:171])
        by mx.google.com with ESMTPS id z5si1325553igl.33.2014.12.16.06.53.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 16 Dec 2014 06:53:11 -0800 (PST)
Date: Tue, 16 Dec 2014 08:53:08 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/7] slub: Do not use c->page on free
In-Reply-To: <20141216082555.GA6088@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.11.1412160852460.27498@gentwo.org>
References: <20141210163017.092096069@linux.com> <20141210163033.717707217@linux.com> <20141215080338.GE4898@js1304-P5Q-DELUXE> <alpine.DEB.2.11.1412150815210.20101@gentwo.org> <20141216024210.GB23270@js1304-P5Q-DELUXE> <CAPAsAGyGXSP-2eY1CQS1jDpJq89kwpCuJm4ZBa3cYDGkv_oTxA@mail.gmail.com>
 <20141216082555.GA6088@js1304-P5Q-DELUXE>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, akpm@linuxfoundation.org, rostedt@goodmis.org, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Jesper Dangaard Brouer <brouer@redhat.com>

On Tue, 16 Dec 2014, Joonsoo Kim wrote:

> > Like this:
> >
> >         return d > 0 && d < page->objects * s->size;
> >
>
> Yes! That's what I'm looking for.
> Christoph, how about above change?

Ok but now there is a multiplication in the fast path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
