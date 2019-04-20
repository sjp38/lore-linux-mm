Return-Path: <SRS0=t1VS=SW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0100C282DD
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 19:34:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8177620651
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 19:34:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="mzwZvj05"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8177620651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9AE16B0003; Sat, 20 Apr 2019 15:34:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C49C06B0006; Sat, 20 Apr 2019 15:34:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B60CB6B0007; Sat, 20 Apr 2019 15:34:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 98D3D6B0003
	for <linux-mm@kvack.org>; Sat, 20 Apr 2019 15:34:58 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id 79so8796269itz.3
        for <linux-mm@kvack.org>; Sat, 20 Apr 2019 12:34:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=yBGAB8b1n3dFt3YiVQiw88D3yeUo9coqXwfyseTVuP8=;
        b=ZcRPUs7dV1NtxS3sODxGJRt8vsqHYdpmbtjGnAlK2BRHwQVH0cuKF1BjHdcgaPCuuQ
         ZIxy3kArN9B1B4osRkeEtkBaR/AnsIbh2ZSMTRcxMMsDf9E8vDzDIeDFJdMiu1SNkXpo
         EvrxDeVF3A1kLIAFvYR8Ul3EhG//je4GaFpgBLw2xsa5tVI36YusFyTFVLbeAArEl2sL
         do2wL2KYBsvyonP8tuqzj4XGLY8q/rNmYggQMTrteIx24DhZ+2wS1RKioq0KU9mQISR+
         luMiQcXFalB9AaV7g+DRz3Hpz9U2MCquJ01jtQ0Qq5MQD5bukDblQ1htUqQxew/5DNBl
         aLyw==
X-Gm-Message-State: APjAAAV+KkDE172HcGWSA389YODm5TSpmAOccVDffT2lgQU4YDRnuyOU
	rkJZ4ZoBhlFv1Yler5a7xc4yOAIz9V3RIamOE1DFnVJRP6qOxc5vDij4mf2eS9gXO4VNeK7ZwGK
	pC4K9cwqsRv3XmeqSeOLwa1nd191i4QtxMlTaudrFvG727Vnnz7YjhwOiM4zR3OUdFg==
X-Received: by 2002:a5e:8348:: with SMTP id y8mr5872785iom.88.1555788898127;
        Sat, 20 Apr 2019 12:34:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCKyJ2Eo/rzD4tNvkPewYEJpkJmn4Ei1BV2/06MUAaWcnZbuEZCrcqNILhcRnif8v9G0jZ
X-Received: by 2002:a5e:8348:: with SMTP id y8mr5872757iom.88.1555788897213;
        Sat, 20 Apr 2019 12:34:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555788897; cv=none;
        d=google.com; s=arc-20160816;
        b=mdWiK92QYxOkI5b6OgFJdF6aeOSUc5DTRpdaXNya3iuGjL0CrOs/6asRDiR5YOjHfB
         c5CTFA8klpJ7n7YxPnoqH9BDHNkys22+Y3WkaZmboBGz0yypbELUgijOlo33INhJkmeb
         npiPDrAMyYScD4l/c2lyAQT3lsmXU+1Cmu2DC+2T/bZMDmSqBNfVjE8pJEOoTkrnirz4
         wMX0cncSaYXV9bCS2HX9PaYHhakxf7EdK7GrNzPBo8/LDl7ssY8/fP3NNaflimhXe3iR
         qMWxlCde5OmP+f47hQOjcBH1CBsKtASIV7XiU6oUHcYS2UYlZsl+F1OqvooCwxgkegvn
         OplA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=yBGAB8b1n3dFt3YiVQiw88D3yeUo9coqXwfyseTVuP8=;
        b=VM0pyjq3fN9hbeRI2f9+EKhY7DoKa0R76VfBd9UxrWExsiWy2rzdUDybUBR643lTuO
         9Qo1pN5FhERHWXfwH0mlz6hJK7yGuwzySTl0DUePyruRORo5lUXDJPIQmkNPR+RmJjb+
         mJ47Q2ACmRR0Mui4UGhyOid5TIyEYQEOAXW3NhlZR/aCVEZuhH9kxp13nZQOPK56u7z5
         VdOBsn9HKo7YCLol3nJplSj7aXjDai+M4cf27Ma+ipsPCVPVa952v43f+bHiVMak6iP1
         uE8XXFG98G13z2UkXuaaJDjkPvqgte7/yj/qY6Z4DetvTOWZ3r8nuwzOLHZgcb9zdgpf
         AE5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=mzwZvj05;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 5si5628903itv.110.2019.04.20.12.34.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 20 Apr 2019 12:34:56 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=mzwZvj05;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:Subject:Sender
	:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=yBGAB8b1n3dFt3YiVQiw88D3yeUo9coqXwfyseTVuP8=; b=mzwZvj05wmRaDLh4JLHUh9hDwF
	s8L8iA3qot/dFziw+9hvQXQwPfastAs0EqxYFVKDs6NBq0z7nHKRCZVkUi2Sa2eYZngi6Op4SkFZv
	NqrB0fDDreHKatH9VA9DR/fRDYFA+z9GnN3XijRaant9BZ8vgFT6FDuV0RYux+kuss+CoyiSLjeKm
	uQU+jRzxBFEn3oDnmDXHTxepOk7cMPLn/97W3hxQVRCfO0W2xO6O5vuu9ts4vMphbUDYH5JQ7b+fK
	if1GHX4UxMYE5l4f0fmjWIhkdJieSYWDuwHIQjmm4N1SvF0yRQZhyUkg8qmOoQn9c9MBdKuseBXDE
	hwoRTgyw==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=dragon.dunlab)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hHvl2-00026T-6j; Sat, 20 Apr 2019 19:34:40 +0000
Subject: Re: arch/sh/kernel/cpu/sh2/clock-sh7619.o:undefined reference to
 `followparent_recalc'
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org,
 Andrew Morton <akpm@linux-foundation.org>,
 Linux Memory Management List <linux-mm@kvack.org>, paul.mundt@gmail.com,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 Linux-sh list <linux-sh@vger.kernel.org>
References: <201904201516.DdPznV5M%lkp@intel.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <fb6880d2-06a4-cec2-e12c-c526d3a4358a@infradead.org>
Date: Sat, 20 Apr 2019 12:34:36 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <201904201516.DdPznV5M%lkp@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/20/19 12:40 AM, kbuild test robot wrote:
> Hi Randy,
> 
> It's probably a bug fix that unveils the link errors.
> 
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   371dd432ab39f7bc55d6ec77d63b430285627e04
> commit: acaf892ecbf5be7710ae05a61fd43c668f68ad95 sh: fix multiple function definition build errors
> date:   2 weeks ago
> config: sh-allmodconfig (attached as .config)
> compiler: sh4-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout acaf892ecbf5be7710ae05a61fd43c668f68ad95
>         # save the attached .config to linux build tree
>         GCC_VERSION=7.2.0 make.cross ARCH=sh 

Hi,

Once again, the question is the validity of the SH2 .config file in this case
(that was attached).

I don't believe that it is valid because CONFIG_SH_DEVICE_TREE=y,
which selects COMMON_CLK, and there is no followparent_recalc() in the
COMMON_CLK API.

Also, while CONFIG_HAVE_CLK=y, drivers/sh/Makefile prevents that from
building clk/core.c, which could provide followparent_recalc():

ifneq ($(CONFIG_COMMON_CLK),y)
obj-$(CONFIG_HAVE_CLK)			+= clk/
endif

Hm, maybe that's where the problem is.  I'll look into that more.



It would be Good if someone from the SuperH area could/would comment.

Thanks.


> If you fix the issue, kindly add following tag
> Reported-by: kbuild test robot <lkp@intel.com>
> 
> 
> All errors (new ones prefixed by >>):
> 
>>> arch/sh/kernel/cpu/sh2/clock-sh7619.o:(.data+0x1c): undefined reference to `followparent_recalc'
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> 


-- 
~Randy

