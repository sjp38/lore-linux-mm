Return-Path: <SRS0=izd7=SX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB529C282E1
	for <linux-mm@archiver.kernel.org>; Sun, 21 Apr 2019 15:24:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 69B3520859
	for <linux-mm@archiver.kernel.org>; Sun, 21 Apr 2019 15:24:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="YkyaWKy5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69B3520859
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CEF0F6B0003; Sun, 21 Apr 2019 11:24:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9ED36B0006; Sun, 21 Apr 2019 11:24:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB55C6B0007; Sun, 21 Apr 2019 11:24:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 836346B0003
	for <linux-mm@kvack.org>; Sun, 21 Apr 2019 11:24:31 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id o8so6537306pgq.5
        for <linux-mm@kvack.org>; Sun, 21 Apr 2019 08:24:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=9op1eYhFbJ9bjqJb16BhG3ik80oPMlMP4bm14U6cZdM=;
        b=ezbt2kOgelDuWyWUqyY76bttUmQZV2rQOwK0aaU8jEhPePcRHTzznueeAC6J9lxjAb
         NFvRpuPyGe32mLo0p5TlRZ2q1aSpYe8pZ+Dy/P//wKfAJU/OTDBF80gcqeDAdWKHwKcT
         F4MqzvTiTMPWB12km5gG0uxQn+9x8hVX8h9Nn5hyijTRnFjjpGdYQUylO6RniV9JUwFp
         +5q8Ac8dt8L1RErnVdWmb70h3Tgeyg6GpxD4UlhDXKf3r3QVVG7nhxk0hYiJ5q2QrEBR
         I8k6OXIWlk88bvbdrhOKgs6+8gCCHzfVh89Sazd5esmJhb0VObCv2XIx4Lw0Vat56HD6
         FQGg==
X-Gm-Message-State: APjAAAX6yHV3U+Mn5yDh9CgD/IUCaHblDnu2YDpW9LzJLFpLsjvfdWHy
	1UpsMom2MiOvr0YgYrTe8FHh6mzJ+u4cPykVbEYXjeKn3TO/pvMm0b//aNzfV94gL6DtWH18nNF
	YIfwi73cH8nZ4DGDsO2LZErNFdFOoX5IFVq6WDG1B3MU7BxaRRp4Fx5VfnjmstTyVnQ==
X-Received: by 2002:a17:902:1105:: with SMTP id d5mr15501819pla.311.1555860270314;
        Sun, 21 Apr 2019 08:24:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhLF9LXBI8ITj+bQgCe80TP9vHMixcu7uPg442nzRSZzc/d6vwp3aPfq1Ehv36JFp8ljBX
X-Received: by 2002:a17:902:1105:: with SMTP id d5mr15501750pla.311.1555860269429;
        Sun, 21 Apr 2019 08:24:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555860269; cv=none;
        d=google.com; s=arc-20160816;
        b=bq13Zjvcoh1QJcV2YLjQ2Q2w6Ilts097KWHqfPQFRYsbBnr1uZyQH8HL3/LKZXwJv1
         dyuEDzPQ5mMgInGABwFd69xuWW9UnucEc2t7zHYBZ+0elwBtKZL2oQi/h+gcS6k8GiAX
         DWRSrGLeXfSCAlZvAaa4mSEqYZEACxqqfiXtdJU3ir41WMooKha/ZGDvM80zK1UociJA
         qgzIeSqT3eWZiqFO9edgu4qEJ2/BPhjZiGfnLegvbaDUFTMoj5dBfZX4lyTykrzT7oip
         d3pmWcx/g2BTjZiH3NNzsFj7VzDKwWaTTOqhqP1cKYhRipXAEy0OgDucgHW3j+XZJUdP
         y5Hw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=9op1eYhFbJ9bjqJb16BhG3ik80oPMlMP4bm14U6cZdM=;
        b=fWCs0v7hWC0XSNQktykjOW58B8EF3LFSfvpHQLEaZtxIzSefabHCll4RfwDElWljkK
         g+TjEuDJoi0SqB6spoxLkKCiqiQcSmi0zf7+WKi0itcgj5aDFgNwXYNwyaHp1/2HXg1i
         4BvDDCS2xfAImyDxQNcaYE68sdV5yvoIH5l3xDkllHGk5rCy2f0hMzJJzvEqXMBminmU
         ntPgCF+8dsb6HjM/H18nsun0KWVIiADgyDoEPzSk8R4/T0MD2FR9Qisc5iBl2TZAA1XC
         pANXLlncNHdeZo0Q7Dc8V6Tq0PUNT5UUjFJZRZMQi88ePrKjaJtK74nsqOY3f4VW6dmC
         ahDA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=YkyaWKy5;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y22si11750004pfo.49.2019.04.21.08.24.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 21 Apr 2019 08:24:29 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=YkyaWKy5;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=9op1eYhFbJ9bjqJb16BhG3ik80oPMlMP4bm14U6cZdM=; b=YkyaWKy5g6a2/qgjt1qeWio4N
	O4OL1HXCtDpdqrQuupSyXk0skuJv1XiuLaqyPjV7U3jD6POU+qkM55wEDT4rWszfjZQ20oUA0+mWv
	Dsn+3uU9gUnMxofW7ueVl7mZVGXsp3Pp9xSg7K8ColR04ta3KSssfzw98wtU17GeE8YkdbFoBdLOE
	PUpfnvtmWSFkcTaK562to/jAXRQbUMynqFO+lkkih0ruMIP6bjH7xATY4Qbef2yiMXv7k/7uHvYCA
	YmiHLxbYkrzMwPXvm5ko/7Kx07UM3eviDVdYmWY5ENPU/wkBRNZSnbck9yBX6aUYbfjjSwI5llTuc
	DNtw/dt5A==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=dragon.dunlab)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hIEKL-0003yr-Sh; Sun, 21 Apr 2019 15:24:26 +0000
Subject: Re: arch/sh/kernel/cpu/sh2/clock-sh7619.o:undefined reference to
 `followparent_recalc'
To: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org,
 linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
 Linux Memory Management List <linux-mm@kvack.org>, paul.mundt@gmail.com,
 Rich Felker <dalias@libc.org>, Linux-sh list <linux-sh@vger.kernel.org>
References: <201904201516.DdPznV5M%lkp@intel.com>
 <fb6880d2-06a4-cec2-e12c-c526d3a4358a@infradead.org>
 <87sgubcvoj.wl-ysato@users.sourceforge.jp>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <a7b17eb8-349f-298c-2e82-895a70b201ac@infradead.org>
Date: Sun, 21 Apr 2019 08:24:21 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <87sgubcvoj.wl-ysato@users.sourceforge.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/21/19 6:52 AM, Yoshinori Sato wrote:
> On Sun, 21 Apr 2019 04:34:36 +0900,
> Randy Dunlap wrote:
>>
>> On 4/20/19 12:40 AM, kbuild test robot wrote:
>>> Hi Randy,
>>>
>>> It's probably a bug fix that unveils the link errors.
>>>
>>> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
>>> head:   371dd432ab39f7bc55d6ec77d63b430285627e04
>>> commit: acaf892ecbf5be7710ae05a61fd43c668f68ad95 sh: fix multiple function definition build errors
>>> date:   2 weeks ago
>>> config: sh-allmodconfig (attached as .config)
>>> compiler: sh4-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
>>> reproduce:
>>>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>>>         chmod +x ~/bin/make.cross
>>>         git checkout acaf892ecbf5be7710ae05a61fd43c668f68ad95
>>>         # save the attached .config to linux build tree
>>>         GCC_VERSION=7.2.0 make.cross ARCH=sh 
>>
>> Hi,
>>
>> Once again, the question is the validity of the SH2 .config file in this case
>> (that was attached).
>>
>> I don't believe that it is valid because CONFIG_SH_DEVICE_TREE=y,
>> which selects COMMON_CLK, and there is no followparent_recalc() in the
>> COMMON_CLK API.
>>
>> Also, while CONFIG_HAVE_CLK=y, drivers/sh/Makefile prevents that from
>> building clk/core.c, which could provide followparent_recalc():
>>
>> ifneq ($(CONFIG_COMMON_CLK),y)
>> obj-$(CONFIG_HAVE_CLK)			+= clk/
>> endif
>>
>> Hm, maybe that's where the problem is.  I'll look into that more.
>>
> 
> Yes.
> Selected target (CONFIG_SH_7619_SOLUTION_ENGINE) is non devicetree
> and used superh specific clk modules.
> So allyesconfig output is incorrect.
> 
> I fixed Kconfig to output the correct config.

Thanks for that.
The patch fixes this problem in my builds.

However, now I see these build errors:

ERROR: "__ashiftrt_r4_28" [fs/udf/udf.ko] undefined!
ERROR: "__ashiftrt_r4_26" [drivers/rtc/rtc-x1205.ko] undefined!
ERROR: "__ashiftrt_r4_25" [drivers/rtc/rtc-pcf2123.ko] undefined!
ERROR: "__ashiftrt_r4_28" [drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.ko] undefined!
ERROR: "__ashiftrt_r4_25" [drivers/input/tablet/gtco.ko] undefined!
ERROR: "__ashiftrt_r4_26" [drivers/input/mouse/psmouse.ko] undefined!
ERROR: "__ashiftrt_r4_28" [drivers/input/mouse/psmouse.ko] undefined!
ERROR: "__ashiftrt_r4_25" [drivers/iio/pressure/bmp280.ko] undefined!
ERROR: "__ashiftrt_r4_26" [drivers/iio/dac/ad5764.ko] undefined!
ERROR: "__ashiftrt_r4_26" [drivers/iio/accel/mma7660.ko] undefined!
ERROR: "__ashiftrt_r4_25" [drivers/iio/accel/dmard06.ko] undefined!
ERROR: "__ashiftrt_r4_26" [drivers/iio/accel/bma220_spi.ko] undefined!
ERROR: "__ashiftrt_r4_25" [drivers/crypto/hisilicon/sec/hisi_sec.ko] undefined!

Is this just a toolchain problem?

I am using the gcc 8.1.0 tools from
https://mirrors.edge.kernel.org/pub/tools/crosstool/


thanks.
-- 
~Randy

