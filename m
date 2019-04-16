Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CC4AC10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 20:05:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 006C020821
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 20:05:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=efficios.com header.i=@efficios.com header.b="MKVHhXkf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 006C020821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=efficios.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 943726B0003; Tue, 16 Apr 2019 16:05:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8CAE56B0006; Tue, 16 Apr 2019 16:05:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 76C596B0007; Tue, 16 Apr 2019 16:05:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4F8366B0003
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 16:05:55 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id w124so18740706qkb.12
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 13:05:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-filter:dkim-signature:date:from:to:cc
         :message-id:in-reply-to:references:subject:mime-version
         :content-transfer-encoding:thread-topic:thread-index;
        bh=xCXfm0GksTeOQ3vNasxSWI3L+tslb07JX35RdVENb28=;
        b=Vhf+8AWGS54wlKFVJlisqxqsASzkJxOleUkj+dnndX2OkpX00qJWM9n90sscXDngmq
         TLa+Ft9wjgdiPJLFZP6pdjRRje8VPuKq5EGDTJNwCZdJ0Kcj0XL+CihhnoU96UX67Yl9
         57MnCHPZiOLS4YytLfb/AFiB1QS3shX8qlMUNBxCXtJ1cL1U4hLmORMvNSmK803edHzZ
         hPPyOdSt2wPgSS1Mn7frQ9FrbfFtD3GPlr2+oToCUUeVRo7zBdnmZj0IzixAwI8PrNSO
         7QP3W0iMEK8z5kroXhfeTFq5eznxzQwTabf9EdwUI0O3ac6VLvFNVyW/W4fjD6GEwM6r
         jxHw==
X-Gm-Message-State: APjAAAXI36r9HP1SFOJdH8+upgh4AKSIBiACg4w1sCx5XILDrapFWbSq
	ZE3LbJvgOyXXdOzi2JhkLhQ9BOkdZW7fMiESuQk3OzzjeJnZMQtgUD8NgyQeIpXL9cn5YFt8wwD
	Hs1deg+hgmAXSM8HHdo6J+Hn/zEaNRbqf6xdxaHLz7pAALw27nr4K1hwskxpKs5RNMw==
X-Received: by 2002:aed:35e4:: with SMTP id d33mr67053281qte.58.1555445155033;
        Tue, 16 Apr 2019 13:05:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx0+VZVGrlLhen//p7Bv+KJ53tBIwzH0/jsRodA9ssXTPt/NEBQBDG2fYnM8lVRgrMLKnTH
X-Received: by 2002:aed:35e4:: with SMTP id d33mr67053220qte.58.1555445154360;
        Tue, 16 Apr 2019 13:05:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555445154; cv=none;
        d=google.com; s=arc-20160816;
        b=u9GeamtM8SlFkGYmrblxr8GC7gpc6TCaiikePnt4mr37ZLlGOcgS+XWOX+3qV4n56Q
         soA6htGyRWIEzCTVuIEngTgN02IYhExZdcq2COgEVBCDFmS2y8te1Wg8QhrLRqBNmqnj
         LpD7MqjnfC/jpAlLO4h3gY9VPiO+UowBBOKz/vlmmeocL7JQ/TGV7LVtiR1a+hKF66dh
         xyCmvXiVCnv3qJCPq452txwS3Jow/OYi8IgUl5jE1sM6imeI3qI1NgGIW5KLn/DvxUHt
         mGT1zEJUBkUePg3SFE7ccSulYTUFnqgd9y39I8bNMZrIZGIfVUkmFdO9ECOQgkFjeE1y
         aY2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:content-transfer-encoding:mime-version
         :subject:references:in-reply-to:message-id:cc:to:from:date
         :dkim-signature:dkim-filter;
        bh=xCXfm0GksTeOQ3vNasxSWI3L+tslb07JX35RdVENb28=;
        b=RXUD8IrqRKVCDOD5O3+T1a6w6MboUVnwNBr+44dXZ+7VAKONLyL2/ys/2fFParLQ3v
         oxag6SO4PrTOMb12dvkOHFAg+GmlePDsCGXTHla1/vnAD23sQ6IbXKrZwOx+aVj+N4Gb
         Kzhm805hal9+WzdMi5gKKZ1f/bYp9ZAz747RQN9ONYOUwMGoQ1ckjJrkj2AzZiw/LRJX
         7h8qOI8QvUnP7KYJWBJmSdZ+9j+xxClpkUDeY0Oji7dywVgmLBaYu1z3an3mBkXCZfNa
         gyxKBSsIfHMif/aV6/WmZ9Ui0Tno2NLTQhvnRpyeoXuTO0s8Sgf1Co5HNRfo0l0aDrab
         u+8A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@efficios.com header.s=default header.b=MKVHhXkf;
       spf=pass (google.com: domain of compudj@efficios.com designates 167.114.142.138 as permitted sender) smtp.mailfrom=compudj@efficios.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=efficios.com
Received: from mail.efficios.com (mail.efficios.com. [167.114.142.138])
        by mx.google.com with ESMTPS id 1si2963967qvy.164.2019.04.16.13.05.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 13:05:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of compudj@efficios.com designates 167.114.142.138 as permitted sender) client-ip=167.114.142.138;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@efficios.com header.s=default header.b=MKVHhXkf;
       spf=pass (google.com: domain of compudj@efficios.com designates 167.114.142.138 as permitted sender) smtp.mailfrom=compudj@efficios.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=efficios.com
Received: from localhost (ip6-localhost [IPv6:::1])
	by mail.efficios.com (Postfix) with ESMTP id 8DBFB1D6FC9;
	Tue, 16 Apr 2019 16:05:53 -0400 (EDT)
Received: from mail.efficios.com ([IPv6:::1])
	by localhost (mail02.efficios.com [IPv6:::1]) (amavisd-new, port 10032)
	with ESMTP id PmFNGrHV7vYt; Tue, 16 Apr 2019 16:05:53 -0400 (EDT)
Received: from localhost (ip6-localhost [IPv6:::1])
	by mail.efficios.com (Postfix) with ESMTP id ECBFA1D6FC5;
	Tue, 16 Apr 2019 16:05:52 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.10.3 mail.efficios.com ECBFA1D6FC5
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=efficios.com;
	s=default; t=1555445153;
	bh=xCXfm0GksTeOQ3vNasxSWI3L+tslb07JX35RdVENb28=;
	h=Date:From:To:Message-ID:MIME-Version;
	b=MKVHhXkfHjSoUDb6xhbZ+yFqnXUzKYUqifa2yA0Norh+/6gh6AJjB6/R/EzziLjVN
	 UTXLzaRDWBNOxwXGjmLlQT+hIuuNG4Pw39V2YttYfmfrVtLNt3p0ko72/nb+DUchQF
	 Hr5b3vR41lhTaB/bQkSmDj6tmMdSfXzSj8Im+8GGMVgty1WFlRgNAesyTEOvl6qya0
	 DJi1s8XLC/YLf9kHRTzhoSzYDdNYogpCqVdbil4j1PPzaQ5JUozlqeX592lkPfdTlu
	 3/FlNsmnXMW4KVeBjNPgWwc4Ib6mPrtiAdXsxXNEf0br/1hcfA8r3CZfMKfuK9Q6xs
	 kihNtGVNx6/SA==
X-Virus-Scanned: amavisd-new at efficios.com
Received: from mail.efficios.com ([IPv6:::1])
	by localhost (mail02.efficios.com [IPv6:::1]) (amavisd-new, port 10026)
	with ESMTP id 33vRis1AVO1a; Tue, 16 Apr 2019 16:05:52 -0400 (EDT)
Received: from mail02.efficios.com (mail02.efficios.com [167.114.142.138])
	by mail.efficios.com (Postfix) with ESMTP id C74241D6FB7;
	Tue, 16 Apr 2019 16:05:52 -0400 (EDT)
Date: Tue, 16 Apr 2019 16:05:52 -0400 (EDT)
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Guenter Roeck <groeck@google.com>, Kees Cook <keescook@chromium.org>, 
	kernelci <kernelci@groups.io>, 
	Guillaume Tucker <guillaume.tucker@collabora.com>, 
	Mike Rapoport <rppt@linux.ibm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Mark Brown <broonie@kernel.org>, 
	Tomeu Vizoso <tomeu.vizoso@collabora.com>, 
	Matt Hart <matthew.hart@linaro.org>, 
	Stephen Rothwell <sfr@canb.auug.org.au>, 
	Kevin Hilman <khilman@baylibre.com>, 
	Enric Balletbo i Serra <enric.balletbo@collabora.com>, 
	Nicholas Piggin <npiggin@gmail.com>, 
	linux <linux@dominikbrodowski.net>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, 
	Adrian Reber <adrian@lisas.de>, 
	linux-kernel <linux-kernel@vger.kernel.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, 
	Richard Guy Briggs <rgb@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, info <info@kernelci.org>
Message-ID: <2054840174.2796.1555445152616.JavaMail.zimbra@efficios.com>
In-Reply-To: <CAPcyv4gxk9xbsP3YSKzxu5Yp9FTefyxHc6xC33GwZ3Zf9_eeKA@mail.gmail.com>
References: <20190215185151.GG7897@sirena.org.uk> <CAGXu5jLAPKBE-EdfXkg2AK5P=qZktW6ow4kN5Yzc0WU2rtG8LQ@mail.gmail.com> <CABXOdTdVvFn=Nbd_Anhz7zR1H-9QeGByF3HFg4ZFt58R8=H6zA@mail.gmail.com> <CAGXu5j+Sw2FyMc8L+8hTpEKbOsySFGrCmFtVP5gt9y2pJhYVUw@mail.gmail.com> <CABXOdTcXWf9iReoocaj9rZ7z17zt-62iPDuvQQSrQRtMeeZNiA@mail.gmail.com> <CAPcyv4i8xhA6B5e=YBq2Z5kooyUpYZ8Bv9qov-mvqm4Uz=KLWQ@mail.gmail.com> <CABXOdTc5=J7ZFgbiwahVind-SNt7+G_-TVO=v-Y5SBVPLdUFog@mail.gmail.com> <CAPcyv4gxk9xbsP3YSKzxu5Yp9FTefyxHc6xC33GwZ3Zf9_eeKA@mail.gmail.com>
Subject: Re: next/master boot bisection: next-20190215 on beaglebone-black
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Originating-IP: [167.114.142.138]
X-Mailer: Zimbra 8.8.12_GA_3794 (ZimbraWebClient - FF66 (Linux)/8.8.12_GA_3794)
Thread-Topic: next/master boot bisection: next-20190215 on beaglebone-black
Thread-Index: 6c8jdHB53tUcYvEQYLkcXDa+eqcbdA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

----- On Apr 16, 2019, at 2:54 PM, Dan Williams dan.j.williams@intel.com wrote:

> On Thu, Apr 11, 2019 at 1:54 PM Guenter Roeck <groeck@google.com> wrote:
> [..]
>> > > Boot tests report
>> > >
>> > > Qemu test results:
>> > >     total: 345 pass: 345 fail: 0
>> > >
>> > > This is on top of next-20190410 with CONFIG_SHUFFLE_PAGE_ALLOCATOR=y
>> > > and the known crashes fixed.
>> >
>> > In addition to CONFIG_SHUFFLE_PAGE_ALLOCATOR=y you also need the
>> > kernel command line option "page_alloc.shuffle=1"
>> >
>> > ...so I doubt you are running with shuffling enabled. Another way to
>> > double check is:
>> >
>> >    cat /sys/module/page_alloc/parameters/shuffle
>>
>> Yes, you are right. Because, with it enabled, I see:
>>
>> Kernel command line: rdinit=/sbin/init page_alloc.shuffle=1 panic=-1
>> console=ttyAMA0,115200 page_alloc.shuffle=1
>> ------------[ cut here ]------------
>> WARNING: CPU: 0 PID: 0 at ./include/linux/jump_label.h:303
>> page_alloc_shuffle+0x12c/0x1ac
>> static_key_enable(): static key 'page_alloc_shuffle_key+0x0/0x4' used
>> before call to jump_label_init()
> 
> This looks to be specific to ARM never having had to deal with
> DEFINE_STATIC_KEY_TRUE in the past.
> 
> I am able to avoid this warning by simply not enabling JUMP_LABEL
> support in my build.

Looking into this some more, it looks like I was on the wrong track
with my large branch offset theory. Is it just possible that
page_alloc_shuffle() ends up using jump labels before they are
initialized ? Perhaps this has something to do with how early
the page_alloc.shuffle=1 kernel parameter is handled.

Thanks,

Mathieu


-- 
Mathieu Desnoyers
EfficiOS Inc.
http://www.efficios.com

