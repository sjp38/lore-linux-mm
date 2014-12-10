Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9CD226B0080
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 12:29:46 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id a1so4241299wgh.23
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 09:29:46 -0800 (PST)
Received: from mail-wg0-x229.google.com (mail-wg0-x229.google.com. [2a00:1450:400c:c00::229])
        by mx.google.com with ESMTPS id hr5si8517514wjb.150.2014.12.10.09.29.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Dec 2014 09:29:45 -0800 (PST)
Received: by mail-wg0-f41.google.com with SMTP id y19so4293017wgg.0
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 09:29:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141210163034.078015357@linux.com>
References: <20141210163017.092096069@linux.com>
	<20141210163034.078015357@linux.com>
Date: Wed, 10 Dec 2014 19:29:45 +0200
Message-ID: <CAOJsxLGtqtDSvvSXnQBGdXFfX_osWKuQ5R8Q0ai0VMv2hQC3eg@mail.gmail.com>
Subject: Re: [PATCH 6/7] slub: Drop ->page field from kmem_cache_cpu
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm <akpm@linuxfoundation.org>, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, Dec 10, 2014 at 6:30 PM, Christoph Lameter <cl@linux.com> wrote:
> Dropping the page field is possible since the page struct address
> of an object or a freelist pointer can now always be calcualted from
> the address. No freelist pointer will be NULL anymore so use
> NULL to signify the condition that the current cpu has no
> percpu slab attached to it.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>

Reviewed-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
