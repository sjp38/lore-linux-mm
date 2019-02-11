Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36805C4151A
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:14:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E407921B68
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:14:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lo0nOekM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E407921B68
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 806BF8E0106; Mon, 11 Feb 2019 12:14:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B6758E0103; Mon, 11 Feb 2019 12:14:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67F988E0106; Mon, 11 Feb 2019 12:14:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 27EAB8E0103
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:14:19 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id d18so10309872pfe.0
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 09:14:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=9zX2LaIivP5IrW+2g3nFwEyNT3JVgCgrnDq2ie5w/4I=;
        b=lwcAbNBPeuHLxUyMQlouyLnB7mH6e94eFaLlckczEKe50BIwl14+oq1mlVlSzP+mj4
         Iy84XV4/iSW5lM379nVGkUgxcSs37l2NgIPFG1TVmb1xbQldMzAki0hnyybVDry1mLd1
         NHEWV3S8vsxFBrIucRJqyWaGmYuQfA+6g4oMqcCT1fiparoXfyB2xFYIK6CRmVc7Yotd
         k7F/asIzej79NGwAK7p6T7rlI3RWQh5Qqn54f56Cypv2WIJxJDuHCZSZz95m2QqPJoSj
         g9TEKKGRtEb3PRwKUFHJcuR5Udv6aRa15v2NFfpnkIcsPvWVTlasi8Psb9WcmENLfctW
         ogdQ==
X-Gm-Message-State: AHQUAua5VUm2PeaS7RdmaktMXluC01MSwaO4JR4DEW4pLcWjToVF1+f9
	qysC377iT3W0w4nKtDIw02aiiXMObxUvsR1trirTRypjRTfuv/je57j9LX2Ak4i+/Cuo8zml7MJ
	E8ya2Y1DS0ovVkt9gzmwUrF/haYdqITGXGJHHybOEcO8xPnmRKgcvHNR5f6+Vr5NrfsqfWo6zK8
	YB8bFxiS55CE8XOGy1pyw9K0ShrA4dBXM/f8uvjTaq8Kv2dTR6zLVypScXo2FW97UzI4OQamI42
	xtYJbyRjiv16sDY8zZRAHhjaKdsuVeGBLaIJNU9ALi8hPXyxOn78hKzv9Kc4zn2CMxtnW1AgBkO
	ZPlFJfykRWzh3P4f6h5bupRwWgVhziUwqGs0skBDHb0Pu51NohoWyAU/b5zGP4eGGvHYK5GvxAf
	n
X-Received: by 2002:a17:902:b217:: with SMTP id t23mr5717548plr.321.1549905258863;
        Mon, 11 Feb 2019 09:14:18 -0800 (PST)
X-Received: by 2002:a17:902:b217:: with SMTP id t23mr5717498plr.321.1549905258206;
        Mon, 11 Feb 2019 09:14:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549905258; cv=none;
        d=google.com; s=arc-20160816;
        b=zGw3sAWRi61/99g66VkRTWnYMrApZsN3H9h3VD0kMxDhn2jTOghPWPV7s4sPpalOSa
         bfKxzWQVWDvZfycKuH3rY6ePt249lPCle9ADT6GueANdmk57SwPNMKKCOy9A3ugriFIe
         AT/2F85addSrZheMC4k7yrTU7VExj3p89+S5meQ6nEp9zqVdEzIHgBzGZJDCAqM3ZDGQ
         rdt7JlnI4SMJ05FUtGaaZfmsJpgPn/Km13nxsV5R4BymVmlbSE4oqEAWsboTjfCE2Pjd
         sIo4JrE4WEaLr6dzbHp28M8ySKGC3vDKlk+UtHzuz+VG7/mwYs5mupV5Ax7nlPhJVyoe
         iw8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=9zX2LaIivP5IrW+2g3nFwEyNT3JVgCgrnDq2ie5w/4I=;
        b=rlQUJEm3O5Q2sWUwO2QDiGCWnJJ1jtlxWTjQa6lds2faw6/P5uhqWpIj/S0nBejsPx
         nUqXNgU26lc2Qlh9mo2ThqsKGHkfqZ9qhXDD/NJK6DqsY4zNH1evH0WsgCUhG1d9/R0k
         aQSpjGTcN7bTGhpS7mGn4xfGAK5bmU3xMjMG4mGnrQtlGSB3q0OIPu/p41x04Xbf+WJ6
         CMpDfUXEtA0cOG778o3cjaKj4SIT61OA7JdSgjILWCodFSmDFFTqQfd1Sdxv7ZlaXfV9
         yqh0UcG/cUI1vgjMbIMkYCh+hp5HLfLXUSEgEYgyewvkIXjXSwiMWawbw4Jb3Pd6wiO1
         Smcw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lo0nOekM;
       spf=pass (google.com: domain of eric.dumazet@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=eric.dumazet@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n3sor15229646plk.38.2019.02.11.09.14.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 09:14:18 -0800 (PST)
Received-SPF: pass (google.com: domain of eric.dumazet@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lo0nOekM;
       spf=pass (google.com: domain of eric.dumazet@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=eric.dumazet@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=9zX2LaIivP5IrW+2g3nFwEyNT3JVgCgrnDq2ie5w/4I=;
        b=lo0nOekMsye6WJPkEcUUVJXMoX2EEOet4cU+M+Gqj6dUQoN1FVPd+LuZ0mFOBOwm1r
         v22OzjdcNmLnTyT3Gx6yP75cb/P5IF9/WiEeTI9p6YA1RL3UwzqubY01c1NjWIb4YmwN
         xSrbS6m8GbLDQEyW5XRjjjfVuHODudsxiFixSk+ntcd8jLQwrQkHfOUmeNZSip48i8Zp
         /ouUna2My7GleBMk9iUbDUbEc/Ub5/+yywgpz4c6dMmS2fe7QaT9kyjwhvSJ188//jBI
         a59lTZhj2eMRppGQVaLG+HQQQ2irUc1M1qifII6wEfms3q/A4LDJt5+kTgu5GPg4CIGL
         3nPw==
X-Google-Smtp-Source: AHgI3IbsIoghZPcXS+Ij5y7KSRU3ijsBImHFQk33e0rlJql/8jsaFdJVfSLKuNdSowa6666+PFaHuQ==
X-Received: by 2002:a17:902:7c82:: with SMTP id y2mr37959914pll.33.1549905257696;
        Mon, 11 Feb 2019 09:14:17 -0800 (PST)
Received: from ?IPv6:2620:15c:2c1:200:55c7:81e6:c7d8:94b? ([2620:15c:2c1:200:55c7:81e6:c7d8:94b])
        by smtp.gmail.com with ESMTPSA id l87sm19868977pfj.35.2019.02.11.09.14.16
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 09:14:16 -0800 (PST)
Subject: Re: [RFC, PATCH] net: page_pool: Don't use page->private to store
 dma_addr_t
To: Tariq Toukan <tariqt@mellanox.com>,
 Ilias Apalodimas <ilias.apalodimas@linaro.org>,
 Matthew Wilcox <willy@infradead.org>
Cc: David Miller <davem@davemloft.net>, "brouer@redhat.com"
 <brouer@redhat.com>, "toke@redhat.com" <toke@redhat.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "mgorman@techsingularity.net" <mgorman@techsingularity.net>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>
References: <1549550196-25581-1-git-send-email-ilias.apalodimas@linaro.org>
 <20190207150745.GW21860@bombadil.infradead.org>
 <20190207152034.GA3295@apalos>
 <20190207.132519.1698007650891404763.davem@davemloft.net>
 <20190207213400.GA21860@bombadil.infradead.org>
 <20190207214237.GA10676@Iliass-MBP.lan>
 <bfd83487-7073-18c8-6d89-e50fe9a83313@mellanox.com>
From: Eric Dumazet <eric.dumazet@gmail.com>
Message-ID: <64f7af75-e6df-7abc-c4ce-82e6ca51fafe@gmail.com>
Date: Mon, 11 Feb 2019 09:14:15 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <bfd83487-7073-18c8-6d89-e50fe9a83313@mellanox.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 02/11/2019 12:53 AM, Tariq Toukan wrote:
> 

> Hi,
> 
> It's great to use the struct page to store its dma mapping, but I am 
> worried about extensibility.
> page_pool is evolving, and it would need several more per-page fields. 
> One of them would be pageref_bias, a planned optimization to reduce the 
> number of the costly atomic pageref operations (and replace existing 
> code in several drivers).
> 

But the point about pageref_bias is to place it in a different cache line than "struct page"

The major cost is having a cache line bouncing between producer and consumer.

pageref_bias means the producer only have to read the "struct page" and not dirty it
in the case the page can be recycled.



> I would replace this dma field with a pointer to an extensible struct, 
> that would contain the dma mapping (and other stuff in the near future).
> This pointer fits perfectly with the existing unsigned long private; 
> they can share the memory, for both 32- and 64-bits systems.
> 
> The only downside is one more pointer de-reference. This should be perf 
> tested.
> However, when introducing the page refcnt bias optimization into 
> page_pool, I believe the perf gain would be guaranteed.

Only in some cases perhaps (when the cache line can be dirtied without performance hit)

