Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B75EC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 00:39:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD27520820
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 00:39:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="F2W38VBd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD27520820
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 79BFA6B026A; Wed,  3 Apr 2019 20:39:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 721A06B026B; Wed,  3 Apr 2019 20:39:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C2FB6B026C; Wed,  3 Apr 2019 20:39:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1F2ED6B026A
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 20:39:32 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id y17so626432plr.15
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 17:39:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=wFIVtEVhrslAPc1rxJ7EFYor+Slx2eUn7DRdGymDm7Y=;
        b=NeyBaCcFTllBcLOW4xo/2c1Y7gC/j/CZ4IXwEMRV7YiGS+8rFo8mHkTFwyDLWcCe3o
         56ZOs8bYcst5+epLzEDy7MT/h0BcD3ffqoWhRsRGbRcP0fBE3UusFesyTHRA5PHiY0jX
         zlb5YelDX777J5pwhnXsQ4F8lB2/9fnh7s7DFQBQF0LFp8EVpB4FEKdUvELDTUs5kuGN
         lHMH4sq/CWkP2aLz4X0LGABUblNunNu6fWchWSp/Rfq0FBp2EuKSIRaQkqdxxdcQ2KCh
         PQWMWxHClNboXkyJJzY23gJI6YSqPHTW1Ehi4lYj6f8+B8bFIjoAmgFeuV+o8yZ7blXo
         lrFg==
X-Gm-Message-State: APjAAAUZTJghXYU5vDnLVWVfQyNV9vI4fJvkAAztGLD+KfenxkvHNX6I
	TsNK9bj8iz61747/EvPotOiQFzp7Kxe3wKoNqFX2Dsjm7vsmCO/4g+Ic85duP8Jtn8N59WzpuG0
	PRa0ZWlfsc212wPfXkPNW53XUp+kdSElquEBBtMnuSwiKL6I4jEstMBX78FxUYBT5xg==
X-Received: by 2002:a17:902:2a29:: with SMTP id i38mr3225584plb.22.1554338371666;
        Wed, 03 Apr 2019 17:39:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrfM/Nb4xOm26YnJgv7y6afusLZa2FvZGcY7BnGfsQCQzeAt8+393h++l1Y6abJeDBmYuN
X-Received: by 2002:a17:902:2a29:: with SMTP id i38mr3225502plb.22.1554338370848;
        Wed, 03 Apr 2019 17:39:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554338370; cv=none;
        d=google.com; s=arc-20160816;
        b=dPo+15Oilv0eaF1f3ghKQ9x4skshFaFZ687yuBEv86cwgyvbJkVVXMTY2dCdIfr+a8
         pFpPf0Ts5vBtlkexi3xizMYn/NAmVC84Yf68PB4OAMhTssM8UwuUxxbWHipz1MinLrwi
         vNcilzCeizI6J0C5miIzQu1liJ/ql15C3aMM+erzqVvv7gK8gE/ZsXcfVyDKTLEYIyQH
         vA0W/FO8dqmZdWV+srluBf/3D4XUpGA0F3D9V96HDwuEBbpt5bUxklnmvv3V3MKHFDB0
         XoSxsEMn210RBzUDqEOVn73pTboPrPOVsR3rxEveCDGjO8PfpiV53Zb0pxBRFGbvcDPT
         jYLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=wFIVtEVhrslAPc1rxJ7EFYor+Slx2eUn7DRdGymDm7Y=;
        b=jp/2Q4pWO6bbQj1tvOiX+6nzvGvRQ0MFoMvTNreSv8Jve0hiJpGVWhvofBPrsLykcy
         hZEaPXj6DTCn8xDV9UH522OaiKMHUj+PdZiXjcEpHlLRQ23OrC7LW+zqIaUbkZeVxj/V
         c8AQT/Dy4tL4TeIzlcXsSQZKGkr0S20NM62awMb9zuJpKRfvPX7h7vyKzAOC5sQ8CpNX
         i0b8Bi1OHOZveMl1tejl8oxJZ0JIVMjyC+d3R5Y00M2wRa2xeJqJg8+nN+97/DgDDSuJ
         90nUOqmDpWKBhnVO9OGdAo/yjW+tzWaPeoIwJf462hYuqEE9J22TgoFXKxipZQYmHCyi
         1Klg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=F2W38VBd;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s13si15209813pfe.188.2019.04.03.17.39.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Apr 2019 17:39:30 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=F2W38VBd;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=wFIVtEVhrslAPc1rxJ7EFYor+Slx2eUn7DRdGymDm7Y=; b=F2W38VBd9nCA9JmPo6hQStFS/
	fO4bIQ1TxcWdOBY2/0Xj/6NF+7giJF++5x7D5QnBTFlzj3DaIY0d7dgUSI9xFMXNdQmvrjOIGjNCF
	WpsKJrreZmJTPtBNpZk4v0kEDuesGRtmxb1kfD3vYFs/vvS7yEG6oktZRrEeCfTD8+OjELtj56sEZ
	YDAv2iFLz4kxedjnTTTMvhbKQHHsShGT75kHl4NOD1Dc0CNEBQiqQ3OF3n13uhygy4hXOqav26/us
	DXYMmDw7BDv2p66zfcsYrhZ/K4xQ+M7jm+5U22hmfgwC12opeb0RCRojGZc+lp+G2wWnHQohBJTLt
	FTTkGiw2Q==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=dragon.dunlab)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hBqPg-0001fr-HN; Thu, 04 Apr 2019 00:39:28 +0000
Subject: Re: [kbuild-all] [mmotm:master 19/222]
 arch/sh/kernel/cpu/sh2/clock-sh7619.o:undefined reference to
 `followparent_recalc'
To: Rong Chen <rong.a.chen@intel.com>, kbuild test robot <lkp@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>,
 Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org,
 Johannes Weiner <hannes@cmpxchg.org>
References: <201904031355.srXJo4hh%lkp@intel.com>
 <2af6aff3-ac3f-1d53-0d33-f81dd0dfa605@infradead.org>
 <44789370-4ca9-329f-65ad-8ff428a7e91b@intel.com>
 <38dbc113-2b1c-3fe6-ba37-36f89bbb71c4@infradead.org>
 <67b967df-e621-8370-f810-4b62b34ded16@intel.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <c6e5f5c7-ec18-8986-5796-6b573ff2e9a9@infradead.org>
Date: Wed, 3 Apr 2019 17:39:23 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <67b967df-e621-8370-f810-4b62b34ded16@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/3/19 5:20 PM, Rong Chen wrote:
> 
> On 4/3/19 10:46 PM, Randy Dunlap wrote:
>> On 4/3/19 12:09 AM, Rong Chen wrote:
>>> On 4/3/19 2:26 PM, Randy Dunlap wrote:
>>>> On 4/2/19 10:54 PM, kbuild test robot wrote:
>>>>> Hi Randy,
>>>>>
>>>>> It's probably a bug fix that unveils the link errors.
>>>>>
>>>>> tree:   git://git.cmpxchg.org/linux-mmotm.git master
>>>>> head:   03590d39c08e0f2969871a5efcf27a366c1e8c60
>>>>> commit: cffa367bb8abe4c1424e93e345c7d63844d1c5db [19/222] sh: fix multiple function definition build errors
>>>>> config: sh-allmodconfig (attached as .config)
>>>>> compiler: sh4-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
>>>>> reproduce:
>>>>>           wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>>>>>           chmod +x ~/bin/make.cross
>>>>>           git checkout cffa367bb8abe4c1424e93e345c7d63844d1c5db
>>>>>           # save the attached .config to linux build tree
>>>>>           GCC_VERSION=7.2.0 make.cross ARCH=sh
>>>>>
>>>>> All errors (new ones prefixed by >>):
>>>>>
>>>>>>> arch/sh/kernel/cpu/sh2/clock-sh7619.o:(.data+0x1c): undefined reference to `followparent_recalc'
>>>>> ---
>>>>> 0-DAY kernel test infrastructure                Open Source Technology Center
>>>>> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
>>>>>
>>>> Hi,
>>>> I suspect that it's more of an invalid .config file.
>>>> How do you generate the .config files?  or is it a defconfig?
>>> the config file was generated by "make ARCH=sh allmodconfig"
>>>
>>>
>>>> Yes, I have seen this build error, but I was able to get around it
>>>> by modifying the .config file.  That's why I suspect that it may be
>>>> an invalid .config file.
>>> Can you share the fix steps? We'll take a look at it.
>> Hi,
>>
>> For this build error:
>>>> arch/sh/kernel/cpu/sh2/clock-sh7619.o:(.data+0x1c): undefined reference to `followparent_recalc'
>> the problem is with CONFIG_COMMON_CLK.  The COMMON_CLK framework does not
>> provide this API.  However, in arch/sh/boards/Kconfig, COMMON_CLK is always
>> selected by SH_DEVICE_TREE.  By disabling SH_DEVICE_TREE, the build
>> succeeds.
> 
> Thanks for the explanation, It seems SH_DEVICE_TREE was enabled by allmodconfig.
> does it mean it's a problem of allmodconfig? we thought kernel could be built successfully.

I think that there are multiple $arch + boards/platforms that are very
board-specific where allmodconfig doesn't make sense, but that's mostly an
opinion.  I haven't tried to prove it.


-- 
~Randy

