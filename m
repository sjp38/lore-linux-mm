Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f49.google.com (mail-yh0-f49.google.com [209.85.213.49])
	by kanga.kvack.org (Postfix) with ESMTP id CFD9C6B0073
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 10:15:37 -0500 (EST)
Received: by mail-yh0-f49.google.com with SMTP id f10so6138741yha.8
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 07:15:37 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y3si1076099qai.115.2014.12.16.07.15.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Dec 2014 07:15:36 -0800 (PST)
Date: Tue, 16 Dec 2014 16:15:21 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 3/7] slub: Do not use c->page on free
Message-ID: <20141216161521.1f72e102@redhat.com>
In-Reply-To: <alpine.DEB.2.11.1412160852460.27498@gentwo.org>
References: <20141210163017.092096069@linux.com>
	<20141210163033.717707217@linux.com>
	<20141215080338.GE4898@js1304-P5Q-DELUXE>
	<alpine.DEB.2.11.1412150815210.20101@gentwo.org>
	<20141216024210.GB23270@js1304-P5Q-DELUXE>
	<CAPAsAGyGXSP-2eY1CQS1jDpJq89kwpCuJm4ZBa3cYDGkv_oTxA@mail.gmail.com>
	<20141216082555.GA6088@js1304-P5Q-DELUXE>
	<alpine.DEB.2.11.1412160852460.27498@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, akpm@linuxfoundation.org, rostedt@goodmis.org, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, brouer@redhat.com

On Tue, 16 Dec 2014 08:53:08 -0600 (CST)
Christoph Lameter <cl@linux.com> wrote:

> On Tue, 16 Dec 2014, Joonsoo Kim wrote:
> 
> > > Like this:
> > >
> > >         return d > 0 && d < page->objects * s->size;
> > >
> >
> > Yes! That's what I'm looking for.
> > Christoph, how about above change?
> 
> Ok but now there is a multiplication in the fast path.

Could we pre-calculate the value (page->objects * s->size) and e.g store it
in struct kmem_cache, thus saving the imul ?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
