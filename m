Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9449C43387
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 15:18:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95D2520657
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 15:18:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="pGpZhbYx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95D2520657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25E2C8E0004; Wed, 16 Jan 2019 10:18:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20C238E0002; Wed, 16 Jan 2019 10:18:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0AF998E0004; Wed, 16 Jan 2019 10:18:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id BA5CE8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 10:18:38 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 68so4881376pfr.6
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 07:18:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=rqBr1ZOdeWPp7+fYxcWyxlFNS/RxUrI2luwWGSK1Z5Q=;
        b=GZHbRPyKHza0hGDvn4/fToKkuiV2vQxePp2np864vvmlUf8iA4+NBo0RhTUEbh+Ciw
         23Nq46GwV0zdE+mmN8iwbgF8RJ90utmv0AiW3YgTU2T6XzvgDC/C5Eb79xieeuaNsld5
         jtwyE0rRbeFm/ti2VKPAHlvx/t98fuBy/4Ngo7GHiP70skSzeX5viQOOKXDQ/5+/FRw9
         bIyq+MQaw9QPKiKmiu94ByXcaoZpz0RPMekFDuUb8/URF2hEojf+rEkgQ+1jMVTj3pf2
         kzpJSLr607T9o6fxawUh+gO41c2p7FOcWorMgUUkMDnNW4bxonQXcDZB2aeQEtiV+pBK
         v7pA==
X-Gm-Message-State: AJcUukf/Rjn0HTnfr8qgDqanfh3dbA/QEUyhU79LmwsKAt4PteyV3Xma
	8qH7mrAQrZXfDNohrIsJPowqgfQsWE032kMv5k4zaDNn3h3JqBPdCo6j1ZzjMWbkoTg0e7fXjMz
	A7gRoziy4wEMhMiNn/K1HwK6QxXBVUpgZxEnoI6F4GO3PT5jHISGReeLpqensjmkuuQ==
X-Received: by 2002:a17:902:3f81:: with SMTP id a1mr10313422pld.258.1547651918425;
        Wed, 16 Jan 2019 07:18:38 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5+/R+PuhGQuvxmsdXQapsylVUIiq6y5fGHdSt6l73lYBeBlms6i/i5wINQLbR74dt0a9dR
X-Received: by 2002:a17:902:3f81:: with SMTP id a1mr10313347pld.258.1547651917520;
        Wed, 16 Jan 2019 07:18:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547651917; cv=none;
        d=google.com; s=arc-20160816;
        b=q0LiZed3QcElI6+mSz6UusmCa351Zqj+VN0naoBpzaPbKyYqzku1FbLr5k5ITkS5mg
         /UsAKYm89NoUHV8Ts+svZL74NRCQOq5dSHgtfcEQ0f5Sd74GfUj2GFB4qb2jea9jB5Wb
         0s9xdLLYEKT/KzkfTYcsqWiOJhb42da+SyRCrpdonUQrjXjr37mIkuOW4fhzn74v9OWT
         GGRZFkA8KE2p7OxUw08VGhtvAg733GGsxdhEPnxnypa6v6cMdR7j0a3GzwFwFMYdFCNa
         SLwYmeYdXtpBc1J9//VoeRSUmaXuJMkIFQh2R39/Glg8dTRj4+iVegn5fTs5FRs/D1j8
         8zsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=rqBr1ZOdeWPp7+fYxcWyxlFNS/RxUrI2luwWGSK1Z5Q=;
        b=pDeF3nMlD6sRcKATif45rryv4OGyLDSFb6AbNxmbBTi92HDzmG1i/kKFfljYRbB6mB
         +91dR/wbPbTxk+NEN30kN6hJga7jcvbL5HwjM5u4ssTgW5zjHXi4Hh5Yf5UmGWalEW56
         1E7WW+9CJn84uufTJ8wc6U7axdM8x8jS5ge9BEpT8xfK4y81OyQ42tMebOWOLYs0QbNY
         tKZlG6BTriq4UtnJ+SOxArlxohQiGCeVBGU0rVqHrJKd/LDeFDnMXuC1cOkm84CWmIl2
         QvybaIIiT20I7bY/wSLIVEyNI5enIQvFEeGAE27w1eXMwOWvTuui0o8heCMXmKJV0LN6
         CaEA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=pGpZhbYx;
       spf=pass (google.com: domain of robh+dt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=robh+dt@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g12si6575142pll.428.2019.01.16.07.18.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 07:18:37 -0800 (PST)
Received-SPF: pass (google.com: domain of robh+dt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=pGpZhbYx;
       spf=pass (google.com: domain of robh+dt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=robh+dt@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-qt1-f177.google.com (mail-qt1-f177.google.com [209.85.160.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0D33C20873
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 15:18:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1547651917;
	bh=b4Eql+8wNKqBmh8BvWalk13WRrshCh12iUx8UsuWK8E=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=pGpZhbYxHtMwTO9dI0h366yRg+LAD2wNIytXd9Or8lLZMueCmrAGXVKvlpAwTQgbw
	 rXua/KxbeyHuTIJrfkJKBBEpsBy5u3yOgSKWwnfRKE2es62irDaRyHZuhGk3sTbP0m
	 Xyxm48InvedRZ4XFYn+dmOso3aoQp59Wh0ocuj4E=
Received: by mail-qt1-f177.google.com with SMTP id n32so7460407qte.11
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 07:18:37 -0800 (PST)
X-Received: by 2002:aed:3ecf:: with SMTP id o15mr7523514qtf.26.1547651916185;
 Wed, 16 Jan 2019 07:18:36 -0800 (PST)
MIME-Version: 1.0
References: <1547646261-32535-1-git-send-email-rppt@linux.ibm.com> <1547646261-32535-20-git-send-email-rppt@linux.ibm.com>
In-Reply-To: <1547646261-32535-20-git-send-email-rppt@linux.ibm.com>
From: Rob Herring <robh+dt@kernel.org>
Date: Wed, 16 Jan 2019 09:18:24 -0600
X-Gmail-Original-Message-ID: <CAL_JsqJv=+SQwmbwuw1C5Rv9sFHhk4SiP=Z_cKJu3HG5kdwhrg@mail.gmail.com>
Message-ID:
 <CAL_JsqJv=+SQwmbwuw1C5Rv9sFHhk4SiP=Z_cKJu3HG5kdwhrg@mail.gmail.com>
Subject: Re: [PATCH 19/21] treewide: add checks for the return value of memblock_alloc*()
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, 
	Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, 
	"David S. Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, 
	Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>, 
	Heiko Carstens <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, 
	Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, 
	Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, 
	Paul Burton <paul.burton@mips.com>, Petr Mladek <pmladek@suse.com>, Rich Felker <dalias@libc.org>, 
	Richard Weinberger <richard@nod.at>, Russell King <linux@armlinux.org.uk>, 
	Stafford Horne <shorne@gmail.com>, Tony Luck <tony.luck@intel.com>, 
	Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, 
	devicetree@vger.kernel.org, kasan-dev@googlegroups.com, 
	linux-alpha@vger.kernel.org, 
	"moderated list:ARM/FREESCALE IMX / MXC ARM ARCHITECTURE" <linux-arm-kernel@lists.infradead.org>, linux-c6x-dev@linux-c6x.org, 
	linux-ia64@vger.kernel.org, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-m68k@lists.linux-m68k.org, 
	linux-mips@vger.kernel.org, linux-s390@vger.kernel.org, 
	SH-Linux <linux-sh@vger.kernel.org>, arcml <linux-snps-arc@lists.infradead.org>, 
	linux-um@lists.infradead.org, Linux USB List <linux-usb@vger.kernel.org>, 
	linux-xtensa@linux-xtensa.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, 
	Openrisc <openrisc@lists.librecores.org>, sparclinux@vger.kernel.org, 
	"moderated list:H8/300 ARCHITECTURE" <uclinux-h8-devel@lists.sourceforge.jp>, x86@kernel.org, 
	xen-devel@lists.xenproject.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190116151824.ogXAT55qyTDtNynwg1iZ1-Ry3fglZM1pZoDmOZeJviI@z>

On Wed, Jan 16, 2019 at 7:46 AM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> Add check for the return value of memblock_alloc*() functions and call
> panic() in case of error.
> The panic message repeats the one used by panicing memblock allocators with
> adjustment of parameters to include only relevant ones.
>
> The replacement was mostly automated with semantic patches like the one
> below with manual massaging of format strings.
>
> @@
> expression ptr, size, align;
> @@
> ptr = memblock_alloc(size, align);
> + if (!ptr)
> +       panic("%s: Failed to allocate %lu bytes align=0x%lx\n", __func__,
> size, align);
>
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>  arch/alpha/kernel/core_cia.c              |  3 +++
>  arch/alpha/kernel/core_marvel.c           |  6 ++++++
>  arch/alpha/kernel/pci-noop.c              | 11 ++++++++++-
>  arch/alpha/kernel/pci.c                   | 11 ++++++++++-
>  arch/alpha/kernel/pci_iommu.c             | 12 ++++++++++++
>  arch/arc/mm/highmem.c                     |  4 ++++
>  arch/arm/kernel/setup.c                   |  6 ++++++
>  arch/arm/mm/mmu.c                         | 14 +++++++++++++-
>  arch/arm64/kernel/setup.c                 |  9 ++++++---
>  arch/arm64/mm/kasan_init.c                | 10 ++++++++++
>  arch/c6x/mm/dma-coherent.c                |  4 ++++
>  arch/c6x/mm/init.c                        |  3 +++
>  arch/csky/mm/highmem.c                    |  5 +++++
>  arch/h8300/mm/init.c                      |  3 +++
>  arch/m68k/atari/stram.c                   |  4 ++++
>  arch/m68k/mm/init.c                       |  3 +++
>  arch/m68k/mm/mcfmmu.c                     |  6 ++++++
>  arch/m68k/mm/motorola.c                   |  9 +++++++++
>  arch/m68k/mm/sun3mmu.c                    |  6 ++++++
>  arch/m68k/sun3/sun3dvma.c                 |  3 +++
>  arch/microblaze/mm/init.c                 |  8 ++++++--
>  arch/mips/cavium-octeon/dma-octeon.c      |  3 +++
>  arch/mips/kernel/setup.c                  |  3 +++
>  arch/mips/kernel/traps.c                  |  3 +++
>  arch/mips/mm/init.c                       |  5 +++++
>  arch/nds32/mm/init.c                      | 12 ++++++++++++
>  arch/openrisc/mm/ioremap.c                |  8 ++++++--
>  arch/powerpc/kernel/dt_cpu_ftrs.c         |  5 +++++
>  arch/powerpc/kernel/pci_32.c              |  3 +++
>  arch/powerpc/kernel/setup-common.c        |  3 +++
>  arch/powerpc/kernel/setup_64.c            |  4 ++++
>  arch/powerpc/lib/alloc.c                  |  3 +++
>  arch/powerpc/mm/hash_utils_64.c           |  3 +++
>  arch/powerpc/mm/mmu_context_nohash.c      |  9 +++++++++
>  arch/powerpc/mm/pgtable-book3e.c          | 12 ++++++++++--
>  arch/powerpc/mm/pgtable-book3s64.c        |  3 +++
>  arch/powerpc/mm/pgtable-radix.c           |  9 ++++++++-
>  arch/powerpc/mm/ppc_mmu_32.c              |  3 +++
>  arch/powerpc/platforms/pasemi/iommu.c     |  3 +++
>  arch/powerpc/platforms/powermac/nvram.c   |  3 +++
>  arch/powerpc/platforms/powernv/opal.c     |  3 +++
>  arch/powerpc/platforms/powernv/pci-ioda.c |  8 ++++++++
>  arch/powerpc/platforms/ps3/setup.c        |  3 +++
>  arch/powerpc/sysdev/msi_bitmap.c          |  3 +++
>  arch/s390/kernel/setup.c                  | 13 +++++++++++++
>  arch/s390/kernel/smp.c                    |  5 ++++-
>  arch/s390/kernel/topology.c               |  6 ++++++
>  arch/s390/numa/mode_emu.c                 |  3 +++
>  arch/s390/numa/numa.c                     |  6 +++++-
>  arch/s390/numa/toptree.c                  |  8 ++++++--
>  arch/sh/mm/init.c                         |  6 ++++++
>  arch/sh/mm/numa.c                         |  4 ++++
>  arch/um/drivers/net_kern.c                |  3 +++
>  arch/um/drivers/vector_kern.c             |  3 +++
>  arch/um/kernel/initrd.c                   |  2 ++
>  arch/um/kernel/mem.c                      | 16 ++++++++++++++++
>  arch/unicore32/kernel/setup.c             |  4 ++++
>  arch/unicore32/mm/mmu.c                   | 15 +++++++++++++--
>  arch/x86/kernel/acpi/boot.c               |  3 +++
>  arch/x86/kernel/apic/io_apic.c            |  5 +++++
>  arch/x86/kernel/e820.c                    |  3 +++
>  arch/x86/platform/olpc/olpc_dt.c          |  3 +++
>  arch/x86/xen/p2m.c                        | 11 +++++++++--
>  arch/xtensa/mm/kasan_init.c               |  4 ++++
>  arch/xtensa/mm/mmu.c                      |  3 +++
>  drivers/clk/ti/clk.c                      |  3 +++
>  drivers/macintosh/smu.c                   |  3 +++
>  drivers/of/fdt.c                          |  8 +++++++-
>  drivers/of/unittest.c                     |  8 +++++++-

Acked-by: Rob Herring <robh@kernel.org>

>  drivers/xen/swiotlb-xen.c                 |  7 +++++--
>  kernel/power/snapshot.c                   |  3 +++
>  lib/cpumask.c                             |  3 +++
>  mm/kasan/init.c                           | 10 ++++++++--
>  mm/sparse.c                               | 19 +++++++++++++++++--
>  74 files changed, 415 insertions(+), 29 deletions(-)

