Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 994C1C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 04:39:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 565D32087C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 04:39:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="HOkQ7PsK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 565D32087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED1EC8E0003; Tue, 12 Mar 2019 00:39:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E59998E0002; Tue, 12 Mar 2019 00:39:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFB798E0003; Tue, 12 Mar 2019 00:39:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id A820A8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 00:39:37 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id l87so1205044qki.10
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 21:39:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=LkhfHT+eZqOj4+XJACRRXYWHTO5hqppA0D2BmcRnPaE=;
        b=JROkUh2y9Y7p/Cn0QZkYsEjRGmj5QVDEvngwrArn0irsUMzPeGudgGV/ihWs2sXyfN
         SO3zUGzC3s+agKK+Yaypjen/HwlpWRH/Zyzc1qyviBgafp8HEEuQVL+hRd60NsaknL5U
         Faanx/zp4o2YLaW3pHji4rhI1zTCj+TQtsBJGiQE4e+tEneG+rTT5nKn+nuA93SyObl1
         qjUn7POG10rnzfRyWnLstOwQKy11i3wvaAFKCYoaRFZB96nptsldV9oxNErhW0xfnP2i
         mH4qHGqD5IhIX8XJI6MiJRofb+6flGIcnorneeYmZRdKWPf1Ye+ae9VSXLPKHqSudnVH
         JEAA==
X-Gm-Message-State: APjAAAWQlB+u8569G3jHUXX7ozV7Gd8K/MQ8bZDuM4QkGBLpPR8PWv+a
	4HYZLa0ZgKehn/9v+5KHPJ9jWYDBQ2r3A86iFqfXASfJXVGlTlnJEX5/id3L/P3GL5twXCVdmgI
	9Cm7Iybz7QFRl9nd6u4nvcCSe7nfRHUEJmy/7ZkMxE162jAoyDGJXvjKkkexN2LQ=
X-Received: by 2002:a0c:8938:: with SMTP id 53mr28973329qvp.165.1552365577488;
        Mon, 11 Mar 2019 21:39:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwc+FFYUcBrJnvZpl4lqQvxPy1yoe0iq9AEw/pTXGAitV8wPxWuT3i//xkGejMwG+WMuDdx
X-Received: by 2002:a0c:8938:: with SMTP id 53mr28973302qvp.165.1552365576848;
        Mon, 11 Mar 2019 21:39:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552365576; cv=none;
        d=google.com; s=arc-20160816;
        b=075geaiUwq4wEajMM7DQShNkkzFs4s2JwRgOBP/VpVL2ZxfizjRdPS5DjSVRudrHjO
         DN2Ia3ytJ/xVUy+1B1CGYOG6IumjXF+HvRVsuPxM3VJZw+9OWCPxCVlf1T15rPz+EDIS
         DX2/ebwTx+5U6Ntj0ueQeZ270c+DuXkKLYmbKtrmMFwaTgzR6gM2F4XFmrrZDFm/HJVu
         EJhYeRlSbDDs/unC9MGISUWxlcWq32/pYXT9p/v5L2vk73nOrykbFFSuzZsu0N/8v2i6
         pJ5vPZBK7Yi/Q91Qtd5KMn0kC80HwbMAzZz0l6u0Ye9ElJ9ctFq59y1/7B5FhvoZpZkT
         ey8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=LkhfHT+eZqOj4+XJACRRXYWHTO5hqppA0D2BmcRnPaE=;
        b=Ztr7xxO5zWeJniAVVtUAe8krXzNkhElf8ThfgGb78tircsjiJbKiQK16e762ygGqLu
         HTgAQ4slDCmOBFXcAmpupclLlX9D5xOQXBYIq7qa6LxYjxTvpXX4EwA4sHQynoItskNQ
         aH72QjVaf2q6p6EHMWjlI8Yv3fT9yCaUg/mBoLeuJhM7NPejxuLetlNXN83gzJyA59qy
         qIPxGyy1CSUGhtVJCyf86v0w654APh9PzLHnoJjmpk4/7PT75oQxMbhqUOOkgjjibH0j
         zyN9eW1IOIazBh4YpfNKo1okgQpaGFNFrzc699/BagoEaJ0tzCYXmge/CFzbtBnnZC0y
         V6/A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=HOkQ7PsK;
       spf=pass (google.com: domain of 010001697032e074-f9658e7a-595f-4804-a7a0-fd4220ee8473-000000@amazonses.com designates 54.240.9.54 as permitted sender) smtp.mailfrom=010001697032e074-f9658e7a-595f-4804-a7a0-fd4220ee8473-000000@amazonses.com
Received: from a9-54.smtp-out.amazonses.com (a9-54.smtp-out.amazonses.com. [54.240.9.54])
        by mx.google.com with ESMTPS id r47si459685qte.237.2019.03.11.21.39.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 11 Mar 2019 21:39:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of 010001697032e074-f9658e7a-595f-4804-a7a0-fd4220ee8473-000000@amazonses.com designates 54.240.9.54 as permitted sender) client-ip=54.240.9.54;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=HOkQ7PsK;
       spf=pass (google.com: domain of 010001697032e074-f9658e7a-595f-4804-a7a0-fd4220ee8473-000000@amazonses.com designates 54.240.9.54 as permitted sender) smtp.mailfrom=010001697032e074-f9658e7a-595f-4804-a7a0-fd4220ee8473-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1552365576;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=1LTMJfj2MpOeyw9WxqSJjQTwp4yTHH300l9armbyJC4=;
	b=HOkQ7PsKGu3GSQcfBqMosDF+daAGkgtFYWtLnhM6U0lGK0XdYQ+blRTjybq852/P
	0j3VXMrpX5d3eF+pwOtkhR78avcgymKf+t9Sz+WbQ0YmNes5jaMZRyZeX/jBxjICmh2
	dnAFEAl8z0SmxzqaOBHIrVvRtJ9+MEc0ZqhJHsaU=
Date: Tue, 12 Mar 2019 04:39:36 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Roman Gushchin <guro@fb.com>
cc: "Tobin C. Harding" <tobin@kernel.org>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Pekka Enberg <penberg@cs.helsinki.fi>, 
    Matthew Wilcox <willy@infradead.org>, Tycho Andersen <tycho@tycho.ws>, 
    "linux-mm@kvack.org" <linux-mm@kvack.org>, 
    "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [RFC 04/15] slub: Enable Slab Movable Objects (SMO)
In-Reply-To: <20190311224842.GC7915@tower.DHCP.thefacebook.com>
Message-ID: <010001697032e074-f9658e7a-595f-4804-a7a0-fd4220ee8473-000000@email.amazonses.com>
References: <20190308041426.16654-1-tobin@kernel.org> <20190308041426.16654-5-tobin@kernel.org> <20190311224842.GC7915@tower.DHCP.thefacebook.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.03.12-54.240.9.54
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Mar 2019, Roman Gushchin wrote:

> > +static inline void *alloc_scratch(struct kmem_cache *s)
> > +{
> > +	unsigned int size = oo_objects(s->max);
> > +
> > +	return kmalloc(size * sizeof(void *) +
> > +		       BITS_TO_LONGS(size) * sizeof(unsigned long),
> > +		       GFP_KERNEL);
>
> I wonder how big this allocation can be?
> Given that the reason for migration is probably highly fragmented memory,
> we probably don't want to have a high-order allocation here. So maybe
> kvmalloc()?

The smallest object size is 8 bytes which is one word which would be
places in an order 0 page. So it comes out to about a page again.

Larger allocation orders are possible if the slab pages itself can have
larger orders of course. If you set the min_order to the huge page order
then we can have similar sized orders for the allocation of the scratch
space. However, that is not a problem since the allocations for the slab
pages itself are also already of that same order.

