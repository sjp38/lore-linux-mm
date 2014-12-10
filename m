Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 455B86B0088
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 11:45:19 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id ex7so5821894wid.6
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 08:45:18 -0800 (PST)
Received: from mail-wg0-x236.google.com (mail-wg0-x236.google.com. [2a00:1450:400c:c00::236])
        by mx.google.com with ESMTPS id hc7si8409604wjc.87.2014.12.10.08.45.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Dec 2014 08:45:18 -0800 (PST)
Received: by mail-wg0-f54.google.com with SMTP id l2so4144442wgh.41
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 08:45:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141210163033.612898004@linux.com>
References: <20141210163017.092096069@linux.com>
	<20141210163033.612898004@linux.com>
Date: Wed, 10 Dec 2014 18:45:18 +0200
Message-ID: <CAOJsxLHk6jUej0kqBtUnjUbEKOfZDRaSLyG_f=TJm9ogLZbArA@mail.gmail.com>
Subject: Re: [PATCH 2/7] slub: Use page-mapping to store address of page frame
 like done in SLAB
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm <akpm@linuxfoundation.org>, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, Dec 10, 2014 at 6:30 PM, Christoph Lameter <cl@linux.com> wrote:
> SLAB uses the mapping field of the page struct to store a pointer to the
> begining of the objects in the page frame. Use the same field to store
> the address of the objects in SLUB as well. This allows us to avoid a
> number of invocations of page_address(). Those are mostly only used for
> debugging though so this should have no performance benefit.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>

Reviewed-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
