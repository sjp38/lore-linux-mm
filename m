Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4B3756B008C
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 11:59:12 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id y19so4176610wgg.14
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 08:59:11 -0800 (PST)
Received: from mail-wg0-x233.google.com (mail-wg0-x233.google.com. [2a00:1450:400c:c00::233])
        by mx.google.com with ESMTPS id gp6si9235862wib.41.2014.12.10.08.59.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Dec 2014 08:59:11 -0800 (PST)
Received: by mail-wg0-f51.google.com with SMTP id x12so4135699wgg.38
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 08:59:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141210163033.970247616@linux.com>
References: <20141210163017.092096069@linux.com>
	<20141210163033.970247616@linux.com>
Date: Wed, 10 Dec 2014 18:59:11 +0200
Message-ID: <CAOJsxLFEMDwqGtSOBG-6Yjfk7NEzK9pQeTeGuzZFQ=F4Pqmx0Q@mail.gmail.com>
Subject: Re: [PATCH 5/7] slub: Use end_token instead of NULL to terminate freelists
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm <akpm@linuxfoundation.org>, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, Dec 10, 2014 at 6:30 PM, Christoph Lameter <cl@linux.com> wrote:
> Ending a list with NULL means that the termination of a list is the same
> for all slab pages. The pointers of freelists otherwise always are
> pointing to the address space of the page. Make termination of a
> list possible by setting the lowest bit in the freelist address
> and use the start address of a page if no other address is available
> for list termination.
>
> This will allow us to determine the page struct address from a
> freelist pointer in the future.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>

Reviewed-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
