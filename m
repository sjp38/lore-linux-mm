Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9D13C06511
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 16:06:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C1C421479
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 16:06:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sifive.com header.i=@sifive.com header.b="WIoPLVVT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C1C421479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sifive.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E5CD6B0003; Mon,  1 Jul 2019 12:06:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 096838E0003; Mon,  1 Jul 2019 12:06:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC87D8E0002; Mon,  1 Jul 2019 12:06:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f79.google.com (mail-io1-f79.google.com [209.85.166.79])
	by kanga.kvack.org (Postfix) with ESMTP id CE3256B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 12:06:47 -0400 (EDT)
Received: by mail-io1-f79.google.com with SMTP id v11so15572922iop.7
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 09:06:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=InMcyXa5sXJAd1Yjv5DDfuzVwc5hmtVlJVQ+GIywkco=;
        b=fmdtqr4bcyl8Kuna+ifpSiB1iN2Iwbaw3dwg35ve+OuLuYZADD/kOHdd/+BYVe30vc
         AxpocLoVvnZCPJR5UT6mTkpB6PZIrOOnibONGoJ2DkGPGvuV3l59E5N8+fDXRDXvAfGr
         0SwHS2ErS2uRNSWyvt1wkuOWc6Flzoeoi3paM8rUwviw9ptIZx3uOOHVKApQHGNZfvbS
         c9lexngTLaK7guRfpL5H5txCha8BA59jNPCxH2/r2m2KYX3imq72EAgCGrfrMFDo+hqO
         aJXQXfzxZBJUXpiOVuKxr2yc5nX0FShW5z1CVTZKlq78PsGd5KjMZ3/X6ThZYGCRdg2c
         LwPw==
X-Gm-Message-State: APjAAAX5r+vB6neoRGgXjoOVhN6AnMTRacDl0qXwvst1MYOKSMKoKPuj
	V2KtzUb7RcHAcpzkh3XKceJbml+pZQqcaK9twVz6Fmii3HvuifJj0vo38EjSTlBK/Zt5wc/INOx
	veHN44v+J24ob7oGTLpLdIgkEgM4m03rCustqDqnfcRqgQcIICeb7Y+/RKsQ+sk/5cw==
X-Received: by 2002:a5e:8210:: with SMTP id l16mr11122067iom.240.1561997207553;
        Mon, 01 Jul 2019 09:06:47 -0700 (PDT)
X-Received: by 2002:a5e:8210:: with SMTP id l16mr11121921iom.240.1561997206014;
        Mon, 01 Jul 2019 09:06:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561997206; cv=none;
        d=google.com; s=arc-20160816;
        b=ufiNrfqY48JJ3Waq7XaKArRTyAdLustQbJ7aNAabhmQuM25ssXGT3CgkKUOCGQj0Zl
         WbLoXw8R6GblgyL3eTkTv6XHKG8TDCf2QB8Vmdlh0rmL5uYnG/bClDpPFegDaFfvp1Rc
         T00I6AMh+zTqjEZBMAG1ZBswNKqA18BZkvnv9aIEu4/wDEVKYkHYtLVRmk1wAHS+sOQE
         SwiNXwb4pd20ORfuU+OzKBVRtLZdYfb8BCLgYfMSQ2qUmpI/DnjhDG8n9sJ0BpyJnaMx
         xqM8w0DXrzm/0gzP/aVypFJdbSjznT/84+s1G2ObiJNZkHwqR5SO3aUjQP+PbmsGltjc
         nyig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=InMcyXa5sXJAd1Yjv5DDfuzVwc5hmtVlJVQ+GIywkco=;
        b=thHXMAlkGGzEOnwj9dF9FfyOUQk36t6tjvjLUX06uO4RoWm2QyclZS7dE0yGhAKa5z
         xllkWSvCAz7zzKXyF51ecszGJ16dgQZjLHTliNXdbCgmUx4expvsUj2BwsDQ8rIv+cl2
         KCaltj0i0gYuspoqTiIZ0fXaynJrKG1pDSB0CHaCLh+ShJgWTP7/uM3uipamBn761m1F
         SQx+twLPgFt1L6oJnSlM5a5gSOFes/8VSkt8f9TwydXEUjritCcFR1ThxeL9CnlT6xlO
         SZ9gJHSE+VTcUGp4jd0eSQ7wK9ziYj2MMyoio/7/0qCjEYklTZ5fWVXl129hdKO7a0VJ
         QunQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sifive.com header.s=google header.b=WIoPLVVT;
       spf=pass (google.com: domain of paul.walmsley@sifive.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=paul.walmsley@sifive.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 131sor28177283jac.14.2019.07.01.09.06.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Jul 2019 09:06:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of paul.walmsley@sifive.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sifive.com header.s=google header.b=WIoPLVVT;
       spf=pass (google.com: domain of paul.walmsley@sifive.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=paul.walmsley@sifive.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=sifive.com; s=google;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=InMcyXa5sXJAd1Yjv5DDfuzVwc5hmtVlJVQ+GIywkco=;
        b=WIoPLVVTn8rSwrT7ABjLNYG0wnLKvjvHo/dgBVVxfPuv4EIDyAoUU4BrI/z8rbNtT0
         1O/xrCDhePoSl25Bh596TdgHrewYOtV0sM+w40g2+/HSGL1jnwyOhHBf53s+EhRXSntm
         zx45xkUd6WYP4VH+pHG9Dir4+Np7m0pZ3zkA7Ijt5/8LT4dQDBCaaU1oiEiE9sY1vJz6
         lyD/aMqrltDZztxu++zv6qBse7xclDClJznxjBs29GzmeDJ5rMwk9u/cFjASR0ERP4j2
         bC3Lo/DSmP2hKf+FFVwYjsGudzNzPlOcdHWOF9C6w6sx+n+S7AFqDv8dveTz78H8MmX1
         7Qow==
X-Google-Smtp-Source: APXvYqxL4h8vZQ2+vG0HtnQ8dyFs6puOwncIF/3RmDP3OfBIMby5YcRiUgft36tp862ZyI0igX9kng==
X-Received: by 2002:a02:a38d:: with SMTP id y13mr13211858jak.68.1561997205559;
        Mon, 01 Jul 2019 09:06:45 -0700 (PDT)
Received: from localhost (c-73-95-159-87.hsd1.co.comcast.net. [73.95.159.87])
        by smtp.gmail.com with ESMTPSA id o7sm10000521ioo.81.2019.07.01.09.06.44
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 01 Jul 2019 09:06:45 -0700 (PDT)
Date: Mon, 1 Jul 2019 09:06:44 -0700 (PDT)
From: Paul Walmsley <paul.walmsley@sifive.com>
X-X-Sender: paulw@viisi.sifive.com
To: Christoph Hellwig <hch@lst.de>
cc: Palmer Dabbelt <palmer@sifive.com>, linux-mm@kvack.org, 
    Damien Le Moal <damien.lemoal@wdc.com>, linux-riscv@lists.infradead.org, 
    linux-kernel@vger.kernel.org
Subject: Re: RISC-V nommu support v2
In-Reply-To: <20190701065654.GA21117@lst.de>
Message-ID: <alpine.DEB.2.21.9999.1907010904320.3867@viisi.sifive.com>
References: <20190624054311.30256-1-hch@lst.de> <20190701065654.GA21117@lst.de>
User-Agent: Alpine 2.21.9999 (DEB 301 2018-08-15)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

Probably best to feed the mm patches to Andrew.  For the RISC-V patches, 
am running a bit behind this merge window.  Combined with the end of the 
week holidays in the US, I doubt I'll make it to to the nommu series for 
v5.3.


- Paul

On Mon, 1 Jul 2019, Christoph Hellwig wrote:

> Palmer, Paul,
> 
> any comments?  Let me know if you think it is too late for 5.3
> for the full series, then I can at least feed the mm bits to
> Andrew.
> 
> On Mon, Jun 24, 2019 at 07:42:54AM +0200, Christoph Hellwig wrote:
> > Hi all,
> > 
> > below is a series to support nommu mode on RISC-V.  For now this series
> > just works under qemu with the qemu-virt platform, but Damien has also
> > been able to get kernel based on this tree with additional driver hacks
> > to work on the Kendryte KD210, but that will take a while to cleanup
> > an upstream.
> > 
> > To be useful this series also require the RISC-V binfmt_flat support,
> > which I've sent out separately.
> > 
> > A branch that includes this series and the binfmt_flat support is
> > available here:
> > 
> >     git://git.infradead.org/users/hch/riscv.git riscv-nommu.2
> > 
> > Gitweb:
> > 
> >     http://git.infradead.org/users/hch/riscv.git/shortlog/refs/heads/riscv-nommu.2
> > 
> > I've also pushed out a builtroot branch that can build a RISC-V nommu
> > root filesystem here:
> > 
> >    git://git.infradead.org/users/hch/buildroot.git riscv-nommu.2
> > 
> > Gitweb:
> > 
> >    http://git.infradead.org/users/hch/buildroot.git/shortlog/refs/heads/riscv-nommu.2
> > 
> > Changes since v1:
> >  - fixes so that a kernel with this series still work on builds with an
> >    IOMMU
> >  - small clint cleanups
> >  - the binfmt_flat base and buildroot now don't put arguments on the stack
> > 
> > _______________________________________________
> > linux-riscv mailing list
> > linux-riscv@lists.infradead.org
> > http://lists.infradead.org/mailman/listinfo/linux-riscv
> ---end quoted text---
> 


