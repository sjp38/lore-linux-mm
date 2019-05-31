Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88D9CC04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 18:31:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D3D726DF8
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 18:31:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="XIhW5QA8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D3D726DF8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BEEAF6B0272; Fri, 31 May 2019 14:31:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B512B6B0274; Fri, 31 May 2019 14:31:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A40086B0278; Fri, 31 May 2019 14:31:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 423B56B0272
	for <linux-mm@kvack.org>; Fri, 31 May 2019 14:31:16 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id u13so2285501lfg.19
        for <linux-mm@kvack.org>; Fri, 31 May 2019 11:31:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=OI/XkyWscYGF3A6q2jZ5I5FXRspFschNtLNhVlAhmaA=;
        b=XUD7E+EZnUD4nliWo9FhCr2yCcJEtpNy+9wM9iBgRtnepBmt2AI6/o19/brGLt1/t9
         4dt1Xq6nwiKlM95qd0h+T8MSngYe5NOUMDQntwuGK1XrG6FGCNI9c+WdYaFDu8Q28YnN
         5kZlHM6ZyrstH+f9IUv20w5VkeNAmzMv3RQwk/wmBJP35GpWGwbD/LEa5Ohbp38lLzPA
         AlE9culg6L+mJmVUlsMaFErZF4mOJQ1t/aRHNsjosCqbNO73vbxhqQTwHOevkEVn6LRa
         puHH4bCbHBClbPo0EQYkTWIvDyltz4h3PqpXcIRNcvh87jY1iPo0WL95E32NiIEhKRbh
         8f4w==
X-Gm-Message-State: APjAAAW2iNzM6NLZQDQapenyH+kEzms0DVs8EjNGg09mYaKmOq6X8Qu9
	m+DPu/o0/VxdpmHHEBuaGSTuU9jJ1x9OtplF09ms01LG0HWps/O+8l+8THNRC2KdTyX4l41UEdY
	Ki3XaPbe3JjtzaicfQGG4A74Y6nCCFUts9v7dTyae2mKPTnOdzU+5kRdFTtZZj6AylQ==
X-Received: by 2002:a2e:86d4:: with SMTP id n20mr3466036ljj.210.1559327475413;
        Fri, 31 May 2019 11:31:15 -0700 (PDT)
X-Received: by 2002:a2e:86d4:: with SMTP id n20mr3465997ljj.210.1559327474435;
        Fri, 31 May 2019 11:31:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559327474; cv=none;
        d=google.com; s=arc-20160816;
        b=mUkI+a6AcoPAu7hYf3VizxFi0uZzN353RTkJwRJ4oVhNPaTzuE44aEx3POr4FGXM5/
         tQZ6nlT6tfOWjGwfNxHG1tOMkFTeA8DwZqhZqvnabSZPpjMkZp0qnStmS5ON3c24Zcdo
         3rThksKUZhYqXhRblxy3v6JVdB8hn6bTrDOM7ktn3//AouU/i/KXtJzEDUno6HQ5ePFS
         gHreGlpFoDLz/+PPDy4xSaGZy+I5M0qfWXnkGcJsyvIuePRal7w8CzDliCBbvneNb0Wo
         e9c4P/GhWaNVroFzruMuyyX8yZySKPLzVaJMQ+4G+p6FbCzJOWkePaq2JpG3VShzf0kA
         hFpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=OI/XkyWscYGF3A6q2jZ5I5FXRspFschNtLNhVlAhmaA=;
        b=K4mRLvFZBgiuBGDHu8ULsb1wkNbTw687T7ZmWpfzU9+sMkNkIr63wjHi0p31WIFLcg
         SMjRNXVXpzx/jasr9eVkRuKf0TIN/ekh0ct3yJwC1BmLM0OBiXXLUu8oEpc7f4DPkvLU
         aCV3bT5nkVXs/4+vQ8julIGiGqFHzC1d+VZc+m/UN04Rp0otNbyQp2inC0eCiVU+p1HV
         I7DHwQ8LrefDyz/EuLl3BM9riJInfTruSMtZIT8jvTpE+8WJ/Iv9dBAuGDqBFuNtj7vq
         oYJgBMBX56Au/cIc60CI8hwctHg4e06i51aMcqTpswTLnxaYqcpZIvw7aJmStSeDDtzY
         hXFw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=XIhW5QA8;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d28sor2468706lfm.0.2019.05.31.11.31.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 11:31:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=XIhW5QA8;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=OI/XkyWscYGF3A6q2jZ5I5FXRspFschNtLNhVlAhmaA=;
        b=XIhW5QA8Xo4JHcGzA63mCXQV36Thq0SGB3HcmpD47Io+dSV1aXANbYc5EtOg1o2Na5
         cP5NY7zZZbPkTEogRr8MiiyM9Ejv2cDEHDIstDA9/aCsb2qtbSu3Kdt3sDl/vlELdHbK
         jAm3CuPDjICN+xqs//OTC5MWMsJRG2G18ibag=
X-Google-Smtp-Source: APXvYqws1pca21BDfbNbWlTluNKhH67sZUwQk7OT6L22Ts9r5G9onbEHSq8rT+6WEc/kBtwUpSoS7Q==
X-Received: by 2002:ac2:5ec6:: with SMTP id d6mr6927917lfq.131.1559327473130;
        Fri, 31 May 2019 11:31:13 -0700 (PDT)
Received: from mail-lj1-f175.google.com (mail-lj1-f175.google.com. [209.85.208.175])
        by smtp.gmail.com with ESMTPSA id b6sm1459600lfa.54.2019.05.31.11.31.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 May 2019 11:31:12 -0700 (PDT)
Received: by mail-lj1-f175.google.com with SMTP id r76so10516856lja.12
        for <linux-mm@kvack.org>; Fri, 31 May 2019 11:31:11 -0700 (PDT)
X-Received: by 2002:a2e:914d:: with SMTP id q13mr6747997ljg.140.1559327471592;
 Fri, 31 May 2019 11:31:11 -0700 (PDT)
MIME-Version: 1.0
References: <20190528120453.27374-1-npiggin@gmail.com>
In-Reply-To: <20190528120453.27374-1-npiggin@gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 31 May 2019 11:30:55 -0700
X-Gmail-Original-Message-ID: <CAHk-=whHWqVPWMeNRYuxAd8xnZscshoXUP8SFPmJivJfds5-HQ@mail.gmail.com>
Message-ID: <CAHk-=whHWqVPWMeNRYuxAd8xnZscshoXUP8SFPmJivJfds5-HQ@mail.gmail.com>
Subject: Re: [PATCH 1/4] mm/large system hash: use vmalloc for size >
 MAX_ORDER when !hashdist
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, 
	Toshi Kani <toshi.kani@hp.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Uladzislau Rezki <urezki@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 5:08 AM Nicholas Piggin <npiggin@gmail.com> wrote:
>
> The kernel currently clamps large system hashes to MAX_ORDER when
> hashdist is not set, which is rather arbitrary.

I think the *really* arbitrary part here is "hashdist".

If you enable NUMA support, hashdist is just set to 1 by default on
64-bit, whether the machine actually has any numa characteristics or
not. So you take that vmalloc() TLB overhead whether you need it or
not.

So I think your series looks sane, and should help the vmalloc case
for big hash allocations, but I also think that this whole
alloc_large_system_hash() function should be smarter in general.

Yes, it's called "alloc_large_system_hash()", but it's used on small
and perfectly normal-sized systems too, and often for not all that big
hashes.

Yes, we tend to try to make some of those hashes large (dentry one in
particular), but we also use this for small stuff.

For example, on my machine I have several network hashes that have
order 6-8 sizes, none of which really make any sense to use vmalloc
space for (and which are smaller than a large page, so your patch
series wouldn't help).

So on the whole I have no issues with this series, but I do think we
should maybe fix that crazy "if (hashdist)" case. Hmm?

                   Linus

