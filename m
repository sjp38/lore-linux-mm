Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0807C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 22:33:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 438CD217F4
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 22:33:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="rJm/bKIj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 438CD217F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B44BD6B0003; Thu,  8 Aug 2019 18:33:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF5096B0006; Thu,  8 Aug 2019 18:33:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BE506B0007; Thu,  8 Aug 2019 18:33:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 617A16B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 18:33:04 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id g21so60056158pfb.13
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 15:33:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=o2EVs0fRTQQKeqIepJ2aVwMX64LCEoyth+cmmxU0tbw=;
        b=Ar9catGc1UZJDrPVPjZzXWn+y6KT5x+cyKv3Lev/N2aKrM8PSqjYGMmr9qnLAh6aGX
         HUJ/3nQYw73hmaARf7hgKVfhtdACBnfdKYkzyDIrk7b9Wmq2H4NvZ3X1MwlKlox7Mxbc
         W099BC28rGzD7rGn04Oftpmc9T+cz/qOiKEvY1oxcU9KcX7i/fuDPUo4bne+ooKdnJUe
         c0Sv9LY3Wvyyr9uGcZPULaBH0MyiEWjkVqdxSTDky7wBo2D6JuVeWT1zE9nGBJhYetqg
         coDNuQ+fO1ZChAEsMTFLnXJLDOwluoKfgOS5I7fatELU5sBldKMFZ0OO/frTZcwNQwWW
         dTpg==
X-Gm-Message-State: APjAAAWXBO1Q61JZerOFMI6aoSPw0+aYu6IryyksL9R5xC0sUFPVPNCG
	j/433CgpbTF36W/xSSARlKSi1WQ5bePrKQ9M76kSR6Dxu79dWUqAKgYMHGntBuMdinzBXcYR5MF
	lJr1Pxcx8Lgmhx063S+jxbf1A+zOqgby9Bs3ftZpGfmTpfeSjIr0wu+XiJC4OtUDeLg==
X-Received: by 2002:a62:8f91:: with SMTP id n139mr15730902pfd.48.1565303583955;
        Thu, 08 Aug 2019 15:33:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0dkioTZoYCGgIN/rCx0PlOzW2DyAJu7SO85c0X1Of5ZaGmWoiwJrnbqz4p2afCK4XKJOT
X-Received: by 2002:a62:8f91:: with SMTP id n139mr15730835pfd.48.1565303583105;
        Thu, 08 Aug 2019 15:33:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565303583; cv=none;
        d=google.com; s=arc-20160816;
        b=jFh5ARhtC4IklqKPml6LqNqQ5wWTBYI3YbEaWL5TScG7lO9nNyahpw0LVscKAd0EG0
         juN3P2VfI3++0hMaapgoYmWLdcOdj984mBPn2yd7mS2GO3NVy1vSTXZ4LGih4hnsbha/
         XKz4oplEy/YLsh3Ty7iZ7Y8lgemsnSd+spG/ejcBo83decoRhvwZ+pX1sU1A/faJ0uda
         3KGHiDMVOFrGxD/P+BHAA5z9VtRmn1moiQNOYKaF154j1qq9dpfXoJFBD2TCcYJwTg9o
         9rkCeLB0NQdUPcFn9oz7rQ6/BpStEsCKKTI0H4rUmxCc51mbsJWuq7jZnP0JcdomROYt
         9/sg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=o2EVs0fRTQQKeqIepJ2aVwMX64LCEoyth+cmmxU0tbw=;
        b=lwUI9U4F80f0gaRo0UcsvNtL/SFCBQrQoo/N2h1NTz/5oprWvQtB6tn2MQptXPiKO4
         BLw+wRKvmyur/r1WL83NFXebSadlx7efleZsBbTdnB62ct+yhR7gEQGyCl8/Sz2xXJ+E
         MerZ1txPtbCd2V5n/7XZ/gzO4/MBFUCMXIqK2PwPgSFFCzarJ2Nd+xzkO/SXDr8ug74w
         Q6Mtc41Kq1iiv7lD/luGv65+Bxs6qRFA+Ya3RjX3x8usuwoKHivemTiv8M0kzWof8cm5
         jcRqnFaCA65RRg29qdKUb4VuUCBXNN0O8v4kiaqmz39j9AlBPYI5Y0fpCjLe1zrqtqdy
         QMMA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="rJm/bKIj";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n123si36154162pgn.151.2019.08.08.15.33.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 15:33:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="rJm/bKIj";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1ECB5216C8;
	Thu,  8 Aug 2019 22:33:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565303582;
	bh=M1LHDKT+Utjw2MuliMFXwjmQGIz79EFLeGhC6jmdeW8=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=rJm/bKIjqOczu37MctJclbvuCqDc2bjNbCOceXgrdzzO5jdTQq59GCZBl+aaSOFHo
	 JWftfKITVhkjQlcdggzJR5GIR3v5lckbgstfbb5fdsE0+HHu12+i5Q62vy30iUhD6A
	 xVNDNvwKYNXCR25osWwquW4PqKI0St9mmWBTs9xA=
Date: Thu, 8 Aug 2019 15:33:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrey Konovalov <andreyknvl@google.com>, Will Deacon <will@kernel.org>,
 Will Deacon <will.deacon@arm.com>, Vincenzo Frascino
 <vincenzo.frascino@arm.com>, Catalin Marinas <catalin.marinas@arm.com>,
 Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org, Szabolcs Nagy
 <Szabolcs.Nagy@arm.com>, dri-devel@lists.freedesktop.org, Kostya Serebryany
 <kcc@google.com>, Khalid Aziz <khalid.aziz@oracle.com>,
 "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
 Felix Kuehling <Felix.Kuehling@amd.com>, Jacob Bramley
 <Jacob.Bramley@arm.com>, Leon Romanovsky <leon@kernel.org>,
 linux-rdma@vger.kernel.org, amd-gfx@lists.freedesktop.org, Christoph
 Hellwig <hch@infradead.org>, Jason Gunthorpe <jgg@ziepe.ca>, Linux ARM
 <linux-arm-kernel@lists.infradead.org>, Dave Martin <Dave.Martin@arm.com>,
 Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org, Kevin
 Brodsky <kevin.brodsky@arm.com>, Ruben Ayrapetyan
 <Ruben.Ayrapetyan@arm.com>, Ramana Radhakrishnan
 <Ramana.Radhakrishnan@arm.com>, Alex Williamson
 <alex.williamson@redhat.com>, Mauro Carvalho Chehab <mchehab@kernel.org>,
 Dmitry Vyukov <dvyukov@google.com>, Linux Memory Management List
 <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Yishai Hadas <yishaih@mellanox.com>, LKML <linux-kernel@vger.kernel.org>,
 Jens Wiklander <jens.wiklander@linaro.org>, Lee Smith <Lee.Smith@arm.com>,
 Alexander Deucher <Alexander.Deucher@amd.com>, enh <enh@google.com>, Robin
 Murphy <robin.murphy@arm.com>, Christian Koenig <Christian.Koenig@amd.com>,
 Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v19 00/15] arm64: untag user pointers passed to the
 kernel
Message-Id: <20190808153300.09d3eb80772515f0ea062833@linux-foundation.org>
In-Reply-To: <201908081410.C16D2BD@keescook>
References: <cover.1563904656.git.andreyknvl@google.com>
	<CAAeHK+yc0D_nd7nTRsY4=qcSx+eQR0VLut3uXMf4NEiE-VpeCw@mail.gmail.com>
	<20190724140212.qzvbcx5j2gi5lcoj@willie-the-truck>
	<CAAeHK+xXzdQHpVXL7f1T2Ef2P7GwFmDMSaBH4VG8fT3=c_OnjQ@mail.gmail.com>
	<20190724142059.GC21234@fuggles.cambridge.arm.com>
	<20190806171335.4dzjex5asoertaob@willie-the-truck>
	<CAAeHK+zF01mxU+PkEYLkoVu-ZZM6jNfL_OwMJKRwLr-sdU4Myg@mail.gmail.com>
	<201908081410.C16D2BD@keescook>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 8 Aug 2019 14:12:19 -0700 Kees Cook <keescook@chromium.org> wrote:

> > The ones that are left are the mm ones: 4, 5, 6, 7 and 8.
> > 
> > Andrew, could you take a look and give your Acked-by or pick them up directly?
> 
> Given the subsystem Acks, it seems like 3-10 and 12 could all just go
> via Andrew? I hope he agrees. :)

I'll grab everything that has not yet appeared in linux-next.  If more
of these patches appear in linux-next I'll drop those as well.

The review discussion against " [PATCH v19 02/15] arm64: Introduce
prctl() options to control the tagged user addresses ABI" has petered
out inconclusively.  prctl() vs arch_prctl().

