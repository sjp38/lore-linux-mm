Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9286AC32754
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 21:12:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 453822173E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 21:12:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="ACf43qcD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 453822173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D56DC6B0003; Thu,  8 Aug 2019 17:12:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D05FC6B0006; Thu,  8 Aug 2019 17:12:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA77E6B0007; Thu,  8 Aug 2019 17:12:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7FD7D6B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 17:12:23 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 6so59917205pfi.6
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 14:12:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=ylddyGuuUpJhKUvK1ev1Q44hiLLmL8PwyC4MRMb3mUE=;
        b=G6kuPs8NsAI0oecgR+hmdHiIyT771fkBxmmJRaqOiJRb+stDxrpIajksELm4e/eumu
         E6GS7HTvUEFjhFDSPKYSsyLPGdk5mJTVhSPyKLsjVh3juIkG+gYjLQZGfCaRRPmgKNaf
         KxPWjz8bhqp9ZcYjwQX4epKXUjiVPY7EzZGPJ57T94i8AGVXQksGG4+ih1cqpl0fK72l
         65uYMCnTM9HrlPOYRjawDK91EPMqu27Q9HiyF4Xny5xcQbDDTNZGfa1uPQ7Cv6UlQi8e
         nYN7jl5oXzA3rQ8dPjs3QYYAh7ByGcQ/JFvVQyGREb5/Ja/ZflQHO3nVi7xWiqKThLMq
         jfNg==
X-Gm-Message-State: APjAAAUdfxNUjXROMujXNdmuvQbXVUNkqvTrCkJuE+zwrWsAUsyTlIOo
	+y92FYhaVrga7fZdunnONhoKFkKoMG2dGvu8ldBLyJMkYZF6+0yTbpYXHLyQWzU7N7Sgfl6TO2T
	DLt3cEv1XXr+mVcpXNpz9F9Nj2hmlP06QhNLsG+1/1c/i0oV1YkG2oj0qdViFhe8SGg==
X-Received: by 2002:a63:67c6:: with SMTP id b189mr12898277pgc.163.1565298743044;
        Thu, 08 Aug 2019 14:12:23 -0700 (PDT)
X-Received: by 2002:a63:67c6:: with SMTP id b189mr12898206pgc.163.1565298742038;
        Thu, 08 Aug 2019 14:12:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565298742; cv=none;
        d=google.com; s=arc-20160816;
        b=BamV7JSKTXkUGRoBLfngVTE9k+aVwfGuxUKfSJ5OQlV4pBHbi7pVxKyUt6qFHpA1Km
         CPJB7vvd5mJcRSQ2I2ssf0/2X+AcnZnHEB56SXCaQ1VOby30/Q4FOSuNyt170SZqcRK+
         NpJw+nn45FDRgUKnQP8PLNi00juNeV4wFVvFAuCI4u7TMeGR2wHPtcpVC7lLUIh4qRuP
         v5a9IPU8dmo7AEO4m1wu9B1w/WpluVdWe+4vsVfop4q7n10EiGWNeWJDUyvP4BJVycc5
         4UkDXBEAhFQOtnl6ytdvuu08bpcks3cp5bavaxbh2ygaGFaHvt8f7WFv8m0nkw37qOiA
         VIrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=ylddyGuuUpJhKUvK1ev1Q44hiLLmL8PwyC4MRMb3mUE=;
        b=MhmofXz4NqxgmEI96OFVuGbNNnoI5MXHczD0sqyATOgrFj6pf+jv97MvOY4fW2PgLN
         1PFoGt6YyXNwR0irB8yo/pFwWElU/p2G/rQDi6nA2bz3oDwYfEzrdw+tSKNhO4N+Sx5G
         b+jNfrxZ2a1a0xzXS1WtAxnO5iGIyY8CaNWdD0sORkGVbOcnajPx1NEKwThmSbogSgu1
         PIv6M5BWymdHGQTwj03SuX6k3Znh3JA0Ehe0WN6JUPOpJXg7h4nwcIlf3aP5xqkcsJGc
         dMu9ttz01+pm0TmCGjiX0k/YEoYtiljCkcdjbk9PvxuhmBsPyjvaFJIpJlJ1EiEfDx9r
         0Icg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=ACf43qcD;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j21sor76580176pfr.2.2019.08.08.14.12.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Aug 2019 14:12:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=ACf43qcD;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=ylddyGuuUpJhKUvK1ev1Q44hiLLmL8PwyC4MRMb3mUE=;
        b=ACf43qcDjfXfx13Z+1Gsw1UZV/Uosrf1yEiF0Agjii4NCq0aSJm4NT0QzSwLCl7Dc5
         gq+wLSnVQcR3qxZ0fm9hvoSL16jb4cCF5OkMFfCEBQn0MQdPfLlk2tDzdSCLPp3vIQBd
         UxRwIr8unIchMakLD/5qyLX3unblGeVjDLQfg=
X-Google-Smtp-Source: APXvYqy0pdWoHPkerneL5407ilt1ySmaIIJNjNXYxB0G6sGkOR++FLPJzal2z8CcZbjPxvclbtt+OA==
X-Received: by 2002:a62:1750:: with SMTP id 77mr17827956pfx.172.1565298741745;
        Thu, 08 Aug 2019 14:12:21 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id q19sm101457867pfc.62.2019.08.08.14.12.20
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 08 Aug 2019 14:12:20 -0700 (PDT)
Date: Thu, 8 Aug 2019 14:12:19 -0700
From: Kees Cook <keescook@chromium.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Will Deacon <will@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Will Deacon <will.deacon@arm.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	dri-devel@lists.freedesktop.org, Kostya Serebryany <kcc@google.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org,
	amd-gfx@lists.freedesktop.org,
	Christoph Hellwig <hch@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Dave Martin <Dave.Martin@arm.com>,
	Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Lee Smith <Lee.Smith@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>, enh <enh@google.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v19 00/15] arm64: untag user pointers passed to the kernel
Message-ID: <201908081410.C16D2BD@keescook>
References: <cover.1563904656.git.andreyknvl@google.com>
 <CAAeHK+yc0D_nd7nTRsY4=qcSx+eQR0VLut3uXMf4NEiE-VpeCw@mail.gmail.com>
 <20190724140212.qzvbcx5j2gi5lcoj@willie-the-truck>
 <CAAeHK+xXzdQHpVXL7f1T2Ef2P7GwFmDMSaBH4VG8fT3=c_OnjQ@mail.gmail.com>
 <20190724142059.GC21234@fuggles.cambridge.arm.com>
 <20190806171335.4dzjex5asoertaob@willie-the-truck>
 <CAAeHK+zF01mxU+PkEYLkoVu-ZZM6jNfL_OwMJKRwLr-sdU4Myg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+zF01mxU+PkEYLkoVu-ZZM6jNfL_OwMJKRwLr-sdU4Myg@mail.gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 07, 2019 at 07:17:35PM +0200, Andrey Konovalov wrote:
> On Tue, Aug 6, 2019 at 7:13 PM Will Deacon <will@kernel.org> wrote:
> >
> > On Wed, Jul 24, 2019 at 03:20:59PM +0100, Will Deacon wrote:
> > > On Wed, Jul 24, 2019 at 04:16:49PM +0200, Andrey Konovalov wrote:
> > > > On Wed, Jul 24, 2019 at 4:02 PM Will Deacon <will@kernel.org> wrote:
> > > > > On Tue, Jul 23, 2019 at 08:03:29PM +0200, Andrey Konovalov wrote:
> > > > > > Should this go through the mm or the arm tree?
> > > > >
> > > > > I would certainly prefer to take at least the arm64 bits via the arm64 tree
> > > > > (i.e. patches 1, 2 and 15). We also need a Documentation patch describing
> > > > > the new ABI.
> > > >
> > > > Sounds good! Should I post those patches together with the
> > > > Documentation patches from Vincenzo as a separate patchset?
> > >
> > > Yes, please (although as you say below, we need a new version of those
> > > patches from Vincenzo to address the feedback on v5). The other thing I
> > > should say is that I'd be happy to queue the other patches in the series
> > > too, but some of them are missing acks from the relevant maintainers (e.g.
> > > the mm/ and fs/ changes).
> >
> > Ok, I've queued patches 1, 2, and 15 on a stable branch here:
> >
> >   https://git.kernel.org/pub/scm/linux/kernel/git/arm64/linux.git/log/?h=for-next/tbi
> >
> > which should find its way into -next shortly via our for-next/core branch.
> > If you want to make changes, please send additional patches on top.
> >
> > This is targetting 5.4, but I will drop it before the merge window if
> > we don't have both of the following in place:
> >
> >   * Updated ABI documentation with Acks from Catalin and Kevin
> 
> Catalin has posted a new version today.
> 
> >   * The other patches in the series either Acked (so I can pick them up)
> >     or queued via some other tree(s) for 5.4.
> 
> So we have the following patches in this series:
> 
> 1. arm64: untag user pointers in access_ok and __uaccess_mask_ptr
> 2. arm64: Introduce prctl() options to control the tagged user addresses ABI
> 3. lib: untag user pointers in strn*_user
> 4. mm: untag user pointers passed to memory syscalls
> 5. mm: untag user pointers in mm/gup.c
> 6. mm: untag user pointers in get_vaddr_frames
> 7. fs/namespace: untag user pointers in copy_mount_options
> 8. userfaultfd: untag user pointers
> 9. drm/amdgpu: untag user pointers
> 10. drm/radeon: untag user pointers in radeon_gem_userptr_ioctl
> 11. IB/mlx4: untag user pointers in mlx4_get_umem_mr
> 12. media/v4l2-core: untag user pointers in videobuf_dma_contig_user_get
> 13. tee/shm: untag user pointers in tee_shm_register
> 14. vfio/type1: untag user pointers in vaddr_get_pfn
> 15. selftests, arm64: add a selftest for passing tagged pointers to kernel
> 
> 1, 2 and 15 have been picked by Will.
> 
> 11 has been picked up by Jason.
> 
> 9, 10, 12, 13 and 14 have acks from their subsystem maintainers.
> 
> 3 touches generic lib code, I'm not sure if there's a dedicated
> maintainer for that.

Andrew tends to pick up lib/ patches.

> The ones that are left are the mm ones: 4, 5, 6, 7 and 8.
> 
> Andrew, could you take a look and give your Acked-by or pick them up directly?

Given the subsystem Acks, it seems like 3-10 and 12 could all just go
via Andrew? I hope he agrees. :)

-- 
Kees Cook

