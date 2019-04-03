Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29697C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:46:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE06620830
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:46:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="cCydogQi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE06620830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D42C6B0008; Wed,  3 Apr 2019 10:46:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 55B266B000A; Wed,  3 Apr 2019 10:46:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3FC956B000C; Wed,  3 Apr 2019 10:46:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 022B96B0008
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 10:46:22 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id y2so12513119pfl.16
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 07:46:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=9cUDFCKv8nkxnqXXlNldVxmjwYStmT4DTqy8AloTJc0=;
        b=KxfmQ86311Hg5M5RoEHghNEi1smn10rYAgpbS6jPiZsin5tKK5AWrh1tPDjzjxZ/bI
         KJSJbyWdBdWTtve6ccW4KR1cKHdk83VXYswvV0eI6yBerxeBfHWkG0geYCkIpoXIfxiU
         8dwS1QeJbRwppijN11B4MOQN6RBDbIlWJJpAKLIZQu2Yn8md8SrsCTVGUnbRnjm8P92T
         fHC4En4yB+/CNMLFSfswiyjjwbAVTLcvdxbi5sofgfkTD+VSApEqzKQRcf8uAzsBdfqA
         t7BkJje7qoxYTCn6Jq0NeNiAWqi98b/jzaJQ6zJzb/Ai+ynsjuztyf1UAmILA+MYQyfi
         4yKQ==
X-Gm-Message-State: APjAAAXkTY+BVaX2gPQ4xHzRgpA9sm7loN3Bg2mcKiHakaOmONxx18xp
	s7vDWGyAoazyFWyDoeFT67OaW5yj/L5WtEzGGKbl8ov+LFLLzKzZU3EyUHJHFJJLbq3BvunCprq
	+NlsvvbhY7tlxBE9ezbhAqtXpiuvGCtJVDHVJfSqh5ryz6GNbYzcf7zT0zjBBG3JrLA==
X-Received: by 2002:a63:525f:: with SMTP id s31mr59535pgl.172.1554302781570;
        Wed, 03 Apr 2019 07:46:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw4o225d9sEKd+cLWbXn3MBLRq1MXqEJw67fKTfWET6by0WSydOhYAL5lb1vnjV2/ZH28sD
X-Received: by 2002:a63:525f:: with SMTP id s31mr59446pgl.172.1554302780551;
        Wed, 03 Apr 2019 07:46:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554302780; cv=none;
        d=google.com; s=arc-20160816;
        b=IPIj310yMEy8e90oaLgloAssTD3RJ4WrZPbqJEcrWa7WDnPgOMbEGarkSqMbezC50Q
         GXmcTc7T54y3puZ2Kv/YN3dqORRSKhPnmGJ5oLigk1tGkE39R9t8iYp3kelr8H51kLzN
         Fsw+/yQ57EBFOJpsrbqRgYoBmZdWQZuNHixB9kh+wENQ7DM1hK7cUBvpOV2XB/itpiNc
         zYZd0F8GHS+o7wRkAFezhaeJEPv0YT4OQ0lN8i/SDZHb+C06A3ldMw54YpmHdHOD3Ft6
         Z150FJnP/GeOK1XLjIG7TVMa93xwK/nfV+GQRzaKyzqbxAXIzCU9Fj6wapbyhSRJh8Uo
         NBwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=9cUDFCKv8nkxnqXXlNldVxmjwYStmT4DTqy8AloTJc0=;
        b=jh8JI7dq/NiK+NaTR3B0IwiUXZphKJjY20Ip75Aqb0UYJWRnqfJHQ3D29ZmM+AUNxU
         WLS6Bn/KDPiUrXF/B+/KkerV6mNLUIsgOupD9+Mq9nKmAyBJel6IC6RjLsAsA6YfsV3z
         dcvZBraXh1pa9EZ+RA+d/lYy/G0c8XbiS5IAkpahW7T/cGCQqfid2LW2AFarWrTTwZTH
         9nnZiikt1u9TPacLBaMZvRwDD9RO9s+4E21DS9LhV/GEwrCWD/2O1xtvX1e2mCDbnQb3
         DuRTbFrjn9hRMc1d1xL4oiAVmyz+2yd+5EQsH5ZTv4Ez4PMhXkiLbA6s2EE7PRveWOL3
         j9vg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=cCydogQi;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f2si13549554pgi.61.2019.04.03.07.46.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Apr 2019 07:46:20 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=cCydogQi;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=9cUDFCKv8nkxnqXXlNldVxmjwYStmT4DTqy8AloTJc0=; b=cCydogQivcTjSsheqUuGx8u0n
	ch7lvDlBpD38lNsleRsC/1xH6vp6FeBEW7jpVBju5SxfghVu6s8hk73/aHMowt9jVi74S8nPBGmQU
	RidTeen6IYlh9J5M/RU6fdzmcuGz9z8lyMAfzUQQ6nUwDsjyEn9r4TU4owomdAZzH6tQyL1Rn99Cn
	ULHseu/TI/psJgCsWYJ7rTT9OFLd+Lsg4hokJXhvQylV7qet3+FnMaap5UFW9a3rlOB/nbFf+3PRP
	tBXpiWQ6tN9j6Yt6o/ODnUmRnWl5abnEuEm+zngOtcfGpP8YVKfDagpXR39VbG7PTgbGLeKisB/a2
	QFWvotPzQ==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hBh9e-0003fd-E1; Wed, 03 Apr 2019 14:46:18 +0000
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
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <38dbc113-2b1c-3fe6-ba37-36f89bbb71c4@infradead.org>
Date: Wed, 3 Apr 2019 07:46:16 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <44789370-4ca9-329f-65ad-8ff428a7e91b@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/3/19 12:09 AM, Rong Chen wrote:
> 
> On 4/3/19 2:26 PM, Randy Dunlap wrote:
>> On 4/2/19 10:54 PM, kbuild test robot wrote:
>>> Hi Randy,
>>>
>>> It's probably a bug fix that unveils the link errors.
>>>
>>> tree:   git://git.cmpxchg.org/linux-mmotm.git master
>>> head:   03590d39c08e0f2969871a5efcf27a366c1e8c60
>>> commit: cffa367bb8abe4c1424e93e345c7d63844d1c5db [19/222] sh: fix multiple function definition build errors
>>> config: sh-allmodconfig (attached as .config)
>>> compiler: sh4-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
>>> reproduce:
>>>          wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>>>          chmod +x ~/bin/make.cross
>>>          git checkout cffa367bb8abe4c1424e93e345c7d63844d1c5db
>>>          # save the attached .config to linux build tree
>>>          GCC_VERSION=7.2.0 make.cross ARCH=sh
>>>
>>> All errors (new ones prefixed by >>):
>>>
>>>>> arch/sh/kernel/cpu/sh2/clock-sh7619.o:(.data+0x1c): undefined reference to `followparent_recalc'
>>> ---
>>> 0-DAY kernel test infrastructure                Open Source Technology Center
>>> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
>>>
>> Hi,
>> I suspect that it's more of an invalid .config file.
>> How do you generate the .config files?  or is it a defconfig?
> 
> the config file was generated by "make ARCH=sh allmodconfig"
> 
> 
>>
>> Yes, I have seen this build error, but I was able to get around it
>> by modifying the .config file.  That's why I suspect that it may be
>> an invalid .config file.
> 
> Can you share the fix steps? We'll take a look at it.

Hi,

For this build error:
>> arch/sh/kernel/cpu/sh2/clock-sh7619.o:(.data+0x1c): undefined reference to `followparent_recalc'

the problem is with CONFIG_COMMON_CLK.  The COMMON_CLK framework does not
provide this API.  However, in arch/sh/boards/Kconfig, COMMON_CLK is always
selected by SH_DEVICE_TREE.  By disabling SH_DEVICE_TREE, the build
succeeds.


-- 
~Randy

