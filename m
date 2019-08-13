Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF0E0C41514
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 16:48:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 829062085A
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 16:48:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sifive.com header.i=@sifive.com header.b="PVaDn1Ye"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 829062085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sifive.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0575E6B0005; Tue, 13 Aug 2019 12:48:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F22126B0006; Tue, 13 Aug 2019 12:48:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC3866B0007; Tue, 13 Aug 2019 12:48:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0040.hostedemail.com [216.40.44.40])
	by kanga.kvack.org (Postfix) with ESMTP id B58956B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 12:48:46 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 72DB1180AD7C3
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 16:48:46 +0000 (UTC)
X-FDA: 75817988652.16.humor61_86c013e4cb908
X-HE-Tag: humor61_86c013e4cb908
X-Filterd-Recvd-Size: 4924
Received: from mail-ot1-f67.google.com (mail-ot1-f67.google.com [209.85.210.67])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 16:48:45 +0000 (UTC)
Received: by mail-ot1-f67.google.com with SMTP id f17so39696206otq.4
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:48:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=sifive.com; s=google;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=wWYXt7jx7G31cd0rE9luks4j70Eji+/vHa4Z1GbiX1s=;
        b=PVaDn1YePRT9j9KWakxbJ5aZbPHOe1J33ryNWuvT223ufkBNGNMfeasLJ4OrxmwPQZ
         zC9YYVf5EuudnD8g2gF+COcciyXunWMzIWBn3kPO03qtPucFcPSAcXnoBJ6kR8EpWhD1
         n2kN9d52DP0eEmM3jbQMP5LVdVgEvBpuKKVeVwA4eSx6BVuM8ibVKAoD7BR6I9ULnXs5
         FAoNg0DL0iJBEqca3QwrsWRVpN2G6Rn3ar6llSZc784HZGsYUJgp2ajlMF+fYDPicuzH
         95qrxSmcS0SEyuOAfEnmAETTEAs+VX2awtZGt/ux0Jucg+YEytTtvv1a97y1iTAEt4ja
         F88g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:in-reply-to:message-id
         :references:user-agent:mime-version;
        bh=wWYXt7jx7G31cd0rE9luks4j70Eji+/vHa4Z1GbiX1s=;
        b=M0KeQd5uiHoReGPh22iCl6W/suJnlyjMHZOET08vH/ruYSBwET9Dc5CQlSs7+9J6wM
         4oL5xAy/LiggFnB3iFD9X0oHwqKNwlMuB3x75uVklkTk17Dz6QDC0LDeUVXg7T1K4QE4
         En5SafrV5pn6Vh/M191lwNeYgo2X6Hq92Vi0UMb11f3OLL6LO0dZcBBVfUV4ygvlVMcK
         2tHsFgDX1pEJa25FANkze/kv4kDo0uoMHS8+pac6jVz/MQhjxNWXGfQT2t02qvv20nsG
         6SAXvu+O9IklBtMd76o3L/Fs55X+VFqs307MJQ033oEloI0FfYOu8fS/zDjmFpJoPw8A
         pY0A==
X-Gm-Message-State: APjAAAVTUP5yUE+QsDy58l1yAV0jDACnHOzq+g2iqIrOSdy06ZolTo+/
	jNMNCuDyozfxn5LlNBbzMFbk4Q==
X-Google-Smtp-Source: APXvYqxPVuDBsGAd9o9o1k5X+B5nMlPiCHWLeDxvNl/FUOtJzCoioboXTdGD/sGypvrgZDoyB/qP5A==
X-Received: by 2002:a5d:8497:: with SMTP id t23mr39094733iom.298.1565714925017;
        Tue, 13 Aug 2019 09:48:45 -0700 (PDT)
Received: from localhost (c-73-95-159-87.hsd1.co.comcast.net. [73.95.159.87])
        by smtp.gmail.com with ESMTPSA id t19sm91323213iog.41.2019.08.13.09.48.44
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 13 Aug 2019 09:48:44 -0700 (PDT)
Date: Tue, 13 Aug 2019 09:48:43 -0700 (PDT)
From: Paul Walmsley <paul.walmsley@sifive.com>
X-X-Sender: paulw@viisi.sifive.com
To: Logan Gunthorpe <logang@deltatee.com>
cc: Greentime Hu <green.hu@gmail.com>, Rob Herring <robh@kernel.org>, 
    Albert Ou <aou@eecs.berkeley.edu>, Andrew Waterman <andrew@sifive.com>, 
    Palmer Dabbelt <palmer@sifive.com>, 
    Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
    Stephen Bates <sbates@raithlin.com>, Olof Johansson <olof@lixom.net>, 
    greentime.hu@sifive.com, linux-riscv@lists.infradead.org, 
    Michael Clark <michaeljclark@mac.com>, Christoph Hellwig <hch@lst.de>, 
    linux-mm@kvack.org
Subject: Re: [PATCH v4 2/2] RISC-V: Implement sparsemem
In-Reply-To: <alpine.DEB.2.21.9999.1908130921170.30024@viisi.sifive.com>
Message-ID: <alpine.DEB.2.21.9999.1908130947130.30024@viisi.sifive.com>
References: <20190109203911.7887-1-logang@deltatee.com> <20190109203911.7887-3-logang@deltatee.com> <CAEbi=3d0RNVKbDUwRL-o70O12XBV7q6n_UT-pLqFoh9omYJZKQ@mail.gmail.com> <c4298fdd-6fd6-fa7f-73f7-5ff016788e49@deltatee.com> <CAEbi=3cn4+7zk2DU1iRa45CDwTsJYfkAV8jXHf-S7Jz63eYy-A@mail.gmail.com>
 <CAEbi=3eZcgWevpX9VO9ohgxVDFVprk_t52Xbs3-TdtZ+js3NVA@mail.gmail.com> <0926a261-520e-4c40-f926-ddd40bb8ce44@deltatee.com> <CAEbi=3ebNM-t_vA4OA7KCvQUF08o6VmL1j=kMojVnYsYsN_fBw@mail.gmail.com> <e2603558-7b2c-2e5f-e28c-f01782dc4e66@deltatee.com>
 <CAEbi=3d7_xefYaVXEnMJW49Bzdbbmc2+UOwXWrCiBo7YkTAihg@mail.gmail.com> <96156909-1453-d487-ff66-a041d67c74d6@deltatee.com> <CAEbi=3dC86dhGdwdarS_x+6-5=WPydUBKjo613qRZxKLDAqU_g@mail.gmail.com> <5506c875-9387-acc9-a7fe-5b7c10036c40@deltatee.com>
 <alpine.DEB.2.21.9999.1908130921170.30024@viisi.sifive.com>
User-Agent: Alpine 2.21.9999 (DEB 301 2018-08-15)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Aug 2019, Paul Walmsley wrote:

> On Tue, 13 Aug 2019, Logan Gunthorpe wrote:
> 
> > On 2019-08-13 12:04 a.m., Greentime Hu wrote:
> > 
> > > Every architecture with mmu defines their own pfn_valid().
> > 
> > Not true. Arm64, for example just uses the generic implementation in
> > mmzone.h. 
> 
> arm64 seems to define their own:
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/arm64/Kconfig#n899
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/arm64/mm/init.c#n235
> 
> While there are many architectures which have their own pfn_valid(); 
> oddly, almost none of them set HAVE_ARCH_PFN_VALID ?

(fixed the linux-mm@ address)


- Paul

