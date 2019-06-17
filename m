Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 715ECC46477
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 17:59:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 352AB208CB
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 17:59:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 352AB208CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA31D8E0004; Mon, 17 Jun 2019 13:59:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C799C8E0001; Mon, 17 Jun 2019 13:59:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8F548E0004; Mon, 17 Jun 2019 13:59:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6E4968E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 13:59:04 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so17411829eds.14
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 10:59:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=t4Zg6P/3rcvHF/Kkh6J9Veq1cGhqPvvomS5CoeMxCEs=;
        b=LNldXPvaJMAFbGKxRjS+aE0W8AfmFUA14Gcqkt3VHmuLSE6zmWRe5GXy6OQKxc5zpF
         dbNJD4STeqzQ7XjnKjCerYvBZ0BQU6464Ov9nuorN3T/jUcZf6THyhawGP3+NArO08XS
         UiT7sJmxL/nshJXrDpPVG7WlKhFXZj1mDUZ3eu5TOhNWLgpDS0ixTp1TGxBPvbDrBZFQ
         1V+4gutIZOM8Im/7eREn9l0gf2gl8Uf3JJbIcAziZPeF2Nke/kbcl6jo6QftrnefT/tO
         6Ucpt8DpnBZ6YfhJ9Z4oaMlobCHPFH67ULNIy1Ohc/cakP/4JiSBGNq8bL8jRcKsHLWV
         afAg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXAE4m1JiaAIirDtXuc1GDGSyC8Dae30PB6xJLGJx2Bk8ZIltSB
	XWVYY/6VxVRZrh4W4G+8hO+HAyQvD0/s7W1XpfNCeOGPkkEjlsSoELZtx8fpLgRX9RldFw/R97M
	gbR4Ex4rHouGM5Pwl1WMpB2g2s0/LEf8cds+YeorsquwN15fcnjo6fkPoJkfkdg52uw==
X-Received: by 2002:aa7:c98c:: with SMTP id c12mr56271351edt.225.1560794343875;
        Mon, 17 Jun 2019 10:59:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyFHITLLhjz/+tAtEYtIQ4OrHF3kjuVo18TjF15HaTSernzTvhGdAseHY+SB6px8f0DQNk7
X-Received: by 2002:aa7:c98c:: with SMTP id c12mr56094644edt.225.1560791902214;
        Mon, 17 Jun 2019 10:18:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560791901; cv=none;
        d=google.com; s=arc-20160816;
        b=nTF5/Sl9gsNaFD2luqD1b2vlj/3sZ/AjGh5w6cMmeZ+U2/wAn+m7x0jITrmb96hWNc
         rx2He7JVfJhO942jaFBuNr9gje0ZiNl/Eez6PC0uA5wZCePvrmipIn9Okcj/qf6QtZRY
         a9YKhIpdbUH2v+9my9FdzSYectvuDy4/50PcJuY4w8HJf7rPqfMPeN8+GuUY80dGNHTf
         CuCIDVi85al7L0zORX19Pe1LG/f6AyCrRi4WEHFXG+IavIqydHwKrcWWVq8CanrLVIQi
         kK+ebGUBNkCKiXtMSBM9zeRRvxUsoVvEA8dsKCC5oBAJMrQipImlx+SMdMSNXZMOclfv
         GF/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=t4Zg6P/3rcvHF/Kkh6J9Veq1cGhqPvvomS5CoeMxCEs=;
        b=a8J/3qxaUOmjZsScUshUn/1BcltRmaZ1nbgiVxS5AXQy0VAItLbBgXoJKYwFseqbDm
         vFy4RkiKEXKa4hpfOuLjKO9/m1pWuAwrrgRKA+pINjYdU9nv0HS8OFf9AUtkZRrNcfgA
         LFhONu55DMTe3JUP//rCckA8f4C8+LZFoKHCcWiYcYG56QPXlWCv6aESx+sIHGq/kzWK
         Is0bOWQpdHF9f3Iyd5FpBD2tmiFBKp1vAgRLawHJ5cLELmv+6Z+HoVf+KlxvyjDBZpcW
         jhw/Y5q1nrpkMaoVpLj81ccvcE2QRPCcaECGNtnKTfx0FqW++mI6GAKJbDaN9jVVV6if
         AmMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id b32si8459673eda.254.2019.06.17.10.18.21
        for <linux-mm@kvack.org>;
        Mon, 17 Jun 2019 10:18:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A9B7128;
	Mon, 17 Jun 2019 10:18:20 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 08B543F246;
	Mon, 17 Jun 2019 10:18:15 -0700 (PDT)
Date: Mon, 17 Jun 2019 18:18:13 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Evgenii Stepanov <eugenis@google.com>
Cc: Andrey Konovalov <andreyknvl@google.com>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
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
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v17 03/15] arm64: Introduce prctl() options to control
 the tagged user addresses ABI
Message-ID: <20190617171813.GC34565@arrakis.emea.arm.com>
References: <cover.1560339705.git.andreyknvl@google.com>
 <a7a2933bea5fe57e504891b7eec7e9432e5e1c1a.1560339705.git.andreyknvl@google.com>
 <20190617135636.GC1367@arrakis.emea.arm.com>
 <CAFKCwrjJ+0ijNKa3ioOP7xa91QmZU0NhkO=tNC-Q_ThC69vTug@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFKCwrjJ+0ijNKa3ioOP7xa91QmZU0NhkO=tNC-Q_ThC69vTug@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 09:57:36AM -0700, Evgenii Stepanov wrote:
> On Mon, Jun 17, 2019 at 6:56 AM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > On Wed, Jun 12, 2019 at 01:43:20PM +0200, Andrey Konovalov wrote:
> > > From: Catalin Marinas <catalin.marinas@arm.com>
> > >
> > > It is not desirable to relax the ABI to allow tagged user addresses into
> > > the kernel indiscriminately. This patch introduces a prctl() interface
> > > for enabling or disabling the tagged ABI with a global sysctl control
> > > for preventing applications from enabling the relaxed ABI (meant for
> > > testing user-space prctl() return error checking without reconfiguring
> > > the kernel). The ABI properties are inherited by threads of the same
> > > application and fork()'ed children but cleared on execve().
> > >
> > > The PR_SET_TAGGED_ADDR_CTRL will be expanded in the future to handle
> > > MTE-specific settings like imprecise vs precise exceptions.
> > >
> > > Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> >
> > A question for the user-space folk: if an application opts in to this
> > ABI, would you want the sigcontext.fault_address and/or siginfo.si_addr
> > to contain the tag? We currently clear it early in the arm64 entry.S but
> > we could find a way to pass it down if needed.
> 
> For HWASan this would not be useful because we instrument memory
> accesses with explicit checks anyway. For MTE, on the other hand, it
> would be very convenient to know the fault address tag without
> disassembling the code.

I could as this differently: does anything break if, once the user
opts in to TBI, fault_address and/or si_addr have non-zero top byte?

Alternatively, we could present the original FAR_EL1 register as a
separate field as we do with ESR_EL1, independently of whether the user
opted in to TBI or not.

-- 
Catalin

