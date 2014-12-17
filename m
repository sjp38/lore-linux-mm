Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5EE286B0070
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 02:15:36 -0500 (EST)
Received: by mail-ob0-f170.google.com with SMTP id wp18so2450223obc.1
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 23:15:36 -0800 (PST)
Received: from mail-ob0-x235.google.com (mail-ob0-x235.google.com. [2607:f8b0:4003:c01::235])
        by mx.google.com with ESMTPS id o126si1855264oig.56.2014.12.16.23.15.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Dec 2014 23:15:35 -0800 (PST)
Received: by mail-ob0-f181.google.com with SMTP id gq1so2392489obb.12
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 23:15:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1412160948240.27999@gentwo.org>
References: <20141210163017.092096069@linux.com>
	<20141210163033.717707217@linux.com>
	<20141215080338.GE4898@js1304-P5Q-DELUXE>
	<alpine.DEB.2.11.1412150815210.20101@gentwo.org>
	<20141216024210.GB23270@js1304-P5Q-DELUXE>
	<CAPAsAGyGXSP-2eY1CQS1jDpJq89kwpCuJm4ZBa3cYDGkv_oTxA@mail.gmail.com>
	<20141216082555.GA6088@js1304-P5Q-DELUXE>
	<alpine.DEB.2.11.1412160852460.27498@gentwo.org>
	<20141216161521.1f72e102@redhat.com>
	<alpine.DEB.2.11.1412160948240.27999@gentwo.org>
Date: Wed, 17 Dec 2014 16:15:34 +0900
Message-ID: <CAAmzW4MaGCCq4_pz+9dFDY+0X+3qcfr4aTSPsjt8ejkV9WbMnA@mail.gmail.com>
Subject: Re: [PATCH 3/7] slub: Do not use c->page on free
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, akpm@linuxfoundation.org, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>

2014-12-17 0:48 GMT+09:00 Christoph Lameter <cl@linux.com>:
> On Tue, 16 Dec 2014, Jesper Dangaard Brouer wrote:
>
>> > Ok but now there is a multiplication in the fast path.
>>
>> Could we pre-calculate the value (page->objects * s->size) and e.g store it
>> in struct kmem_cache, thus saving the imul ?
>
> I think I just used the last available field for the page->address.

Possibly, we can use _count field.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
