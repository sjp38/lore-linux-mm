Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 49B856B0082
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 12:32:26 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id y19so4263734wgg.14
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 09:32:25 -0800 (PST)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com. [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id j6si88071wiz.3.2014.12.10.09.32.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Dec 2014 09:32:25 -0800 (PST)
Received: by mail-wi0-f181.google.com with SMTP id r20so5971267wiv.8
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 09:32:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1412101107350.6291@gentwo.org>
References: <20141210163017.092096069@linux.com>
	<20141210163033.717707217@linux.com>
	<CAOJsxLFEN_w7q6NvbxkH2KTujB9auLkQgskLnGtN9iBQ4hV9sw@mail.gmail.com>
	<alpine.DEB.2.11.1412101107350.6291@gentwo.org>
Date: Wed, 10 Dec 2014 19:32:25 +0200
Message-ID: <CAOJsxLH4BGT9rGgg_4nxUMgW3sdEzLrmX2WtM8Ld3aytdR5e8g@mail.gmail.com>
Subject: Re: [PATCH 3/7] slub: Do not use c->page on free
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm <akpm@linuxfoundation.org>, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, Dec 10, 2014 at 7:08 PM, Christoph Lameter <cl@linux.com> wrote:
>> > +{
>> > +       long d = p - page->address;
>> > +
>> > +       return d > 0 && d < (1 << MAX_ORDER) && d < (compound_order(page) << PAGE_SHIFT);
>> > +}
>>
>> Can you elaborate on what this is doing? I don't really understand it.
>
> Checks if the pointer points to the slab page. Also it tres to avoid
> having to call compound_order needlessly. Not sure if that optimization is
> worth it.

Aah, it's the (1 << MAX_ORDER) optimization that confused me. Perhaps
add a comment there to make it more obvious?

I'm fine with the optimization:

Reviewed-by: Pekka Enberg <penberg@kernel.org>

- Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
