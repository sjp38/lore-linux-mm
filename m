Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1198EC43219
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 16:28:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABCCC20651
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 16:28:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABCCC20651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28D276B0005; Fri,  3 May 2019 12:28:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23D586B0006; Fri,  3 May 2019 12:28:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 153DE6B0007; Fri,  3 May 2019 12:28:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id BF29E6B0005
	for <linux-mm@kvack.org>; Fri,  3 May 2019 12:28:56 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n23so4271179edv.9
        for <linux-mm@kvack.org>; Fri, 03 May 2019 09:28:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Q7hZet5D3Y1KVXgtMlzA/VSVTbOwwYSjk7AC+3BuoLM=;
        b=RKasNEcUjrqzrmCWOvNVNcPooYSlj0pVpsXkh/swE0NkQJy18QqFXO+O2Vf3Qzx8SK
         shl/23BBuBXsZTPrE3OGZ/uA/159TP42oTl2Vls7mgco2vMQmnV+nH/vxIJ039rD8AfP
         rRZj+U3lEn1hN51FO5kCpVXL0VHmY4kkhuUPTfKSi8s/guPygUMLRtjS0lIOKMWdNEFf
         YrNMwBypeGITQc9ewy82SHCmrVE4EJY55G3uIAZsceWzvSjZLNvONE/KoXuJn50KeGpE
         eYVdzKugp5UV7kcHpQArSbu1MajGqW7SKC02enBisLVaYf5Opw4PbUNSrGssfIESyh0p
         iCxw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXlBdJBG/tHAFsLBc+a6lSkj7Pc/D9viGFFF92Et3ohKIvcUdZ4
	K5QpnknvUV6fXIoxyldTy8P/q61ZOy3EqSedVH/EjBhYYYhVrN3vrMpPZzFoaLSkbmGKxF2rljp
	jHxc/zqi0T1MH08dEU1lEvQhlPm+lgQ0Pyp8iOraKEXMOfWbqsbrEqPHzmY6oySwJZQ==
X-Received: by 2002:a17:906:a458:: with SMTP id cb24mr5102182ejb.158.1556900936293;
        Fri, 03 May 2019 09:28:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxr1ugFmy0AMycTkcyQCojlzNsTeh8M0F4w8uCq3sKKi//fPpcEQatLwBJpic8VB6+X1CFP
X-Received: by 2002:a17:906:a458:: with SMTP id cb24mr5102110ejb.158.1556900935166;
        Fri, 03 May 2019 09:28:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556900935; cv=none;
        d=google.com; s=arc-20160816;
        b=yFaralIrqZA1SoDBI6HnkeDVU70GnFUI72tv4OMFj3QoGVAKnOmLAAUlSA4v4lBJDu
         fhTmNmzWaowCCkSOe6UWP1Mw6gcwvZpdSgvgItCwlyRGwRlWTtUccMlhga7OsU23kyPm
         65bdUZCSgIDx9JTFV1xGzk5YyTfnGG5esfh+LX/SPkDI/JxZVDpnBGpqHXB5K+Obx8IT
         /sx6dJCkePhaD4gne5bRBMhZw793p33QFObYDC7ki0+LROROSJ358hCVQ92G4Ik4bEP6
         jZq1EhY+XJiDs1Cn4VWp5D/IQz51wou25sS/FVEYHYgZRg2D0bNQk7xuN2kMYQPZzIDs
         AGQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Q7hZet5D3Y1KVXgtMlzA/VSVTbOwwYSjk7AC+3BuoLM=;
        b=K0RQJhF1lpXxmK7WcBI31CaoaZqTAxoUroMw3iloKLnOUJHk3pmS9tozzjPJzGiP2J
         +YdNFg2sqnnCKbwChAfqSdkFkzV+Kjh2/oVY7A8jMX6yW+8m5iV2ML7ABRXYTshjo6Qy
         vwwSOuaadT0MMojtvh2NNXL73jvQLqlb9MimSg9Mg8HwEOWRwS4jNO77KsNVoqVr8v5k
         fjSamUzIAsxI3mUgl4JX6N38tPU6ItbC/1nHnB0PEvPumgGuA8d5e05cSxgyv6TnSEb1
         yeuwJxu1FvvA0ux+v/SxECIzuHvhrlPeehayEAEcGFtPT+jG/M5U/CSqao3np+0whk3t
         5fDA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p18si1565439eju.338.2019.05.03.09.28.54
        for <linux-mm@kvack.org>;
        Fri, 03 May 2019 09:28:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 17C7FA78;
	Fri,  3 May 2019 09:28:54 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 9E4AE3F557;
	Fri,  3 May 2019 09:28:49 -0700 (PDT)
Date: Fri, 3 May 2019 17:28:46 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Leon Romanovsky <leon@kernel.org>,
	Andrey Konovalov <andreyknvl@google.com>,
	Will Deacon <will.deacon@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Yishai Hadas <yishaih@mellanox.com>,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v13 16/20] IB/mlx4, arm64: untag user pointers in
 mlx4_get_umem_mr
Message-ID: <20190503162846.GI55449@arrakis.emea.arm.com>
References: <cover.1553093420.git.andreyknvl@google.com>
 <1e2824fd77e8eeb351c6c6246f384d0d89fd2d58.1553093421.git.andreyknvl@google.com>
 <20190429180915.GZ6705@mtr-leonro.mtl.com>
 <20190430111625.GD29799@arrakis.emea.arm.com>
 <20190502184442.GA31165@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190502184442.GA31165@ziepe.ca>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks Jason and Leon for the information.

On Thu, May 02, 2019 at 03:44:42PM -0300, Jason Gunthorpe wrote:
> On Tue, Apr 30, 2019 at 12:16:25PM +0100, Catalin Marinas wrote:
> > > Interesting, the followup question is why mlx4 is only one driver in IB which
> > > needs such code in umem_mr. I'll take a look on it.
> > 
> > I don't know. Just using the light heuristics of find_vma() shows some
> > other places. For example, ib_umem_odp_get() gets the umem->address via
> > ib_umem_start(). This was previously set in ib_umem_get() as called from
> > mlx4_get_umem_mr(). Should the above patch have just untagged "start" on
> > entry?
> 
> I have a feeling that there needs to be something for this in the odp
> code..
> 
> Presumably mmu notifiers and what not also use untagged pointers? Most
> likely then the umem should also be storing untagged pointers.

Yes.

> This probably becomes problematic because we do want the tag in cases
> talking about the base VA of the MR..

It depends on whether the tag is relevant to the kernel or not. The only
useful case so far is for the kernel performing copy_form_user() etc.
accesses so they'd get checked in the presence of hardware memory
tagging (MTE; but it's not mandatory, a 0 tag would do as well).

If we talk about a memory range where the content is relatively opaque
(or irrelevant) to the kernel code, we don't really need the tag. I'm
not familiar to RDMA but I presume it would be a device accessing such
MR but not through the user VA directly. The tag is a property of the
buffer address/pointer when accessed by the CPU at that specific address
range. Any DMA or even kernel accessing it through the linear mapping
(get_user_pages()) would drop such tag.

-- 
Catalin

