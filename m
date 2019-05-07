Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_HIGH,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35A83C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 06:33:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB16020C01
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 06:33:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="RyPsl6lm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB16020C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 769206B0007; Tue,  7 May 2019 02:33:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 719B46B0008; Tue,  7 May 2019 02:33:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E26A6B000A; Tue,  7 May 2019 02:33:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 253756B0007
	for <linux-mm@kvack.org>; Tue,  7 May 2019 02:33:44 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id g11so1267884pfq.7
        for <linux-mm@kvack.org>; Mon, 06 May 2019 23:33:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=WbVwG83/kioqURG4Mo71oa7hgX6PokLxVOus+KDdrdU=;
        b=Mkr2BTLClh/8bVKO3E3tzs15L/McBtAflsLWJL+hvVOyQ4hdEZjrQxK7Ab12HqCbzZ
         DjskV2OjL4yGX9GB1Sz4RUCZJgk4wfcQjcRXw5yQ7ViCNR2VcLRL61c6S1aj+9P+LFjz
         x6gviinup1l/n7W5J7ixwZaYvAlIGC4OVJ+cN2oaQJmIdmaI8bBLiyIaMQ/J72f/eTGS
         OLP1HQ+8Ebe+54zAvIwRdxuWiLHL8g0RLIk0TZ0htF5lW2LLVfnvFErz71b399v5Y4Xb
         kVFaTvpUHgDN0gYkgMv6+4Hbqh/mM7921P+x+sC6zTawqMkMFyOnYc1p2QczVHdr0W5m
         l0xg==
X-Gm-Message-State: APjAAAXYhqd4VSlZGXWcGyi1oA53Va+8We6SczK8GNqvneGysUZGfyzw
	jPDfDJgyWBOOwdk8AAXWJfoRL/svy3n5HOJed50PXdActEl0V+RGdGqeB1zeFZ+DSDsdVlFbjRF
	YnNkZ8k18aCO5HiTRZ288L+3Pcaui6nN/DtsOKgA61wAiU4Vsg8FuqaG/E3MyFZwV9A==
X-Received: by 2002:a63:ed12:: with SMTP id d18mr38652198pgi.248.1557210823728;
        Mon, 06 May 2019 23:33:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxX9QQ0JS6aCmd5Tnj/FDreBcQqvUT7PT+Ajb852V+aaM8LTsauf+ycLLZPxCT43cMSHHxX
X-Received: by 2002:a63:ed12:: with SMTP id d18mr38652129pgi.248.1557210822889;
        Mon, 06 May 2019 23:33:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557210822; cv=none;
        d=google.com; s=arc-20160816;
        b=l00mOdWGvGqztKzjDCGh9PXUyiolbAwomNTHjTa2trv13kEMaCTticU/gdb/fbgpxl
         OyotB4xAA4HAGLYmDJqmVhFsTQP0RwfyWV6XemcDTIe4R0W/auxoSCUaTEACqZIQ36MN
         F4Oa409/E8cSykdCXrTXUgn1ySUsIzBX9mmJixM63xpJ7fKXZRxXHGyIoej0A3v9Jelz
         U6Ui9VbR/L/0E7vdLLXSRhTWrha816e0CzJofo3ctgWixKONtdcIMRafVK2hRBnborAF
         0i67nCB9V3sGoegPL+3XeynS2UO14PPi0LRiK/uwHzXU9PgJ6V3hKBT6Gpq8R9Zjh0px
         hARA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=WbVwG83/kioqURG4Mo71oa7hgX6PokLxVOus+KDdrdU=;
        b=WwXhNbq7izjSfwyHUI6Wvu1ZZhERuluXKKqW2qc2iojpIyDSl0jsjRi8uSYYctTqRA
         vf2PlCddqUC8GXK2pKyx3x4x4cZQ9PuXebX37T92fcPKP+F12E+jECckij3NY5xczgQP
         NVbaLEdUzxWQR3uECQtFRUpFVNy/0rO3lf0h7lYhmS0Njb+A6QlmfYGR1ro/1t8NYMNQ
         +TYyOGUQoq2dR/juFCsShHFjJdQa+gF0/gVPQQHRcPAKSA/DZ3L8h1In0muvQRGj24Tq
         GnZgfeFikc9t3PpDhRM4a3/GRu8lo0+sAHURyMF7aK4mSJlC6LAar0FpgIWMkr+952uk
         YoxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=RyPsl6lm;
       spf=pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=leon@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e26si152747pgb.368.2019.05.06.23.33.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 23:33:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=RyPsl6lm;
       spf=pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=leon@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [37.142.3.125])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D6C092087F;
	Tue,  7 May 2019 06:33:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557210822;
	bh=oBFyk7fpihJdB0jCxegQVyX+6vGmLC1DK9IvU35itFk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=RyPsl6lmqvcCnKl41VkY/GHW2+ETy7nDPo8Tpqc6bp7gDCBLdqWePFxG5B2Wa9vwT
	 R3/WlBSqCc8Bj3KtWz9uGTPPZS6ordaRPlQ/fveMibMSWfgfc4tq1AglaAlmwW4kMa
	 oMxOIvxG2cStHRR+RV/gLi/uVrPbQ27CrKcpR2aA=
Date: Tue, 7 May 2019 09:33:37 +0300
From: Leon Romanovsky <leon@kernel.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Andrey Konovalov <andreyknvl@google.com>,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
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
Message-ID: <20190507063337.GP6938@mtr-leonro.mtl.com>
References: <cover.1557160186.git.andreyknvl@google.com>
 <66d044ab9445dcf36a96205a109458ac23f38b73.1557160186.git.andreyknvl@google.com>
 <20190506195020.GD6201@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190506195020.GD6201@ziepe.ca>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2019 at 04:50:20PM -0300, Jason Gunthorpe wrote:
> On Mon, May 06, 2019 at 06:30:59PM +0200, Andrey Konovalov wrote:
> > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > pass tagged user pointers (with the top byte set to something else other
> > than 0x00) as syscall arguments.
> >
> > ib_uverbs_(re)reg_mr() use provided user pointers for vma lookups (through
> > e.g. mlx4_get_umem_mr()), which can only by done with untagged pointers.
> >
> > Untag user pointers in these functions.
> >
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >  drivers/infiniband/core/uverbs_cmd.c | 4 ++++
> >  1 file changed, 4 insertions(+)
>
> I think this is OK.. We should really get it tested though.. Leon?

It can be done after v5.2-rc1.

Thanks

>
> Jason

