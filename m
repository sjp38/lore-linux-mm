Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22F0BC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 18:20:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1E0E218C3
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 18:20:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="ZRFeFu8F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1E0E218C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 763176B0003; Wed, 20 Mar 2019 14:20:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 73AA76B0006; Wed, 20 Mar 2019 14:20:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 62A106B0007; Wed, 20 Mar 2019 14:20:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 34F216B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 14:20:37 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id l10so19475682qkj.22
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 11:20:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=K1oZPjp4GkcjqhAlXwpdoC8QkuglFFzbfMFyEVG/ri8=;
        b=FepNv3kk5YXY3AIoI0xmkqTpYu/wsNG4B7Uj0JzzFVdqgEB4wF73Arv0Rkdf18q2EW
         E0Ya2lt8Utf4HyexRbeo0L7jCis8/ASG3QJ20moBr7ne9ogKZ9XoKAFPb8CxmtQ0e2Xu
         TtMd+9FLxeID+FDNi/tN5iZGyrZZ7sTO/pHHhhhh9tSq3LELUfjkLkhVUUXj93KV87Jz
         ndLzWivmujl2Uha4a5CDZNYdQqDJ5mvM8muCb/833YVhnnQ3kkC3fryWAGcuCDtd4Lpp
         9qBKKy95gHQRch44vxRpFC5Txrm2ub608bYo47ZI371zFZ8vsXp1iRd6uTXXC7k8NOPD
         FXbw==
X-Gm-Message-State: APjAAAVUA1pAOqaPYr0eBnWA3BAmvFdI0Djt2E1grezM18R/UG/RWR+1
	45fe4wq8AfXdRrD9wSs5pBYUO6LgAZM4AtfhYkqKy0O0JsG/Pz0KDcaZ83/Y39eC0u4RCO5zPhk
	ac8DCp2+/e9xpIkuH/+ZC7c+yiQc1a92e/p1aQR7lPO9yaa0OYtYrUdm7cmhyIVI=
X-Received: by 2002:a0c:83a5:: with SMTP id k34mr7775602qva.17.1553106036947;
        Wed, 20 Mar 2019 11:20:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyOerWSPlq95i64/j0OT9PNzl60DNkvqL61K9YLOsFiuqvkZjNKVvI73lWUEoCiaC5flIjk
X-Received: by 2002:a0c:83a5:: with SMTP id k34mr7775564qva.17.1553106036256;
        Wed, 20 Mar 2019 11:20:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553106036; cv=none;
        d=google.com; s=arc-20160816;
        b=amGRM05FGm3p7zPBdSM/T+Us0TKJ1ygJ5vJRQbnZBal3d/i3prKrqEWXyoXTxcQkij
         4YIOW89A26i2s+d5bZbMQDppOqacT5nbiH3nSI+p7mkRA2K9MVRj+13bxDcOhgdPz2hX
         jkE4v0H5O/C2WbzJVtms8f9ytvvQvNlqsc3mHmQvvFDOGn16Deky5C90umG8CmR0nk4e
         VDN4Erf7jCbz7+KhiHfkeahAW+I8WiJ6FJ0shrPOkL/fwSz67hu9G+5j2gpiiPNCepmp
         OUzgD+2tBALF0ZlAujS9Fbm9EemrWbArS770Bl4X1hklAQ/nQwujNbObf6gQFZbqF0pG
         Xsog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=K1oZPjp4GkcjqhAlXwpdoC8QkuglFFzbfMFyEVG/ri8=;
        b=MmTGIirxz4zxJrnzyaBV0yOCy8MNeQBYgcADGWifeVtVZ8qiGkCsUXY4CludS8haxZ
         7eTL8IOqAdn20rMIQWLJKihw7IIejGAZJ0FAiF3UqJu/tIX940rWNiRgSbRQUtt7Zits
         Zd8bMfWRGCt5l7BY+oOnkl+h4+RPz2YvHkk7LZoSewp5P9VQ6J/jqYZf6dAirPUrQrvn
         Mv/NsQjzrgFDKo2o3onmvZSZp9nh2h9EJuK1n6FGQmcMyrAAVkIr5Ti5gP6d3YOSaJat
         Nc23u2i1JXSodCd72XYaXsb6djYU47zHvuEYgekef1Iq6ch79CPxyoE8NG20tk+sjKFQ
         grxg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=ZRFeFu8F;
       spf=pass (google.com: domain of 010001699c5563f8-36c6909f-ed43-4839-82da-b5f9f21594b8-000000@amazonses.com designates 54.240.9.37 as permitted sender) smtp.mailfrom=010001699c5563f8-36c6909f-ed43-4839-82da-b5f9f21594b8-000000@amazonses.com
Received: from a9-37.smtp-out.amazonses.com (a9-37.smtp-out.amazonses.com. [54.240.9.37])
        by mx.google.com with ESMTPS id k96si1574211qte.147.2019.03.20.11.20.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 20 Mar 2019 11:20:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of 010001699c5563f8-36c6909f-ed43-4839-82da-b5f9f21594b8-000000@amazonses.com designates 54.240.9.37 as permitted sender) client-ip=54.240.9.37;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=ZRFeFu8F;
       spf=pass (google.com: domain of 010001699c5563f8-36c6909f-ed43-4839-82da-b5f9f21594b8-000000@amazonses.com designates 54.240.9.37 as permitted sender) smtp.mailfrom=010001699c5563f8-36c6909f-ed43-4839-82da-b5f9f21594b8-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1553106035;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=K1oZPjp4GkcjqhAlXwpdoC8QkuglFFzbfMFyEVG/ri8=;
	b=ZRFeFu8FwB5PFoGiDISVj+TujSsdT5LxaFcBw24dBiAw3s8dX/ozHAP1goU14WUg
	89KwN2HZZEh3k+MaWDIK1WvM+y2GhhhEygM0P19pgj3L/y0/W4HuxQZDM2NFI52YXiI
	kp0kPy8HrfMfhkCmTppF60aC/AJ380WhvTMj0UOo=
Date: Wed, 20 Mar 2019 18:20:35 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Vlastimil Babka <vbabka@suse.cz>
cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, 
    David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
    Ming Lei <ming.lei@redhat.com>, Dave Chinner <david@fromorbit.com>, 
    Matthew Wilcox <willy@infradead.org>, 
    "Darrick J . Wong" <darrick.wong@oracle.com>, 
    Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@kernel.org>, 
    linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, 
    linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Subject: Re: [RFC 0/2] guarantee natural alignment for kmalloc()
In-Reply-To: <5d7fee9c-1a80-6ac9-ac1d-b1ce05ed27a8@suse.cz>
Message-ID: <010001699c5563f8-36c6909f-ed43-4839-82da-b5f9f21594b8-000000@email.amazonses.com>
References: <20190319211108.15495-1-vbabka@suse.cz> <01000169988d4e34-b4178f68-c390-472b-b62f-a57a4f459a76-000000@email.amazonses.com> <5d7fee9c-1a80-6ac9-ac1d-b1ce05ed27a8@suse.cz>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.03.20-54.240.9.37
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 20 Mar 2019, Vlastimil Babka wrote:

> > This means that the alignments are no longer uniform for all kmalloc
> > caches and we get back to code making all sorts of assumptions about
> > kmalloc alignments.
>
> Natural alignment to size is rather well defined, no? Would anyone ever
> assume a larger one, for what reason?
> It's now where some make assumptions (even unknowingly) for natural
> There are two 'odd' sizes 96 and 192, which will keep cacheline size
> alignment, would anyone really expect more than 64 bytes?

I think one would expect one set of alighment for any kmalloc object.

> > Currently all kmalloc objects are aligned to KMALLOC_MIN_ALIGN. That will
> > no longer be the case and alignments will become inconsistent.
>
> KMALLOC_MIN_ALIGN is still the minimum, but in practice it's larger
> which is not a problem.

"In practice" refers to the current way that slab allocators arrange
objects within the page. They are free to do otherwise if new ideas come
up for object arrangements etc.

The slab allocators already may have to store data in addition to the user
accessible part (f.e. for RCU or ctor). The "natural alighnment" of a
power of 2 cache is no longer as you expect for these cases. Debugging is
not the only case where we extend the object.

> Also let me stress again that nothing really changes except for SLOB,
> and SLUB with debug options. The natural alignment for power-of-two
> sizes already happens as SLAB and SLUB both allocate objects starting on
> the page boundary. So people make assumptions based on that, and then
> break with SLOB, or SLUB with debug. This patch just prevents that
> breakage by guaranteeing those natural assumptions at all times.

As explained before there is nothing "natural" here. Doing so restricts
future features and creates a mess within the allocator of exceptions for
debuggin etc etc (see what happened to SLAB). "Natural" is just a
simplistic thought of a user how he would arrange power of 2 objects.
These assumption should not be made but specified explicitly.

> > I think its valuable that alignment requirements need to be explicitly
> > requested.
>
> That's still possible for named caches created by kmem_cache_create().

So lets leave it as it is now then.

