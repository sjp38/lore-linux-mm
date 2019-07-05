Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1EA2FC46499
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 18:24:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1D35216FD
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 18:24:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="cPIYeeEq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1D35216FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D7546B0003; Fri,  5 Jul 2019 14:24:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45FD78E0003; Fri,  5 Jul 2019 14:24:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D9BF8E0001; Fri,  5 Jul 2019 14:24:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E8FBA6B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 14:24:25 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 6so6001661pfi.6
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 11:24:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=SNYSoxZkF3Rdxx2ZQVEVEImqJsKcC3EqWd4waxRXPQA=;
        b=D0YKO6zRkQO2hga+Lrb84Zf255o3W0pnpAiWIxcspysR7v1yBNquxTtOUvyANxgu9S
         VJjpCzZvd2lOIwhOlPpy3H5QcA2Ie95mWBVoSbfN5JfqvXPDHESQENYck/GQV/uhHsMY
         NU8Dvvp+38P65qLdU2KgJzjJXrXHulKEg8e8cFuuinqBPTyeNkmeC2ab0L04zUdac0wb
         gx76NwozOe/+XyKXLh5FX2k/FNxIC+ZPT6bXsofNb5aqPXf700n2b2UhPZVbNdUtw+Dd
         JlNDWXZzodtApLBGzuatX79DgMaioQas6xLITBoRiuiP9TkR8v8qa5xJmXJvkuVgC+L1
         Y8SA==
X-Gm-Message-State: APjAAAVQjPMu8w39HSBRi7Ged785a1CT4k3ncrjNKPNrrorBD/qidcqv
	b7iey1aE5mMIUNHwfbwaWVz4pUXs1IUHoRLqSktjjghoD4z/shiXmnsWkeISusaG/1JG3+qpvox
	134qOEVuPxEJnN7Pzis2CDtXq01aZaanvdKCiYW4vpoCHA9++UkGr8oTj5a3OTcBsdw==
X-Received: by 2002:a17:90a:3310:: with SMTP id m16mr7096124pjb.7.1562351065530;
        Fri, 05 Jul 2019 11:24:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzlaVvJqXPCiNDarUEcqAxKSsZKMdppsYKS77zy+LppSdCeizelQt4oosjkJCi2aaPqNjQC
X-Received: by 2002:a17:90a:3310:: with SMTP id m16mr7096050pjb.7.1562351064659;
        Fri, 05 Jul 2019 11:24:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562351064; cv=none;
        d=google.com; s=arc-20160816;
        b=VnlLLnbUQvCuugm1kG9LdxtP9Ldhd/bsYKcraI6WxR5Rr9IPRNbvARqhSzAuNdJDEv
         zfAqVa+fywAw0eX58G5uv8Wbye8zgGTHOQ21S32onP/imbILUdNfbPgrFDPsXWp1jJRY
         rSa7gMfwYFr0FrFnMo7PaK1nXnpWAVaJjKmoB5FDvzyocxIRbDdZ0OfjnpfUXN2naOUT
         qfBb6uvUT96fsu4Co+7/Uj7s1nMZHo5CbESe7LWPL+/cIk8vqDZaGE9+iqSlujS+tQDb
         G/LzU/hj90JBGyWMI07Yu1z8BmJfnK63WbhPxfCXXNIz9jpoK/NurU72YIo3+e7793CJ
         CQ5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=SNYSoxZkF3Rdxx2ZQVEVEImqJsKcC3EqWd4waxRXPQA=;
        b=AYe1ZcYI8P8q9KH7kTG+TCfL/+1qY0SiBQQJ4isJTzn1Ytu7RurTbxxI9303IFjAYc
         yq8mnAszCJYoBLpDQCgCWcqT4GkPC7U+RauQaS3iQQ8nYpzsP7wua4R9qQQ7fwduuW2z
         E6OSp2RO5Syn/3i9nIIzL4kAUOFpel0ebxmxVZHLunmiQlm+S9nEh41/0ga6/qatADBR
         yY0ztCTKAUOeSutklkTTvNqGA4FseLwwZylBvs0WOiW005B9mJweSAFm4jTo6yzmIws9
         KswcODKCCzc0sHgl+/eJP8dze4U8wHWpmnqV+TRd8lgczHgIp6iWPuHs8nhfzMs0SRBS
         FY2g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=cPIYeeEq;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 61si6785380plb.270.2019.07.05.11.24.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jul 2019 11:24:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=cPIYeeEq;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id BEBC52089C;
	Fri,  5 Jul 2019 18:24:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562351064;
	bh=2y0OFtHQOET0VSSyMlafprvdUrczPn42OquPh94gazY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=cPIYeeEq68ZR0SvrkoClo7jjXiBainG0h8LzwsHE1pywPJr6yjQewgs27SsSL2d6l
	 7kqiLG4RXOKlpiG4CYh/2EWmdrS8TPatebz7l3GLh86L9xHzcqjnm9a2RZ1XDVOAh+
	 NVBNsJMkfCbI3mS7spA3Kl9M2axXj3Ng7rI729b4=
Date: Fri, 5 Jul 2019 20:24:20 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Sasha Levin <alexander.levin@microsoft.com>
Subject: Re: [linux-stable-rc:linux-4.9.y 9986/9999] ptrace.c:undefined
 reference to `abort'
Message-ID: <20190705182420.GA16461@kroah.com>
References: <201907060045.bQY0GTP0%lkp@intel.com>
 <20190705161529.GA8626@kroah.com>
 <CAK8P3a099ZeiEe-zOTJb5tXKtTU7iwzGkjv8riQVK+navotRxw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAK8P3a099ZeiEe-zOTJb5tXKtTU7iwzGkjv8riQVK+navotRxw@mail.gmail.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 05, 2019 at 06:31:51PM +0200, Arnd Bergmann wrote:
> On Fri, Jul 5, 2019 at 6:15 PM Greg Kroah-Hartman
> <gregkh@linuxfoundation.org> wrote:
> > On Sat, Jul 06, 2019 at 12:08:59AM +0800, kbuild test robot wrote:
> > >    arch/arc/built-in.o: In function `arc_pmu_device_probe':
> > > >> perf_event.c:(.text+0x99e6): undefined reference to `abort'
> > >    arch/arc/built-in.o:perf_event.c:(.text+0x99e6): more undefined references to `abort' follow
> >
> > I've queued up af1be2e21203 ("ARC: handle gcc generated __builtin_trap
> > for older compiler") to hopefully resolve this now.
> 
> Thanks, I remember the same problem happening in mainline now,
> and this should solve the issue.
> 
> I also see that the backported patch that introduced the regression
> has succeed in getting rid of many of the warnings in 4.9.y, and kernelci
> itself does not run into the abort() issue because it has a different
> compiler version:
> 
> https://kernelci.org/build/stable-rc/branch/linux-4.9.y/kernel/v4.9.184-93-gaf13e6db0db4/
> 
> All that remains now is
> 
> cc1: error: '-march=r3000' requires '-mfp32'
> (.text+0x1bf20): undefined reference to `iommu_is_span_boundary'
> (.text+0x1bbd0): undefined reference to `iommu_is_span_boundary'
> warning: (SIBYTE_SWARM && SIBYTE_SENTOSA && SIBYTE_BIGSUR &&
> SWIOTLB_XEN && AMD_IOMMU) selects SWIOTLB which has unmet direct
> dependencies (CAVIUM_OCTEON_SOC || MACH_LOONGSON64 && CPU_LOONGSON3 ||
> NLM_XLP_BOARD || NLM_XLR_BOARD)
> arch/arc/kernel/unwind.c:188:14: warning: 'unw_hdr_alloc' defined but
> not used [-Wunused-function]
> drivers/clk/sunxi/clk-sun8i-bus-gates.c:85:27: warning: 'clk_parent'
> may be used uninitialized in this function [-Wmaybe-uninitialized]
> arch/arm64/kernel/vdso.c:127:6: warning: 'memcmp' reading 4 bytes from
> a region of size 1 [-Wstringop-overflow=]
> 
> The two arm specific issues are fixed with these patches
> 
> 4e903450bcb9 ("clk: sunxi: fix uninitialized access")

That applies.

> dbbb08f500d6 ("arm64, vdso: Define vdso_{start,end} as array")

That one does not :(

Care to backport it?  :)

Now we can start tackling the gcc9 issues... :(

thanks,

greg k-h

