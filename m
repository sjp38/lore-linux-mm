Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id DA2726B0073
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 10:34:39 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id eu11so14349831pac.39
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 07:34:39 -0800 (PST)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id bf4si1479603pdb.162.2014.12.16.07.34.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Dec 2014 07:34:38 -0800 (PST)
Received: by mail-pd0-f174.google.com with SMTP id fp1so13991692pdb.5
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 07:34:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141216161521.1f72e102@redhat.com>
References: <20141210163017.092096069@linux.com>
	<20141210163033.717707217@linux.com>
	<20141215080338.GE4898@js1304-P5Q-DELUXE>
	<alpine.DEB.2.11.1412150815210.20101@gentwo.org>
	<20141216024210.GB23270@js1304-P5Q-DELUXE>
	<CAPAsAGyGXSP-2eY1CQS1jDpJq89kwpCuJm4ZBa3cYDGkv_oTxA@mail.gmail.com>
	<20141216082555.GA6088@js1304-P5Q-DELUXE>
	<alpine.DEB.2.11.1412160852460.27498@gentwo.org>
	<20141216161521.1f72e102@redhat.com>
Date: Tue, 16 Dec 2014 19:34:37 +0400
Message-ID: <CAPAsAGxE9kGdjKwU_9w=ZsC6gWq6fs-SKMrSX4mYhBAtdPZasQ@mail.gmail.com>
Subject: Re: [PATCH 3/7] slub: Do not use c->page on free
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, akpm@linuxfoundation.org, rostedt@goodmis.org, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>

2014-12-16 18:15 GMT+03:00 Jesper Dangaard Brouer <brouer@redhat.com>:
> On Tue, 16 Dec 2014 08:53:08 -0600 (CST)
> Christoph Lameter <cl@linux.com> wrote:
>
>> On Tue, 16 Dec 2014, Joonsoo Kim wrote:
>>
>> > > Like this:
>> > >
>> > >         return d > 0 && d < page->objects * s->size;
>> > >
>> >
>> > Yes! That's what I'm looking for.
>> > Christoph, how about above change?
>>
>> Ok but now there is a multiplication in the fast path.
>
> Could we pre-calculate the value (page->objects * s->size) and e.g store it
> in struct kmem_cache, thus saving the imul ?
>

No, one kmem_cache could have several pages with different orders,
therefore different page->objects.

> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Sr. Network Kernel Developer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
