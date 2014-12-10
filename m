Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2BC3A6B0073
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 11:39:21 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id a1so4109265wgh.23
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 08:39:20 -0800 (PST)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com. [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id gb7si21292817wib.29.2014.12.10.08.39.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Dec 2014 08:39:20 -0800 (PST)
Received: by mail-wi0-f181.google.com with SMTP id r20so5807038wiv.2
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 08:39:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141210163033.497862168@linux.com>
References: <20141210163017.092096069@linux.com>
	<20141210163033.497862168@linux.com>
Date: Wed, 10 Dec 2014 18:39:20 +0200
Message-ID: <CAOJsxLHBehVLj=xzPNKc_ndnqwBte9r9yj-rSsxatuFXa=N1ew@mail.gmail.com>
Subject: Re: [PATCH 1/7] slub: Remove __slab_alloc code duplication
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm <akpm@linuxfoundation.org>, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, Dec 10, 2014 at 6:30 PM, Christoph Lameter <cl@linux.com> wrote:
> Somehow the two branches in __slab_alloc do the same.
> Unify them.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>

Reviewed-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
