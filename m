Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32812C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 00:20:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE06B2082E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 00:20:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE06B2082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5ACAA6B026A; Wed,  3 Apr 2019 20:20:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 55A936B026B; Wed,  3 Apr 2019 20:20:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 470A46B026C; Wed,  3 Apr 2019 20:20:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 112436B026A
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 20:20:33 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id u2so334722pgi.10
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 17:20:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=AOaEOitme9ywj0QQnIu5vozxcdYCpOSe8o99GUOHKws=;
        b=EdJyhA1QlOwdAzOzF7mSeoNEucbm/uHI//BC3z9QGTAfUs25gNQ/yHI+WF6dcCmTKw
         kcMGg37UccxE+hjXOO/5iv3kOGl2RC3rqNKYfU6Ep8BgMMrbTmcILooV13gkS1FNfWHL
         Va68L9iV53ovV2J6URAoMtW3krmfZhnHfQXxaLaQvWicYaO98NeJ4+TA74FtlIq1rxMo
         1ZA0Dd9UsqqDPuPw41mEPa+tRXrS+kLFbkJgnRj+5hsN2et/GulsGs6ovfisCmOtdGrL
         F+nnO2/zY6FCo6VaLoWNeqC+y4b8y+aaRgJrcd9P2bWGweUfypFibU/RT7JF1LRDHURY
         YJyQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rong.a.chen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rong.a.chen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUhRp5BP0aVSZ1KtPX5gHeih/+lKnDqKWoPJWHzd20oOT65Cjh5
	Th2u7K9AKFJmUQPyjhSRb2AxmHkKIw7BhIWw6J1pIXueMBTPneIGqAKbWoWWaltgRM2p0jqx1N+
	dtIYzGLyQjrdnB6f2g1HSAPHaF/db1+gtU5FoykFZ5B2x0Fb4iEMiAnalFVXmHTV6EA==
X-Received: by 2002:a63:9a4a:: with SMTP id e10mr2634314pgo.366.1554337232592;
        Wed, 03 Apr 2019 17:20:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwR2vCpiIzD9VE+3GRARMXu6U69ayFHHpv0kZ/3UL7aWhQaBT4/GX744r2h3XR+mgXBEdXS
X-Received: by 2002:a63:9a4a:: with SMTP id e10mr2634256pgo.366.1554337231741;
        Wed, 03 Apr 2019 17:20:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554337231; cv=none;
        d=google.com; s=arc-20160816;
        b=QMfGFD85M3bwQM6b81Z3iSwxeOIAjqmp0/dxubklhW4dWd+Usf5JtrZAMXQJX5V7Dh
         qeuTzWA1LQrMYUyJX4yGB25rNFMt5baql2vrsgFtNwgXDBG919ZcQ4AjIuiwQv5TEMT9
         MVSnJ4fcZoIqUX6gAZ9r0eya8J/BANWfcUQgt8QqAo7UT53M0sZCejgHYzfhOns7BQmf
         TG7ENyjYih13TwBs8Gba4vty5LqdNAbPgWIzUN6Jpb/O2EmA59xHXNE3Yl7Vmmsq1rzz
         zmPnexjwd8wfbldl8A7+eKNKALjVJnGq3lNwEOqe822x5peXWeMhF+gtYHxQyKWjC/eJ
         JLEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=AOaEOitme9ywj0QQnIu5vozxcdYCpOSe8o99GUOHKws=;
        b=VjjTFoQaJZ7T0Rl9roMKZ2KeP84ds8Y/XzmVCFagWQUfug5phGUbsvHI7+wjxzZxKQ
         UQ9xJ7unlBLXQnalHgiyGxY2ZSVwHsASPn6ch3LkoXXxd7jEVDXEK0f5bkO1zpg8o0tj
         8IJOXPIBJtCePgoDlemz9vqfTM+8mFNygMTEShk5GgnOUmFQQtHZHk6gPbY8WWVbO8yC
         H6Kx84xBa13wyQiDSpQGwbYPg50f6ya0TDz96HF8ftUbFiRRPz1btqmGErBwvJCizkfz
         7IoA6bNPCQVt6mgTt5sFdc4M0BkUT2kbdrmw/de25ko+l6GjuOvUAwykV2XFi5Segn25
         i05g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rong.a.chen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rong.a.chen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id j62si564722pgd.87.2019.04.03.17.20.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 17:20:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of rong.a.chen@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rong.a.chen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rong.a.chen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 03 Apr 2019 17:20:31 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,306,1549958400"; 
   d="scan'208";a="131276232"
Received: from shao2-debian.sh.intel.com (HELO [10.239.13.107]) ([10.239.13.107])
  by orsmga008.jf.intel.com with ESMTP; 03 Apr 2019 17:20:29 -0700
Subject: Re: [kbuild-all] [mmotm:master 19/222]
 arch/sh/kernel/cpu/sh2/clock-sh7619.o:undefined reference to
 `followparent_recalc'
To: Randy Dunlap <rdunlap@infradead.org>, kbuild test robot <lkp@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>,
 Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org,
 Johannes Weiner <hannes@cmpxchg.org>
References: <201904031355.srXJo4hh%lkp@intel.com>
 <2af6aff3-ac3f-1d53-0d33-f81dd0dfa605@infradead.org>
 <44789370-4ca9-329f-65ad-8ff428a7e91b@intel.com>
 <38dbc113-2b1c-3fe6-ba37-36f89bbb71c4@infradead.org>
From: Rong Chen <rong.a.chen@intel.com>
Message-ID: <67b967df-e621-8370-f810-4b62b34ded16@intel.com>
Date: Thu, 4 Apr 2019 08:20:54 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <38dbc113-2b1c-3fe6-ba37-36f89bbb71c4@infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 4/3/19 10:46 PM, Randy Dunlap wrote:
> On 4/3/19 12:09 AM, Rong Chen wrote:
>> On 4/3/19 2:26 PM, Randy Dunlap wrote:
>>> On 4/2/19 10:54 PM, kbuild test robot wrote:
>>>> Hi Randy,
>>>>
>>>> It's probably a bug fix that unveils the link errors.
>>>>
>>>> tree:   git://git.cmpxchg.org/linux-mmotm.git master
>>>> head:   03590d39c08e0f2969871a5efcf27a366c1e8c60
>>>> commit: cffa367bb8abe4c1424e93e345c7d63844d1c5db [19/222] sh: fix multiple function definition build errors
>>>> config: sh-allmodconfig (attached as .config)
>>>> compiler: sh4-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
>>>> reproduce:
>>>>           wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>>>>           chmod +x ~/bin/make.cross
>>>>           git checkout cffa367bb8abe4c1424e93e345c7d63844d1c5db
>>>>           # save the attached .config to linux build tree
>>>>           GCC_VERSION=7.2.0 make.cross ARCH=sh
>>>>
>>>> All errors (new ones prefixed by >>):
>>>>
>>>>>> arch/sh/kernel/cpu/sh2/clock-sh7619.o:(.data+0x1c): undefined reference to `followparent_recalc'
>>>> ---
>>>> 0-DAY kernel test infrastructure                Open Source Technology Center
>>>> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
>>>>
>>> Hi,
>>> I suspect that it's more of an invalid .config file.
>>> How do you generate the .config files?  or is it a defconfig?
>> the config file was generated by "make ARCH=sh allmodconfig"
>>
>>
>>> Yes, I have seen this build error, but I was able to get around it
>>> by modifying the .config file.  That's why I suspect that it may be
>>> an invalid .config file.
>> Can you share the fix steps? We'll take a look at it.
> Hi,
>
> For this build error:
>>> arch/sh/kernel/cpu/sh2/clock-sh7619.o:(.data+0x1c): undefined reference to `followparent_recalc'
> the problem is with CONFIG_COMMON_CLK.  The COMMON_CLK framework does not
> provide this API.  However, in arch/sh/boards/Kconfig, COMMON_CLK is always
> selected by SH_DEVICE_TREE.  By disabling SH_DEVICE_TREE, the build
> succeeds.

Thanks for the explanation, It seems SH_DEVICE_TREE was enabled by 
allmodconfig.
does it mean it's a problem of allmodconfig? we thought kernel could be 
built successfully.

Best Regards,
Rong Chen


>
>

