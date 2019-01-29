Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32A71C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 20:56:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF73B20869
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 20:56:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tp9GPLwU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF73B20869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 598BC8E0002; Tue, 29 Jan 2019 15:56:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51E248E0001; Tue, 29 Jan 2019 15:56:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E8488E0002; Tue, 29 Jan 2019 15:56:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 155CA8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 15:56:30 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id n124so16866070itb.7
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 12:56:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=PbF++x/c+Rk9/y8urPwBJZolYS/qjCy27gMQV+Aeh28=;
        b=hwFRmcH++rzwXttKUwGKdbQSV5PmW26s+C2+NBZhrNJPMz9aoJ8lCSurgA6GQ20PVa
         kdqLT99KNxHzM/nEB5sMEvr+Vwpss1oK97szmuw4OEDA91o6DxZYEXqgYyuQGTSF3iBV
         fTYXiiy2/KZTSmXjhaMeTiZYiK8rfFYlWPi034wJx2e9717Jc26qFsVkAwujNennuHGZ
         fyehP4g2movQvYH81VAyYTsJFcX7CqNxx0ff+xNL7SPsbkdzdJR1md2yBontPaJKzw3u
         d/AVu8fcIomqmng8WqHcyRU+GD0I8xucJyaDgqX9w3oSyRHL3owg0Yw1z5uMRjfRX23W
         kj/w==
X-Gm-Message-State: AHQUAuaE80dpOOiC4QBKRC0pa3V337NW5rbtKXYCqW1C4uNeWvFjbdSR
	wE/M8Z4piZJFXoCd8zstzRwxytSwXukpNUEu4OdnmaO/cUi4FeKhisfiJe7SxdlWuMe0Pb9YKP7
	2+d8RyrHm3F9pMmnZOtrXoUX5R6IywoS4O/95QqdjNH2/KYbi9JfbI26k6cgVsA4J2OPB4gLUul
	HPOfT8GhdAgLbSAPayy/B/tWfNhufSI2MljB1s/BvZzUsHFjSi0zOORj3WBsMEsRI+YiZ6PxwJH
	hQgqfk3y2sxijnj2OmkRmNRFGAbOnDCbPj0C9A7ksdAY1FqFuYVtc+um3zVmunFT0QN7UJ5x9RN
	fEoezTiPACHpEgn867fHJ6KZ9neX5HSb5wvFrMndUzwsL19/QuAzPIv6QAYjcnUL225sX97ChR/
	v
X-Received: by 2002:a6b:8e03:: with SMTP id q3mr16445170iod.51.1548795389880;
        Tue, 29 Jan 2019 12:56:29 -0800 (PST)
X-Received: by 2002:a6b:8e03:: with SMTP id q3mr16445132iod.51.1548795389384;
        Tue, 29 Jan 2019 12:56:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548795389; cv=none;
        d=google.com; s=arc-20160816;
        b=GtfDdCumBdSG1TlDe9FGkmH3akV7/8Pl3jD/aVIiZfAHVIHOk/r8QThntoRshFxzF1
         Nw1mr0U1DbsG/2GfTn6mjFoxDv4KbtGJCwm59KmNUE8QE4YJQnKTcZXiooxshUIewCdu
         qSPao3oLfa2+ASD5ZrFr98HtwRgTK5RVlpGV12p2mwc5y0KL3TMHE4cytbkvOEy5Ge2b
         ybnQdRdpolPuBrllEV5s63dtBLYBaHXWYRS1nqRIj4YDoMaLqwhXe1ChYAxFjy+Uqqb2
         977hOWoMx/S379WIPJOZhAtfxz7Le+ZRiOvPXqIb/7lUxZX7ti1ikzcJg9HPUqGLozUO
         zQZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=PbF++x/c+Rk9/y8urPwBJZolYS/qjCy27gMQV+Aeh28=;
        b=B5PgEgt5zQXK+dmiLZ71a59bSF33gjzpvSqJ9Or9doUbU1wIaRJNKSAV+vcU1c/mNH
         dEdD4uYJL7fyVhud56Vv5z2zFssC9zqiG7M5uRbjBHOcoMhMKPuz1zuHzNLYgiRlMxA3
         +ukBIDdvY1pLxJdEbPlY5Xh4IafVWdEh/DsicoxHBrkInCaj402j9pppsmbXVL7Gz0eA
         vZWemHeK5al06uLXJu8YMMAhhBBvH4JYhjX/bvDSM0kvflr7mDKPPu3cP2s7BUghgldI
         gGg7GS8dTFLJI2mdiKDnwWRckpxpl58rZuKyMhllSBVuHukeSRjUeXXSAI1ouMxA/guv
         NBVA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tp9GPLwU;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m73sor5957887itm.20.2019.01.29.12.56.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 12:56:29 -0800 (PST)
Received-SPF: pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tp9GPLwU;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=PbF++x/c+Rk9/y8urPwBJZolYS/qjCy27gMQV+Aeh28=;
        b=tp9GPLwUgbRRb80MNnnerGpeJkzkpH4oWqtWjxuhGUmLrqTiW1/S6nw17TQ7WDuma+
         48rCf7lL8fstJpVdPeQx5UPDKjFdme0FWWw/0hvoxkpjdMhheQSN3vwqndVgpMIHLVlG
         GZ46lsik7z4xMCi/ABEB/1DaPs1+knJfzMMARGDjTvGgOocn53l6VUA/pRMwLq/lGzFC
         mQ1Lk6hnJr+136o0rBxLMBFzhrUtJt1r+9qhWKF3Y97j42neaegPVHOFNvQpdi4qfNlx
         rugFyKyYLhzE0jr8mxjJKAwniPaGEOjJ5hKIOt7y5LoEUPXCauihX4/dzecAmr5bjbSB
         EmTQ==
X-Google-Smtp-Source: ALg8bN4zHSFabZZo/4FI9LtIg2/+xT6LXak3S1kpLCNEodVKp0yKbyT7uT3noZnxWni0iogkCby5h10I2gspmQWw8BA=
X-Received: by 2002:a24:2e94:: with SMTP id i142mr4857501ita.157.1548795388816;
 Tue, 29 Jan 2019 12:56:28 -0800 (PST)
MIME-Version: 1.0
References: <20190128144506.15603-1-mhocko@kernel.org> <20190129141447.34aa9d0c@thinkpad>
 <20190129134920.GM18811@dhcp22.suse.cz> <CABXGCsPM-JrdxN9t-HjkWxJJzdGHiJZOYD5p-CsjGEFSQ=+DwQ@mail.gmail.com>
 <20190129202440.GP18811@dhcp22.suse.cz>
In-Reply-To: <20190129202440.GP18811@dhcp22.suse.cz>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Wed, 30 Jan 2019 01:56:17 +0500
Message-ID: <CABXGCsMk_kj5HxsHncAFFp4Z3trDfL3j8fpcLv3Q_Hj4tGgH2w@mail.gmail.com>
Subject: Re: [PATCH 0/2] mm, memory_hotplug: fix uninitialized pages fallouts.
To: Michal Hocko <mhocko@kernel.org>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, Mikhail Zaslonko <zaslonko@linux.ibm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@soleen.com>, 
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, linux-mm@kvack.org, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 30 Jan 2019 at 01:24, Michal Hocko <mhocko@kernel.org> wrote:
> I do not think so. I plan to repost tomorrow with the updated changelog
> and gathered review and tested-by tags. Can I assume yours as well?

Sure

--
Best Regards,
Mike Gavrilov.

