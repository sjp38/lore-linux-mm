Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 276B1C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 18:13:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D92D5222C0
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 18:13:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hsyVPGTP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D92D5222C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 721F88E0002; Tue, 12 Feb 2019 13:13:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CEE38E0001; Tue, 12 Feb 2019 13:13:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BDC28E0002; Tue, 12 Feb 2019 13:13:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 35DF58E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 13:13:43 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id y205so6280679itc.3
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:13:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=F0p+xt5vznWMTU0vCETmzhDxvo4auw2dSjPdQFEyJl8=;
        b=nmnn8O7vMcpSyLEzhdmIF0iYaR6DUYP0p/X33X4rwZfDDezruZwrQyg++cKUXMNyZ9
         jE3uHHmUtYyVE4mpyGlPJa3n98mv3a7fGpUF+6HLc4MSFRPOvYz0TWVVzho6OpWkZpN4
         mL+Ro4GnZZmXq3B//yt3aBp4oaET1Ud2gxIbQXR/DKJL1zi2esvz1qzi2h5rSCMEjBK6
         3n5wkw/3ZQiiJgkDm5v+QKkWccvw3oI2krrEt57T4oy+y3Fzqxn8MyMf5Lc7uqfZl329
         NIAS4XID+frCkMCSB7+b7jefoV4SuZMP84yYOjKWIrNY7Yu9q5zckmKkMGoDZC2yMzyN
         z97Q==
X-Gm-Message-State: AHQUAuYGt+xSxAqcdCEK/bz/FxfA1ZyBPrZte4a5PkKKFNiQut8Ry/PZ
	Vqpo2nYvzUI6A8tHbHQcWsd1bGCCVdenR6XWooIvOHx7JOBxYWD/QMMjjgoDvNTFe326zTxGs7g
	n5ZL2T32Wd65UftU0qjA8Mtd9DXmBRUebuxdb9gsm9FtF4kpNEh2s7JIfYEZRrS6KuFgAaEJbUx
	+6e/DeLo/qdNDmx+k6bvSA5g+EitVYZNslCpntPBrnHjse8El+cC6WiMLrSFwsdHLrPL0LDYofp
	zcMdwYmlB6xi9HdEQnzsP/+a4IjD93lIIW0l4afZpG6kIWNY4Y/Xp68B+MA3r4uut43F3lHT2gb
	TLq+eksw29H4lN29wFQnoWpa9OkxUzYjhEP5oSub/nOzf2Ti70O+K7IBSL1cpr8yilijLz0kwIS
	L
X-Received: by 2002:a02:9f19:: with SMTP id z25mr2671061jal.3.1549995222943;
        Tue, 12 Feb 2019 10:13:42 -0800 (PST)
X-Received: by 2002:a02:9f19:: with SMTP id z25mr2671023jal.3.1549995222265;
        Tue, 12 Feb 2019 10:13:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549995222; cv=none;
        d=google.com; s=arc-20160816;
        b=0vpv7bb8lJrJsUeaQF9zwZMuv6jVYE/sC+QrAUCxX8mJoQMBcYmdx6hwywfs3UKp8J
         FwJJlWUYctEzbjzMOx4tTy08dPo/Kbmvz0nEYfVc0GqBFEgHnZ2HH6fHMc1l7wWUUko0
         qL6GeqDPB7/MnYaMCso3GPdmKBscnqfRlCbbT7fvAW+bF7SCf31QBKOeqYDeKflMfbIh
         Kvox03pOfu8KA5rd5vXE6Lk63pOzaC3fcDb3kMJCOLXwSw8B03eGi0ZSnu8nmJyhGdW7
         uewcQxd/1fsiqiPp/poVUJPMfL0iK502MZKWs92QiAcMEB/rvCR/jgvnBKINOihuEXhh
         W7jg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=F0p+xt5vznWMTU0vCETmzhDxvo4auw2dSjPdQFEyJl8=;
        b=ANUcOIp2Me8a5WXj62Edfr8YxlC0FHPfWUkk4wAhqtzVVB2Il4OqoBNGMop+RkcfjT
         bCKVvc38Z5PoevJNy3oWJSAIKGtXFNNASe365hZA2Q4AtBcPMlOyBwK/VjZDEp4zYr9/
         vDpNggAeNuAgOv1WzruEnPo3OV7FT3Tq1GXug55dmIk2LAPxdUJnkmvNTpNCrO6OYueW
         gxwQzlJcqYjPZ6P3lWUOPwEhv9wTtO0eO5KZSogqOUk2sRe5iBD6faCrxI4Wwvmh/tAY
         XzZCrHvg3bPVFi9jcVqz/mmIZbwKcqZFgCgaZ3+mb6b3LJYqkmoJjrnh5pME93OCI5KH
         Ej2w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hsyVPGTP;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q4sor3209158ior.73.2019.02.12.10.13.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 10:13:42 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hsyVPGTP;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=F0p+xt5vznWMTU0vCETmzhDxvo4auw2dSjPdQFEyJl8=;
        b=hsyVPGTP6KvQJqWC8CnVlSYlmsMdQss9hPZzHuumejeg3WB24J/be+PPTHol+75mDt
         T/ooXbTeXhO7nKleIBCGpIaIqVNfTZlYR+/Bw9TXRFchZVFRQ/sFF3PDPAR1r2712Mv0
         iVs+VMNzQCyKSEwDbOU+G5kkjAk/yIK5f6HaKPVIDFoLFBigqw0OFbQBnKeTW3TfaOxO
         hfuf11pbexNh/7cycD4ddDJ7gyeTL/lUT01Qi9+79M+vivFCT6qZn/Sx4ztkmAm73aTx
         orKLSa8Dd8VKNB61hP2UjXxiCeLtms+2m4F7PPHx0i++K/1jl1M8IfO4n23XO6fSKobR
         NtPg==
X-Google-Smtp-Source: AHgI3IZdsu99OxLgYYFUrBQ9yaFPM3RWZswyQ7mSktWFr97QQmp3Szi/KSd5KK7AmLhEAeK8U2m/OP05SemjAkltyD0=
X-Received: by 2002:a5e:8c14:: with SMTP id n20mr2635979ioj.200.1549995221824;
 Tue, 12 Feb 2019 10:13:41 -0800 (PST)
MIME-Version: 1.0
References: <1549550196-25581-1-git-send-email-ilias.apalodimas@linaro.org>
 <20190207150745.GW21860@bombadil.infradead.org> <20190207152034.GA3295@apalos>
 <20190207.132519.1698007650891404763.davem@davemloft.net> <20190207213400.GA21860@bombadil.infradead.org>
 <20190207214237.GA10676@Iliass-MBP.lan> <bfd83487-7073-18c8-6d89-e50fe9a83313@mellanox.com>
 <64f7af75-e6df-7abc-c4ce-82e6ca51fafe@gmail.com> <27e97aac-f25b-d46c-3e70-7d0d44f784b5@mellanox.com>
 <d8fa6786-c252-6bb0-409f-42ce18127cb3@gmail.com>
In-Reply-To: <d8fa6786-c252-6bb0-409f-42ce18127cb3@gmail.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 12 Feb 2019 10:13:30 -0800
Message-ID: <CAKgT0UfG08aYoN=zO_aVyx+OgNPmN9pVkBNeZMPTF2KL7XqoBQ@mail.gmail.com>
Subject: Re: [RFC, PATCH] net: page_pool: Don't use page->private to store dma_addr_t
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, 
	Matthew Wilcox <willy@infradead.org>, "brouer@redhat.com" <brouer@redhat.com>, 
	David Miller <davem@davemloft.net>, "toke@redhat.com" <toke@redhat.com>, 
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, 
	"mgorman@techsingularity.net" <mgorman@techsingularity.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 7:16 AM Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>
>
> On 02/12/2019 04:39 AM, Tariq Toukan wrote:
> >
> >
> > On 2/11/2019 7:14 PM, Eric Dumazet wrote:
> >>
> >>
> >> On 02/11/2019 12:53 AM, Tariq Toukan wrote:
> >>>
> >>
> >>> Hi,
> >>>
> >>> It's great to use the struct page to store its dma mapping, but I am
> >>> worried about extensibility.
> >>> page_pool is evolving, and it would need several more per-page fields.
> >>> One of them would be pageref_bias, a planned optimization to reduce the
> >>> number of the costly atomic pageref operations (and replace existing
> >>> code in several drivers).
> >>>
> >>
> >> But the point about pageref_bias is to place it in a different cache line than "struct page"
> >>
> >> The major cost is having a cache line bouncing between producer and consumer.
> >>
> >
> > pageref_bias is meant to be dirtied only by the page requester, i.e. the
> > NIC driver / page_pool.
> > All other components (basically, SKB release flow / put_page) should
> > continue working with the atomic page_refcnt, and not dirty the
> > pageref_bias.
>
> This is exactly my point.
>
> You suggested to put pageref_bias in struct page, which breaks this completely.
>
> pageref_bias is better kept in a driver structure, with appropriate prefetching
> since most NIC use a ring buffer for their queues.
>
> The dma address _can_ be put in the struct page, since the driver does not dirty it
> and does not even read it when page can be recycled.

Instead of maintaining the pageref_bias in the page itself it could be
maintained in some sort of separate structure. You could just maintain
a pointer to a slot in an array somewhere. Then you can still access
it if needed, the pointer would be static for as long as it is in the
page pool, and you could invalidate the pointer prior to removing the
bias from the page.

