Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3A81C282E1
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 07:54:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 563F620857
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 07:54:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 563F620857
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=users.sourceforge.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B675B6B0003; Mon, 22 Apr 2019 03:54:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B19476B0006; Mon, 22 Apr 2019 03:54:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A07AD6B0007; Mon, 22 Apr 2019 03:54:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 64EA86B0003
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 03:54:20 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i14so7185961pfd.10
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 00:54:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:from:to:cc:subject:in-reply-to:references:user-agent
         :mime-version;
        bh=9bgXPkKLhBF6vZXEFTfrl0O6ig2EV3XWJGDSuYwhKO4=;
        b=uALe66R3W/8GR/Fewd9d6bEAmuAv+V7ET3hf/XDST4buHxM5zgYFV6vJoxtjyfNQHA
         g92M4621r6W9s9IB6cedPwb+FO8oTWj2qTLKgPyaZakt0LSqa0Ro/KIwXhV9NNDeLq2e
         MQ3RXnH9WUjNFh7xSQECf3hVy+spy+yujKTa48bhX9qu9WWlveD8YWD5aBlFEQLz9oce
         3uy/di8Ele3iGtZsvUXr2GjAc27o/nq0MGkDJlEqqc7gmaGQxxojXbGoSR/RvB/V8ipj
         HGnKst/q0QijFcb58zd99U67tPP/efCqcZv6+1ThMqzOhPNB5/VFcP+lEj/MDDmKm3wH
         GQ4g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning ysato@users.sourceforge.jp does not designate 202.224.55.13 as permitted sender) smtp.mailfrom=ysato@users.sourceforge.jp
X-Gm-Message-State: APjAAAXnideyFkkUWbZAEH+xl2g7h1S5fZTdI2/XCxb/mo+tfNRTgnDz
	NfaZOKvmoPAHZPOwiJBrK+rDhcBSCY5KJpfqFmnVaocc5HFjl6CgrGPMU+qiqw1HxZl4goB4PnR
	//q9RXPCCvS5kk190LWizYMyRn3yImj2YVr14S+IcaX96HeN6x6+zxMebHhT28RI=
X-Received: by 2002:a63:720c:: with SMTP id n12mr17384050pgc.348.1555919659932;
        Mon, 22 Apr 2019 00:54:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwy3hb1dbxeFvuTDbXmEL9SqTYtHhslGeGTn5/up43pWdi1bA97BREck1H0veZNMWlEdoeQ
X-Received: by 2002:a63:720c:: with SMTP id n12mr17383993pgc.348.1555919658684;
        Mon, 22 Apr 2019 00:54:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555919658; cv=none;
        d=google.com; s=arc-20160816;
        b=n3U05jYm/djUu6zRvP6eO0GcT5Y6TjUM8qjRQQYSdIEa6jzmqtX7QD3nS1OMnu0Jpf
         QtPnziu2Xw+ZUJawqxZ1SIPJBkz+BgZQ9lXFG/K+Ejlf2gD4yEj5FuhCT3XYpVA/zfSc
         nRr4BrdEqP+8fnDIKmB7QGPGgDVQaUhhwlZuMvrc6J9ycJMqAHVdCYqc9tVWQP9VP48Y
         rO+/dBcpZmQdBdqhFfQhahtPzcyBo2WBuSjBwIReOOP+gvhm546luv/KNmROTNfbfCn6
         NUzUa2Znl9MIGmfyNPMbXltLLPB3Hq1xZCrQqF2dNyn3GsFzutRXRUlsiJCqQzrEQ74v
         tdsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:in-reply-to:subject:cc:to:from
         :message-id:date;
        bh=9bgXPkKLhBF6vZXEFTfrl0O6ig2EV3XWJGDSuYwhKO4=;
        b=SyqcJrY0npQhNdXspYMyh18GHqygC+JViXLH3G/ilbsDOlY1KmfHTaQOxQXwcXbBCQ
         KT+qmRYM9KyRhQbC4hg64P3Sh34N4a5h6b1hyiazVdcyzOotSp9lCFq2X1Oggi22bFmM
         41arieTC+c1UwshRMfFm8or2aNBfScMlYqWPsuWHmvrJl7iZ0ziW3OmDV21Fw+oUnRvN
         2m2LnnCo/DOU0TnIf4uTSkogrHPem3uDVDAuhlXpgnwanKPSAdGCUBsWphLDPtvmT5RZ
         gReUWRM9zblS9wbyR5BTN1sbvV8BEP0SeXraoiRxhTET/jZDkfXHl72tXUyu1Gcd+1Tm
         wqRA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning ysato@users.sourceforge.jp does not designate 202.224.55.13 as permitted sender) smtp.mailfrom=ysato@users.sourceforge.jp
Received: from mail01.asahi-net.or.jp (mail01.asahi-net.or.jp. [202.224.55.13])
        by mx.google.com with ESMTP id i1si10992494pgq.528.2019.04.22.00.54.17
        for <linux-mm@kvack.org>;
        Mon, 22 Apr 2019 00:54:18 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning ysato@users.sourceforge.jp does not designate 202.224.55.13 as permitted sender) client-ip=202.224.55.13;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning ysato@users.sourceforge.jp does not designate 202.224.55.13 as permitted sender) smtp.mailfrom=ysato@users.sourceforge.jp
Received: from h61-195-96-97.vps.ablenet.jp (h61-195-96-97.vps.ablenet.jp [61.195.96.97])
	(Authenticated sender: PQ4Y-STU)
	by mail01.asahi-net.or.jp (Postfix) with ESMTPA id C4A1C11B04C;
	Mon, 22 Apr 2019 16:54:15 +0900 (JST)
Received: from yo-satoh-debian.ysato.ml (ZM005235.ppp.dion.ne.jp [222.8.5.235])
	by h61-195-96-97.vps.ablenet.jp (Postfix) with ESMTPSA id 308CF240082;
	Mon, 22 Apr 2019 16:54:14 +0900 (JST)
Date: Mon, 22 Apr 2019 16:54:10 +0900
Message-ID: <87mukimq59.wl-ysato@users.sourceforge.jp>
From: Yoshinori Sato <ysato@users.sourceforge.jp>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: kbuild test robot <lkp@intel.com>,
	kbuild-all@01.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	paul.mundt@gmail.com,
	Rich Felker <dalias@libc.org>,
	Linux-sh list <linux-sh@vger.kernel.org>
Subject: Re: arch/sh/kernel/cpu/sh2/clock-sh7619.o:undefined reference to `followparent_recalc'
In-Reply-To: <a7b17eb8-349f-298c-2e82-895a70b201ac@infradead.org>
References: <201904201516.DdPznV5M%lkp@intel.com>
	<fb6880d2-06a4-cec2-e12c-c526d3a4358a@infradead.org>
	<87sgubcvoj.wl-ysato@users.sourceforge.jp>
	<a7b17eb8-349f-298c-2e82-895a70b201ac@infradead.org>
User-Agent: Wanderlust/2.15.9 (Almost Unreal) SEMI-EPG/1.14.7 (Harue)
 FLIM/1.14.9 (=?ISO-8859-4?Q?Goj=F2?=) APEL/10.8 EasyPG/1.0.0 Emacs/25.1
 (x86_64-pc-linux-gnu) MULE/6.0 (HANACHIRUSATO)
MIME-Version: 1.0 (generated by SEMI-EPG 1.14.7 - "Harue")
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 Apr 2019 00:24:21 +0900,
Randy Dunlap wrote:
> 
> On 4/21/19 6:52 AM, Yoshinori Sato wrote:
> > On Sun, 21 Apr 2019 04:34:36 +0900,
> > Randy Dunlap wrote:
> >>
> >> On 4/20/19 12:40 AM, kbuild test robot wrote:
> >>> Hi Randy,
> >>>
> >>> It's probably a bug fix that unveils the link errors.
> >>>
> >>> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> >>> head:   371dd432ab39f7bc55d6ec77d63b430285627e04
> >>> commit: acaf892ecbf5be7710ae05a61fd43c668f68ad95 sh: fix multiple function definition build errors
> >>> date:   2 weeks ago
> >>> config: sh-allmodconfig (attached as .config)
> >>> compiler: sh4-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
> >>> reproduce:
> >>>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
> >>>         chmod +x ~/bin/make.cross
> >>>         git checkout acaf892ecbf5be7710ae05a61fd43c668f68ad95
> >>>         # save the attached .config to linux build tree
> >>>         GCC_VERSION=7.2.0 make.cross ARCH=sh 
> >>
> >> Hi,
> >>
> >> Once again, the question is the validity of the SH2 .config file in this case
> >> (that was attached).
> >>
> >> I don't believe that it is valid because CONFIG_SH_DEVICE_TREE=y,
> >> which selects COMMON_CLK, and there is no followparent_recalc() in the
> >> COMMON_CLK API.
> >>
> >> Also, while CONFIG_HAVE_CLK=y, drivers/sh/Makefile prevents that from
> >> building clk/core.c, which could provide followparent_recalc():
> >>
> >> ifneq ($(CONFIG_COMMON_CLK),y)
> >> obj-$(CONFIG_HAVE_CLK)			+= clk/
> >> endif
> >>
> >> Hm, maybe that's where the problem is.  I'll look into that more.
> >>
> > 
> > Yes.
> > Selected target (CONFIG_SH_7619_SOLUTION_ENGINE) is non devicetree
> > and used superh specific clk modules.
> > So allyesconfig output is incorrect.
> > 
> > I fixed Kconfig to output the correct config.
> 
> Thanks for that.
> The patch fixes this problem in my builds.

OK. Thanks.

> However, now I see these build errors:
> 
> ERROR: "__ashiftrt_r4_28" [fs/udf/udf.ko] undefined!
> ERROR: "__ashiftrt_r4_26" [drivers/rtc/rtc-x1205.ko] undefined!
> ERROR: "__ashiftrt_r4_25" [drivers/rtc/rtc-pcf2123.ko] undefined!
> ERROR: "__ashiftrt_r4_28" [drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.ko] undefined!
> ERROR: "__ashiftrt_r4_25" [drivers/input/tablet/gtco.ko] undefined!
> ERROR: "__ashiftrt_r4_26" [drivers/input/mouse/psmouse.ko] undefined!
> ERROR: "__ashiftrt_r4_28" [drivers/input/mouse/psmouse.ko] undefined!
> ERROR: "__ashiftrt_r4_25" [drivers/iio/pressure/bmp280.ko] undefined!
> ERROR: "__ashiftrt_r4_26" [drivers/iio/dac/ad5764.ko] undefined!
> ERROR: "__ashiftrt_r4_26" [drivers/iio/accel/mma7660.ko] undefined!
> ERROR: "__ashiftrt_r4_25" [drivers/iio/accel/dmard06.ko] undefined!
> ERROR: "__ashiftrt_r4_26" [drivers/iio/accel/bma220_spi.ko] undefined!
> ERROR: "__ashiftrt_r4_25" [drivers/crypto/hisilicon/sec/hisi_sec.ko] undefined!
> 
> Is this just a toolchain problem?
> 
> I am using the gcc 8.1.0 tools from
> https://mirrors.edge.kernel.org/pub/tools/crosstool/
>

It looks libgcc function.
sh port using private build libgcc. It missing this function.
We need added __ashiftrt_r4 variant.

> 
> thanks.
> -- 
> ~Randy

-- 
Yosinori Sato

