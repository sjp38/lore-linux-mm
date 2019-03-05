Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F9B4C00319
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 12:38:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFD2B2084F
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 12:38:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mDwHzRXU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFD2B2084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F0DC8E0003; Tue,  5 Mar 2019 07:38:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 89F2F8E0001; Tue,  5 Mar 2019 07:38:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78E568E0003; Tue,  5 Mar 2019 07:38:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4EA318E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 07:38:09 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id 190so2255285itl.7
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 04:38:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=FMKOX00b5geW59JCGmiWRpcFMC5xVj2cRPCdif1RMXE=;
        b=F8OqJkTeUwTVYIUOnKufmsLOjNaoDHo7xuxrBN+Bl8Ee+sEjfW4BTdSehqpmGLcVPk
         EuDdj/V3hPhn4KA59LZpdZFUvUf+6iwByjxvc+aPrDdildVTC4oAanEA+PcAWEb9Kvcc
         CfLKZeNPLYarShueMTlrcGSsagNIEIkdrpGkq7LmXUSJvxxyeq4pX0036F5W9veZd6Yd
         dMJIMoYTykfoQklKGGNOzzRPNqTfPBwrncgd1azAUcPfkdURr4uU1n6iceIjcY7Vga1N
         2Lkw4eRkRyH3cqVqi509nQm9Rf/AntB7z1Unlhx+QBH/JNgLY3A0UZrGyjKdHmvFUiAE
         wPkw==
X-Gm-Message-State: APjAAAVzuRmwTXpaZ0curZQmAbrKBEns8S3rR4y7a7rLiOcUYd9+J4Q3
	do5uG97xZNnFceXgSFp0ZhTDsq1Pa0gTZ4+YvPqEfJQeg+Gl0jSnf119o5XqbddCv4d8VSPW/I9
	XdgKNt0kzHap39oPtibvyKw6DTqC7Bsd2QD2bVImwl0DTv+q9JL05FIImpZFdRMIX2a0lEnXbV4
	+OxeRp9smHfWYGyIiqPasOf9A/hwX7jbP5ZQ7dmcJ1neUeuJgoXAJ24DlPzs+Qzma1m2tpIKGK4
	+F4HpekvogHWnBEkdffcEa5NTL+uf7m75uRAGzSE2EJObFC39aeXdVJVyj50aHcngR835zviwyI
	oQarTkViCFT15DHBZBdEI2wgTjKavnzS1XzppmoaL4j6KrUj+LmiL6DnwaHweghIwJoxrIuUjQF
	u
X-Received: by 2002:a24:7cc4:: with SMTP id a187mr2550164itd.171.1551789489028;
        Tue, 05 Mar 2019 04:38:09 -0800 (PST)
X-Received: by 2002:a24:7cc4:: with SMTP id a187mr2550025itd.171.1551789485642;
        Tue, 05 Mar 2019 04:38:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551789485; cv=none;
        d=google.com; s=arc-20160816;
        b=mXx0fLN/dIJbtIXja3fiMFVXZSpYvobQUd5i6KWxjhOzUZmsyzRDJJILo/cInvG9FT
         Ut8AYcjxLLvgEoCM7h6TXqZTTYfQzdeuzAvC+0UjPx0Ua66HYh5vWxiHZ9TMWMwnC/rt
         RqUYiK82R/lX3jLlheAhyo+3AorJlXIhKKmw1AqO/k5xmSzHQFAd6cyI2fzqJ6OzUrvH
         hmVZrYo48QxBUOrxs7r9Qj+YQypR7lOJUXTsYeS2SKS9E8bNdUeWxhPEgXD33itppjOG
         rv17G3qiIuXJVdgcEuzcsJ/tLFyFBa6wgpqivWtn6bUEgSG+z+rDrym5Kbm+gjKZScGl
         FtIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=FMKOX00b5geW59JCGmiWRpcFMC5xVj2cRPCdif1RMXE=;
        b=PQ2MsVhrQzaoxmbbvqmvtLqv3yqhWio75G8U1+H47oLwMShFw5VXhkJXJfja0Fno/9
         lJ+Vgcf3co++/b7Gvodz4wZndjqDssudjl7uVYj6K86P7v3l9rDufzI/eiiYtchMOvMY
         0ik4JHh5Evj7GrlZnw7oeLCvmNjWqfwB3nIvArY/+28UwASh+7GILN91Ul2FXpORymcM
         x3z6Gv4FFDCapk+woJl4kKh6FdZTAeK8IPjiUl2KnwdUsQFgYbVc1uulcYNa8XiGdx/l
         fuN7W4LlO0Zob9VWOW92EOZ2aHep6o/twDLLJnPlkyRo3Vdo+dYmOJyXa46jQaqeLybn
         OYDw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mDwHzRXU;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p1sor4482110iof.26.2019.03.05.04.38.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Mar 2019 04:38:05 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mDwHzRXU;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=FMKOX00b5geW59JCGmiWRpcFMC5xVj2cRPCdif1RMXE=;
        b=mDwHzRXUWveyC/rQfyGhDOJ22LHtVB1S02PYABYVmLiRI1a30O5fc4HY/Y3ZaiEfjP
         VYMEikk9vGBnQv62Ur93hDOoLvqAWng5CCCUWEXojBACMFSbonbsb1L494j8P9Rf94Vf
         s3BqBeXhtRx9z9RWtHf2Tr+UeYeedW5a1GZ+DesVPwsbIopTb6F2G5KgT9r8uX7ppxFK
         h1wKbrxKPTtVcQrwYAZPpCzEQiOvhBBPIUOSQlMXxP81qztvmEEihxouHqP1nIzvYHg2
         C4wRasXBamA8EaHurPmoDsMtomXZmBjlNEzMP5cjsu6xQGRub87w4jV6T0ugAxLgfAxm
         a7gw==
X-Google-Smtp-Source: APXvYqwwWSOjiqVVI8C5wZg5+Upov/7T8/LsOOUiMH3bKLM132URHzOkTSpW54ZBSMPW0EXkhyZHCCxXZhWZ2xpfvhU=
X-Received: by 2002:a5d:8251:: with SMTP id n17mr13793382ioo.259.1551789485259;
 Tue, 05 Mar 2019 04:38:05 -0800 (PST)
MIME-Version: 1.0
References: <1551011649-30103-1-git-send-email-kernelfans@gmail.com>
 <20190225160358.GW10588@dhcp22.suse.cz> <CAFgQCTuD9MMdXRjyu1w5s3QSupWWtdcCOR6LhdSEP=1xGONWjQ@mail.gmail.com>
 <20190226120919.GY10588@dhcp22.suse.cz>
In-Reply-To: <20190226120919.GY10588@dhcp22.suse.cz>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Tue, 5 Mar 2019 20:37:53 +0800
Message-ID: <CAFgQCTs5uW9baypGbW5z=KyC7Vd9-QjTSKLFAJC5c2Jd6_ow_Q@mail.gmail.com>
Subject: Re: [PATCH 0/6] make memblock allocator utilize the node's fallback info
To: Michal Hocko <mhocko@kernel.org>
Cc: x86@kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, 
	Mike Rapoport <rppt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andy Lutomirski <luto@kernel.org>, Andi Kleen <ak@linux.intel.com>, Petr Tesarik <ptesarik@suse.cz>, 
	Stephen Rothwell <sfr@canb.auug.org.au>, Jonathan Corbet <corbet@lwn.net>, 
	Nicholas Piggin <npiggin@gmail.com>, Daniel Vacek <neelx@redhat.com>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 8:09 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 26-02-19 13:47:37, Pingfan Liu wrote:
> > On Tue, Feb 26, 2019 at 12:04 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Sun 24-02-19 20:34:03, Pingfan Liu wrote:
> > > > There are NUMA machines with memory-less node. At present page allocator builds the
> > > > full fallback info by build_zonelists(). But memblock allocator does not utilize
> > > > this info. And for memory-less node, memblock allocator just falls back "node 0",
> > > > without utilizing the nearest node. Unfortunately, the percpu section is allocated
> > > > by memblock, which is accessed frequently after bootup.
> > > >
> > > > This series aims to improve the performance of per cpu section on memory-less node
> > > > by feeding node's fallback info to memblock allocator on x86, like we do for page
> > > > allocator. On other archs, it requires independent effort to setup node to cpumask
> > > > map ahead.
> > >
> > > Do you have any numbers to tell us how much does this improve the
> > > situation?
> >
> > Not yet. At present just based on the fact that we prefer to allocate
> > per cpu area on local node.
>
> Yes, we _usually_ do. But the additional complexity should be worth it.
> And if we find out that the final improvement is not all that great and
> considering that memory-less setups are crippled anyway then it might
> turn out we just do not care all that much.
> --
I had finished some test on a "Dell Inc. PowerEdge R7425/02MJ3T"
machine, which owns 8 numa node. and the topology is:
L1d cache:           32K
L1i cache:           64K
L2 cache:            512K
L3 cache:            4096K
NUMA node0 CPU(s):   0,8,16,24
NUMA node1 CPU(s):   2,10,18,26
NUMA node2 CPU(s):   4,12,20,28
NUMA node3 CPU(s):   6,14,22,30
NUMA node4 CPU(s):   1,9,17,25
NUMA node5 CPU(s):   3,11,19,27
NUMA node6 CPU(s):   5,13,21,29
NUMA node7 CPU(s):   7,15,23,31

Here is the basic info about the NUMA machine. cpu 0 and 16 share the
same L3 cache. Only node 1 and 5 own memory. Using local node as
baseline, the memory write performance suffer 25% drop to nearest node
(i.e. writing data from node 0 to 1), and 78% drop to farthest node
(i.e. writing from 0 to 5).

I used a user space test case to get the performance difference
between the nearest node and the farthest. The case pins two tasks on
cpu 0 and 16. The case used two memory chunks, A which emulates a
small footprint of per cpu section, and B which emulates a large
footprint. Chunk B is always allocated on nearest node, while chunk A
switch between nearest node and the farthest to render comparable
result. To emulate around 2.5% access to per cpu area, the case
composes two groups of writing, 1 time to memory chunk A, then 40
times to chunk B.

On the nearest node, I used 4MB foot print, which is the same size as
L3 cache. And varying foot print from 2K -> 4K ->8K to emulate the
access to the per cpu section. For 2K and 4K, perf result can not tell
the difference exactly, due to the difference is smaller than the
variance. For 8K: 1.8% improvement, then the larger footprint, the
higher improvement in performance. But 8K means that a module
allocates 4K/per cpu in the section. This is not in practice.

So the changes may be not need.

Regards,
Pingfan

