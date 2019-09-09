Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB1AFC4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 16:54:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E33321924
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 16:54:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pg0BqddT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E33321924
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19F456B0006; Mon,  9 Sep 2019 12:54:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14E616B0007; Mon,  9 Sep 2019 12:54:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08CAA6B0008; Mon,  9 Sep 2019 12:54:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0131.hostedemail.com [216.40.44.131])
	by kanga.kvack.org (Postfix) with ESMTP id DA5E66B0006
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 12:54:27 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id D11CD81C6
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 16:54:26 +0000 (UTC)
X-FDA: 75915980532.17.event87_9ad9b8c7c901
X-HE-Tag: event87_9ad9b8c7c901
X-Filterd-Recvd-Size: 3265
Received: from mail-ot1-f67.google.com (mail-ot1-f67.google.com [209.85.210.67])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 16:54:26 +0000 (UTC)
Received: by mail-ot1-f67.google.com with SMTP id 67so13174621oto.3
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 09:54:26 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=31kxGZUlgh39qJethx0hRa+2PyryHdT/Kifm1vwiYDs=;
        b=pg0BqddTOhx6M/Lw9KYbXBx53VB0/+25bq5PSVGS50kKhJAnUXeSYvtCFIgIlUO7I4
         Sg1kq0KCyg8dXxJGHKD/MqCwcoPyMDnS6oFukKEhKHQoDCoLoj8esh2gRMKFIcUMl5La
         2FHcOz3V5odVTWnN7UmsDFgD91cDoA9lm/fqufSc+5Jfe1CCXs3dxqddQtSFZUYmc+Mh
         Q7v6HcK87vArL8+rNjdx+vspc3BNqWnc12MCGysMYEtg0aFAUl7cnDYzfUvg0oLEO0o+
         k8ZvmZolsz5u43ZSfVkBrweedczj7i6/QGcV4lflm9XvPAaqCL9km3p4IpM1HxWR9qoP
         hgfg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=31kxGZUlgh39qJethx0hRa+2PyryHdT/Kifm1vwiYDs=;
        b=mOrF/LK7CsMR+9dLqU8LE5sgN6HSq6dOzGKlJJFc51dG+T5kq5VX6fMsS1p7YcQvYP
         rN0BsNjUDCsbzNMKootGrzg/y2BGZlS1U+lLCFhAIj/jGk+zov/nwNGGs04UcgutONR8
         r/fMh+7OYK7gmPgaeiY3xxG950lXVhtlZ55+Fl6JiqJnD1QY/7mdQ4rTFKR8qf3jDxWi
         qudAXvdM5tpmm6wlosa2mxQMQamVaXCxPsXaLkUnwypOmCAFg07wZq0w1fyrKPq41/Dx
         VvAVXpO+W3155Xaeac10UNTjQO4z9T228Z62SPAiJIxAFHZnoRd76ZaOl2RGGd+mj/ZU
         oIEQ==
X-Gm-Message-State: APjAAAUF/0bphoNsNDKcHOKtQPGFpPXeSgxYgy6bagE/XuGe4KsPl+KB
	yvuWmY45hC8fJvmzq8zlDjchacUf4LVsY7TTd4A=
X-Google-Smtp-Source: APXvYqxnlaS57V4kAtXP0r+RRN9r75uKF5+ohgYNaIFFekZNrp9ytwRto6OPiRHTdghftBB5ZTPY16S+Jyw0XDyq2s0=
X-Received: by 2002:a9d:12e4:: with SMTP id g91mr19182974otg.368.1568048065736;
 Mon, 09 Sep 2019 09:54:25 -0700 (PDT)
MIME-Version: 1.0
References: <20190903160430.1368-1-lpf.vector@gmail.com> <20190903160430.1368-3-lpf.vector@gmail.com>
 <80fe024b-006e-b38e-1548-70441d917b41@suse.cz>
In-Reply-To: <80fe024b-006e-b38e-1548-70441d917b41@suse.cz>
From: Pengfei Li <lpf.vector@gmail.com>
Date: Tue, 10 Sep 2019 00:54:14 +0800
Message-ID: <CAD7_sbFf429WxnqcROGgpsYvK4q1maF2uP9nZjqs60195aC95g@mail.gmail.com>
Subject: Re: [PATCH 2/5] mm, slab_common: Remove unused kmalloc_cache_name()
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christopher Lameter <cl@linux.com>, penberg@kernel.org, 
	rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 9, 2019 at 10:59 PM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 9/3/19 6:04 PM, Pengfei Li wrote:
> > Since the name of kmalloc can be obtained from kmalloc_info[],
> > remove the kmalloc_cache_name() that is no longer used.
>
> That could simply be part of patch 1/5 really.
>

Ok, thanks.

> > Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
>
> Ack
>
> > ---
> >   mm/slab_common.c | 15 ---------------
> >   1 file changed, 15 deletions(-)

