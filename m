Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21DC2C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 18:20:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3C1B222BB
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 18:20:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="Bwg4eIV/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3C1B222BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F44B8E0002; Tue, 12 Feb 2019 13:20:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A44C8E0001; Tue, 12 Feb 2019 13:20:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BB918E0002; Tue, 12 Feb 2019 13:20:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 07B768E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 13:20:37 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id f5so1333293wrt.13
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:20:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=bUE+CRybLrXIaYOIjcJlj0+EDkY0lhfvzRxWOTDT9hU=;
        b=jYkFFWMnk/bvQuLGFR0hnz6ZaQJ67tIMk2IRtVzdwx+Gn6RGB0hmfs2HCOgool99Yk
         Ctpmdoid6PIJ+GYKd3QbyzxL0Hbr0P4d57onFUVDBchH5x17fs95+MKI4qwSFt9MjKf1
         wr4h8hzwTkUGXpTmSPgSZ8WfMm7WYPGZQpzN9iLZQ9FGQnjBiDUSDMYURlQeyKm4M73e
         F33P3/is4nBMXxmEAbdFDbb/b/qWHoXe9Z6jkvX/Aise4GggMlB6cYoCj7tW699Qf9Tp
         zRyowpILF5G67lSs12PkLq16HgDD3LNkJ3JXeSWc9VC9w/30tRcRmck+LKlI8WtyvGDV
         zQRA==
X-Gm-Message-State: AHQUAuboctVdhjE93auqhxuO8j0K/3ZXiGpssvG74hXilT0oU/vsNwGW
	ypTuk23MNh1YnlB2lRyaBVWOQUEhOB0a/20V0ERIb7NJDex+hTPbAIf0Vr28oUFVn0+Y1Hz2pZx
	d6CCAvHuQY8YddzJNjCu78rE0xjDdrjzsFsTMAnlwizTQFZTBgHAIo4g6knr1VnsRNFn6tjqTaK
	osXpRmH3gmlgq5uFjUsUabrftV6khSZI/cL31qhfI4OGArCDMKBaBiPaB4I6kj6+DHclgAzLXXw
	cknZBMz59p5yVstZqpE+Q9zDtUKf/fRC63OO7QoO5FWsDGik5iT+TakA3ERawrEXey/qBZCuT+a
	RUW75IoGe+OpHnPNcMaGrbbHV8dE+8AECIs6AeNANq0CVkuIjdrWoRH9yXZyuwCJ4m/hoiXwiCM
	o
X-Received: by 2002:a5d:6086:: with SMTP id w6mr3771146wrt.308.1549995636526;
        Tue, 12 Feb 2019 10:20:36 -0800 (PST)
X-Received: by 2002:a5d:6086:: with SMTP id w6mr3771098wrt.308.1549995635695;
        Tue, 12 Feb 2019 10:20:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549995635; cv=none;
        d=google.com; s=arc-20160816;
        b=hQNl/QFcAyCx5UklXGSFh+H50smbGNNtm8ssk+W4PXRYZtt0zEd88mk3d8CrwkT9ch
         VtrxvEv3rnmKIwGb0cdjItUHPC68OURgQM7I1g383d8Z3MAq8u44OQfBb0wznwHITBJi
         E8f2kJx/ZXci2fTMCEdD/a147bIma9iRekhlMWDSpEbJLdDqZFjpL2pLFOAFq41TMfqE
         A32OtDyCZ3Rm3Qqw78k07uD8NRu3oCRbgLvsMUw4D9Zl7Tb+6jMqiYpInS1SdH4apqye
         b+h1LNuBAfJSGXzwNSyjWMlsOQ7/k0c8t/bnUzaQoA5k/e8iOhFMSdYKQkOQSORO3wb+
         Uc0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=bUE+CRybLrXIaYOIjcJlj0+EDkY0lhfvzRxWOTDT9hU=;
        b=kl66BDe/ZtpMPptJ6DP4tbjeyi7TzVlwVtmAN70i/lpE9XvZSomn8Cw7uxPXaDvzGO
         tQRtdAPTVb9Ld82/vgXdnoOKqk2X4qzU1SOtC6nLyHybDrUnyCf6f4YATWBOVyr31STC
         Tm9nDwu8yNOnUlz7c4wmYwRaD+qOr86tz0c+0w2eSkCBN6iMJFXNxcm9VfgF9emKboEd
         yXeY1djAnV1s+iM/2XG9JNF7zlie6oN+9kIRf776v8JXiT2pB+7oZ4lOnUxwcQFfsN+A
         GkAF3I0bMkKP3l18L23Xu1p5J2CAmjzMhbI4Zfc1YDsQd1noQQc3RkpcMR2IPK2flohD
         v7Ug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b="Bwg4eIV/";
       spf=pass (google.com: domain of ilias.apalodimas@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ilias.apalodimas@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a3sor2297655wmb.24.2019.02.12.10.20.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 10:20:35 -0800 (PST)
Received-SPF: pass (google.com: domain of ilias.apalodimas@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b="Bwg4eIV/";
       spf=pass (google.com: domain of ilias.apalodimas@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ilias.apalodimas@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=bUE+CRybLrXIaYOIjcJlj0+EDkY0lhfvzRxWOTDT9hU=;
        b=Bwg4eIV/uk5JnpxvEDZ7aYV3p09wJgMLUuo7zVplKIugygptVP3tmWzBexfR7U9AX2
         m31g4Bt+jDYkbUTpfyG2UFQORs5AdHxempNNY349LCkrYWEUaj2rHhjytDhHWNtU+Apv
         DAVMon85Be1HZFCYvEIveRqJ0ixVf7QFQv9k7iUJEuhI3jwcMTGXQHDrDQxHqJfSjsT8
         zb/GdOAcv9oWbqmTrJlu+UaJ4D0Rq4kU3P6XLZ7uXyWvk0P6DUCCoxarCgFPK04EK2D6
         QdHVYrlCi9PARKmFkwXHqG2Zrp6ANfZIDG63bz/mjeCx+FUi88fm4AyKg3VTrLbjIooW
         6ffQ==
X-Google-Smtp-Source: AHgI3IahLHucSGj2w0o3CQgw8Qtdao3WBGaSLsyOEh9sRpTljzdv+xhS90TJhKJxiQUKaRQxPdYMHw==
X-Received: by 2002:a1c:f00a:: with SMTP id a10mr138351wmb.148.1549995635073;
        Tue, 12 Feb 2019 10:20:35 -0800 (PST)
Received: from apalos (ppp-94-65-225-153.home.otenet.gr. [94.65.225.153])
        by smtp.gmail.com with ESMTPSA id z1sm8274672wrw.28.2019.02.12.10.20.33
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 10:20:34 -0800 (PST)
Date: Tue, 12 Feb 2019 20:20:31 +0200
From: Ilias Apalodimas <ilias.apalodimas@linaro.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Matthew Wilcox <willy@infradead.org>,
	"brouer@redhat.com" <brouer@redhat.com>,
	David Miller <davem@davemloft.net>,
	"toke@redhat.com" <toke@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mgorman@techsingularity.net" <mgorman@techsingularity.net>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [RFC, PATCH] net: page_pool: Don't use page->private to store
 dma_addr_t
Message-ID: <20190212182031.GA23057@apalos>
References: <20190207150745.GW21860@bombadil.infradead.org>
 <20190207152034.GA3295@apalos>
 <20190207.132519.1698007650891404763.davem@davemloft.net>
 <20190207213400.GA21860@bombadil.infradead.org>
 <20190207214237.GA10676@Iliass-MBP.lan>
 <bfd83487-7073-18c8-6d89-e50fe9a83313@mellanox.com>
 <64f7af75-e6df-7abc-c4ce-82e6ca51fafe@gmail.com>
 <27e97aac-f25b-d46c-3e70-7d0d44f784b5@mellanox.com>
 <d8fa6786-c252-6bb0-409f-42ce18127cb3@gmail.com>
 <CAKgT0UfG08aYoN=zO_aVyx+OgNPmN9pVkBNeZMPTF2KL7XqoBQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgT0UfG08aYoN=zO_aVyx+OgNPmN9pVkBNeZMPTF2KL7XqoBQ@mail.gmail.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Alexander, 

On Tue, Feb 12, 2019 at 10:13:30AM -0800, Alexander Duyck wrote:
> On Tue, Feb 12, 2019 at 7:16 AM Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> >
> >
> > On 02/12/2019 04:39 AM, Tariq Toukan wrote:
> > >
> > >
> > > On 2/11/2019 7:14 PM, Eric Dumazet wrote:
> > >>
> > >>
> > >> On 02/11/2019 12:53 AM, Tariq Toukan wrote:
> > >>>
> > >>
> > >>> Hi,
> > >>>
> > >>> It's great to use the struct page to store its dma mapping, but I am
> > >>> worried about extensibility.
> > >>> page_pool is evolving, and it would need several more per-page fields.
> > >>> One of them would be pageref_bias, a planned optimization to reduce the
> > >>> number of the costly atomic pageref operations (and replace existing
> > >>> code in several drivers).
> > >>>
> > >>
> > >> But the point about pageref_bias is to place it in a different cache line than "struct page"
> > >>
> > >> The major cost is having a cache line bouncing between producer and consumer.
> > >>
> > >
> > > pageref_bias is meant to be dirtied only by the page requester, i.e. the
> > > NIC driver / page_pool.
> > > All other components (basically, SKB release flow / put_page) should
> > > continue working with the atomic page_refcnt, and not dirty the
> > > pageref_bias.
> >
> > This is exactly my point.
> >
> > You suggested to put pageref_bias in struct page, which breaks this completely.
> >
> > pageref_bias is better kept in a driver structure, with appropriate prefetching
> > since most NIC use a ring buffer for their queues.
> >
> > The dma address _can_ be put in the struct page, since the driver does not dirty it
> > and does not even read it when page can be recycled.
> 
> Instead of maintaining the pageref_bias in the page itself it could be
> maintained in some sort of separate structure. You could just maintain
> a pointer to a slot in an array somewhere. Then you can still access
> it if needed, the pointer would be static for as long as it is in the
> page pool, and you could invalidate the pointer prior to removing the
> bias from the page.

I think that's what Tariq was suggesting in the first place.

/Ilias

