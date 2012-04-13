Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id BF7496B004D
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 14:27:32 -0400 (EDT)
Date: Fri, 13 Apr 2012 13:27:30 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: how to avoid allocating or freeze MOVABLE memory in userspace
In-Reply-To: <CAN1soZzEuhQQYf7fNqOeMYT3Z-8VMix+1ihD77Bjtf+Do3x3DA@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1204131326170.15905@router.home>
References: <CAN1soZzEuhQQYf7fNqOeMYT3Z-8VMix+1ihD77Bjtf+Do3x3DA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Haojian Zhuang <haojian.zhuang@gmail.com>
Cc: linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, m.szyprowski@samsung.com

On Fri, 13 Apr 2012, Haojian Zhuang wrote:

> I have one question on memory migration. As we know, malloc() from
> user app will allocate MIGRATE_MOVABLE pages. But if we want to use
> this memory as DMA usage, we can't accept MIGRATE_MOVABLE type. Could
> we change its behavior before DMA working?

MIGRATE_MOVABLE works fine for DMA. If you keep a reference from a device
driver to user pages then you will have to increase the page refcount
which will in turn pin the page and make it non movable for as long as you
keep the refcount.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
