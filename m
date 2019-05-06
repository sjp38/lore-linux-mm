Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDDCCC04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 19:50:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9445820830
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 19:50:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="mAg8m7rS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9445820830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 293CB6B026D; Mon,  6 May 2019 15:50:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2446F6B0270; Mon,  6 May 2019 15:50:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10BC46B0272; Mon,  6 May 2019 15:50:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id E484B6B026D
	for <linux-mm@kvack.org>; Mon,  6 May 2019 15:50:23 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id y10so9607153qti.22
        for <linux-mm@kvack.org>; Mon, 06 May 2019 12:50:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ESsJ96JGC0CvnjgihpL/0kogE+VQksbbiyHqcPsgGyM=;
        b=UG/bvQYPdJ9E6NqOBhVsAHeKIiXUt97zaL3efdLgCZmB47k1tzzeDtKeCLRC6F1Fpy
         IJ3NOus2FavsEpzLHwSwYRNW+FI0oMN2EOjrhD49nm99PKjMYDCriTIPsjdAxcZ0+5CF
         yMRflMGy7/2dFJZGiiSiWw0+4vB/klM36nrPkNmglLB6wBJNozyd62SBvMPa6FzARinc
         y5TS67TQq1E+uKlYMSUYqnL0puQ3LAXdIDOqJCvOqp3gxPPni+sU3Uh+vsSqyKydL0Yt
         QL/wpVEbPtwNcGuQ+5GYhOwQz9aVB0GavPmilW5AG2REW++JYfNKFXpEEiJDwqwYXD0Z
         x8Zw==
X-Gm-Message-State: APjAAAU+lsy9Rcu/510h85ci2Gp4FKAfFRSg82hb4Yu5JV29y5f7WD1Z
	G8vaF4GEL+QkL9pkfg1bcJItGHRBY+/3mHDJ0OevoyVFQGiAM2C9HK1hV/jN1pmC8BtwEu6vHh/
	YhLobvTjUDymMlRRz+U8PT2ml5JeAueelFpPgkHxmU9ob24F6GBa92OcNaxWMOFwixQ==
X-Received: by 2002:a0c:d7c8:: with SMTP id g8mr7327277qvj.231.1557172223676;
        Mon, 06 May 2019 12:50:23 -0700 (PDT)
X-Received: by 2002:a0c:d7c8:: with SMTP id g8mr7327231qvj.231.1557172222992;
        Mon, 06 May 2019 12:50:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557172222; cv=none;
        d=google.com; s=arc-20160816;
        b=Xp3/5KyOnZhtBwYzn7u6r8Pe31w6j8tD+UAk/MxfgyeQluj81ReX122vnoWKQE3m7s
         DK8kVW2ov7f7uwEHUDlOoATKIAJTOQmOiEMXl4XAJwtlYIlWJc7IfamhBa8CQrGg/pE1
         27rM7FaWiHTDpqReMkCpqxKVLRw3A6QSYRxh4p4+bIU100wuB5r7zpOLhfNwMF2LYqY5
         VAWoSRX3KU4ZgD1y6dIpoyFCjoKl2xpIvjunMOJ/kvoKXzjJi4gQzglWH7Xg8J31Il5V
         ef+xB8Iq+qIBNy9eK04RfpGi/9Bfsv99fqmLMeMS43JvZnjyuzLrEmny+wEvm/16lwRW
         zw+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ESsJ96JGC0CvnjgihpL/0kogE+VQksbbiyHqcPsgGyM=;
        b=kGoPDf2/7SLvaK1HOppq0sA3LErusGZSu0+KVNhDQ6yW6Z4BAp6ccU/SfkP1VAn/xr
         sqPF/k+gXoREzCW3UW8kHC3VTTivohHuXM1mZ4i912NaRl8+bC27JHpFE3nZNCMGLV/7
         1WziiSxTN3wSkIZFqPnPCaI81a5F/KwcsC6eH1STUGQYzqHu53h5jafoxpTbKyThHNJI
         G6fdBKdXDpUh07cN3UBswOZ52YsRaZB0H4fudOrJieYScPROVZRXLFVm8shTrcXGbnse
         DR7KSPrP2alBTqTCGgfv8bvcTCXYOOoBs15iOmu4YWQtGk7L+r+mjR71yz1h/WeYnfav
         p3eg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=mAg8m7rS;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y15sor6570272qka.102.2019.05.06.12.50.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 12:50:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=mAg8m7rS;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ESsJ96JGC0CvnjgihpL/0kogE+VQksbbiyHqcPsgGyM=;
        b=mAg8m7rSPAxM5D+1qNjO71dhsXUrQSGF8zaXxmrvN1W1e7B7fEhL/nFNC4QmlTH5S/
         9FjLthJrMSnJTSlBNmAzOuj+WEEEHBw1j3jchmVO404WkT8GTT4n4WekZCWvQcvu4KOF
         mx0V5cfxdymPVb2Ruxoza7w5KItB51NAJ5xivBL7H4fj5rRig8CXPXI75f55CKvkZyYC
         Gs093sJb6bHKcKo1jSkGyp2Pk8c68+e+QijlfKiUVNZuBsCjguF+Uc/8jtTaC+sffP6g
         22gO2vicgInFZL3gRZwFvB6M65AQIPZr/G+9s6iQjRuVRTS6fQK5LrCRIMT4SjvjNieX
         MViA==
X-Google-Smtp-Source: APXvYqweK3T+QR6CpnWc0KpWvE878/YztoCohPUsZDawCWkz4P9i6ckWrJvxSZLqhWTPckszjgD1bg==
X-Received: by 2002:a05:620a:16b4:: with SMTP id s20mr10803976qkj.34.1557172222493;
        Mon, 06 May 2019 12:50:22 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id o44sm9303175qto.36.2019.05.06.12.50.21
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 06 May 2019 12:50:21 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hNjcy-0007kq-Cs; Mon, 06 May 2019 16:50:20 -0300
Date: Mon, 6 May 2019 16:50:20 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Catalin Marinas <catalin.marinas@arm.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v15 13/17] IB, arm64: untag user pointers in
 ib_uverbs_(re)reg_mr()
Message-ID: <20190506195020.GD6201@ziepe.ca>
References: <cover.1557160186.git.andreyknvl@google.com>
 <66d044ab9445dcf36a96205a109458ac23f38b73.1557160186.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <66d044ab9445dcf36a96205a109458ac23f38b73.1557160186.git.andreyknvl@google.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2019 at 06:30:59PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> ib_uverbs_(re)reg_mr() use provided user pointers for vma lookups (through
> e.g. mlx4_get_umem_mr()), which can only by done with untagged pointers.
> 
> Untag user pointers in these functions.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  drivers/infiniband/core/uverbs_cmd.c | 4 ++++
>  1 file changed, 4 insertions(+)

I think this is OK.. We should really get it tested though.. Leon?

Jason

