Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E81D7C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 07:09:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88F0320882
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 07:09:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88F0320882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA3D46B000A; Wed,  3 Apr 2019 03:09:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E54836B000C; Wed,  3 Apr 2019 03:09:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D443B6B000D; Wed,  3 Apr 2019 03:09:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 92E556B000A
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 03:09:04 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 4so11766711plb.5
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 00:09:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=fuK5cJAEp8LY04kAQROt8Q7d2eM3kb7fN4cNMn66WXQ=;
        b=rAw5XnxWt79/KguCiitoZfuqxlnYzoAW+17fm5O2M1rjNCHiMIIprSmhy3CHlC79HV
         Tp48LkgOl33A5pAL2vpRoQdVY7/JMR9yTjpMTiT7jdegR3C09f2fLSKzPrHiykGYm2Ai
         JpQbEhZ50Q+1sHT/2uGdu79pA/VFO5w87/42lomn2oeCWbyvalCnuChIBASw2ZDKrq32
         aWC/gwUww5DluF+i40og599f738oI54WECYaOvMhMW/C1TvZZpADEelwW7S1P2y/MTXC
         K/DN1B/UvLozFzAiLkClzquRTcphV4RrxdjmybXZgc4a6wPdRD1OXKcXkKFdSzuwl8r8
         V05A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rong.a.chen@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=rong.a.chen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWvOfafI+0wSzYtt7kSqzpA3eQlMlxTMwk3YyU5UPjmy4ctMbTt
	gr3e4MBDxoJuSD7OiOwhxt2Lz5SYjBjmtS+qhkTFVmD2HGtes2A9JJCeQr+dWGLugoPuHUKa/FO
	BsTCH6+40iW4pYRfGq0t9ov7dr1QxGyQX5N9IpcXG1yTIozXTY6dcLU88a57lZeXNrg==
X-Received: by 2002:aa7:8019:: with SMTP id j25mr74326584pfi.77.1554275343920;
        Wed, 03 Apr 2019 00:09:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwbzFKfwj5btXbkZv3j3sFiDFKFOF5dFvo1zMk1I86pIGJBePcurkHwb2RJW/Crq3mxFN3g
X-Received: by 2002:aa7:8019:: with SMTP id j25mr74326529pfi.77.1554275343097;
        Wed, 03 Apr 2019 00:09:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554275343; cv=none;
        d=google.com; s=arc-20160816;
        b=fXu2tL0fREOE4hs7d6JU68ITFxUg4NK81BrGEpiJm//UEyoGndfBHpQVGSlD3TWIeD
         lO0zRYsUlGHR2GEQQoJCgz5/b7FQu2dfOGbBua/ipu5VJHqOr6+HRE/HXaonJu/ug8tF
         AmEAikLyTNzyWWMbs7fOamnqWiwIXAdMoycpG/+AU0MsFUhvdyOLTmcA8FZEcfq1KaW2
         nFkN4DeuqbVdie9N4GNiQqpT5hfNbAfxbnkQFA63c4bEw1tTACoJAWYQ0dvm4Gx9sdHr
         H3vxcwROAuO1fedazOLDqJMcVkDNMeF12KMHdSPhsq0XlXO3A/8Ks1hfPKirmASXWc8f
         bSlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=fuK5cJAEp8LY04kAQROt8Q7d2eM3kb7fN4cNMn66WXQ=;
        b=0PuzK/cH70KbSGjkWrw+a2xfm7exqVS4YWKwhMAVyyD2tgZ4O6lCoalet+tUhB/FZO
         SOEqZ50nHGm1uPMfPa5dwtlzwvnn94GOXMxPuLDhqMF5CRBaQy5ydE4n4Auj3UbGzXTV
         6QOzlooeaKEacpPZGkNyaTmLC/E9lS4akea0K6vyR5udmtaIngt5fH8zK+TEA+ywYm0Y
         NKbXb5IBCm3Wf7UpOFgrX4a6hHYZEzhKcHD5RM0tkiGiQck4ZI0opWcPSu2B5A+zTTG2
         Td0J0mNjFTn3QUsSApRfD6vpt+5QX30NUGHwNpjCxyxa0/UwOZvhmPn3Fg0GybmGp8gw
         kM5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rong.a.chen@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=rong.a.chen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id v21si13050916plo.34.2019.04.03.00.09.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 00:09:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of rong.a.chen@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rong.a.chen@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=rong.a.chen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 03 Apr 2019 00:09:02 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,303,1549958400"; 
   d="scan'208";a="131028865"
Received: from shao2-debian.sh.intel.com (HELO [10.239.13.107]) ([10.239.13.107])
  by orsmga008.jf.intel.com with ESMTP; 03 Apr 2019 00:09:00 -0700
Subject: Re: [kbuild-all] [mmotm:master 19/222]
 arch/sh/kernel/cpu/sh2/clock-sh7619.o:undefined reference to
 `followparent_recalc'
To: Randy Dunlap <rdunlap@infradead.org>, kbuild test robot <lkp@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>,
 Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org,
 Johannes Weiner <hannes@cmpxchg.org>
References: <201904031355.srXJo4hh%lkp@intel.com>
 <2af6aff3-ac3f-1d53-0d33-f81dd0dfa605@infradead.org>
From: Rong Chen <rong.a.chen@intel.com>
Message-ID: <44789370-4ca9-329f-65ad-8ff428a7e91b@intel.com>
Date: Wed, 3 Apr 2019 15:09:25 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <2af6aff3-ac3f-1d53-0d33-f81dd0dfa605@infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 4/3/19 2:26 PM, Randy Dunlap wrote:
> On 4/2/19 10:54 PM, kbuild test robot wrote:
>> Hi Randy,
>>
>> It's probably a bug fix that unveils the link errors.
>>
>> tree:   git://git.cmpxchg.org/linux-mmotm.git master
>> head:   03590d39c08e0f2969871a5efcf27a366c1e8c60
>> commit: cffa367bb8abe4c1424e93e345c7d63844d1c5db [19/222] sh: fix multiple function definition build errors
>> config: sh-allmodconfig (attached as .config)
>> compiler: sh4-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
>> reproduce:
>>          wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>>          chmod +x ~/bin/make.cross
>>          git checkout cffa367bb8abe4c1424e93e345c7d63844d1c5db
>>          # save the attached .config to linux build tree
>>          GCC_VERSION=7.2.0 make.cross ARCH=sh
>>
>> All errors (new ones prefixed by >>):
>>
>>>> arch/sh/kernel/cpu/sh2/clock-sh7619.o:(.data+0x1c): undefined reference to `followparent_recalc'
>> ---
>> 0-DAY kernel test infrastructure                Open Source Technology Center
>> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
>>
> Hi,
> I suspect that it's more of an invalid .config file.
> How do you generate the .config files?  or is it a defconfig?

the config file was generated by "make ARCH=sh allmodconfig"


>
> Yes, I have seen this build error, but I was able to get around it
> by modifying the .config file.  That's why I suspect that it may be
> an invalid .config file.

Can you share the fix steps? We'll take a look at it.

Best Regards,
Rong Chen


>
> thanks.

