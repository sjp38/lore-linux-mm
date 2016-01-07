Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id E831A828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 13:54:09 -0500 (EST)
Received: by mail-io0-f181.google.com with SMTP id 1so215052296ion.1
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 10:54:09 -0800 (PST)
Received: from mail-io0-x22c.google.com (mail-io0-x22c.google.com. [2607:f8b0:4001:c06::22c])
        by mx.google.com with ESMTPS id j10si23040849igx.27.2016.01.07.10.54.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jan 2016 10:54:09 -0800 (PST)
Received: by mail-io0-x22c.google.com with SMTP id g73so64031626ioe.3
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 10:54:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160107140253.28907.5469.stgit@firesoul>
References: <20160107140253.28907.5469.stgit@firesoul>
Date: Thu, 7 Jan 2016 10:54:08 -0800
Message-ID: <CA+55aFxHeOsbhp2Ef7BQ0=wXVeX6jKZbP989t7xYy5KSKj2=6Q@mail.gmail.com>
Subject: Re: [PATCH 00/10] MM: More bulk API work
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu, Jan 7, 2016 at 6:03 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> This series contain three aspects:
>  1. cleanup and code sharing between SLUB and SLAB
>  2. implementing accelerated bulk API for SLAB allocator
>  3. new API kfree_bulk()

FWIW, looks ok to me from a quick patch read-through. Nothing raises
my hackles like happened with the old slab work.

           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
