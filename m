Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2AB0EC28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 14:43:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3F1D25B49
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 14:43:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="fwQIgc/f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3F1D25B49
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 86D986B026E; Thu, 30 May 2019 10:43:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F6C86B026F; Thu, 30 May 2019 10:43:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 670B16B0270; Thu, 30 May 2019 10:43:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 286486B026E
	for <linux-mm@kvack.org>; Thu, 30 May 2019 10:43:25 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id o12so4057671pll.17
        for <linux-mm@kvack.org>; Thu, 30 May 2019 07:43:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=rgEoTv+ob3nuU0s1PzvAuS7/7JlQcVGSqkG2dHU05po=;
        b=N5yvTvkFvw7kefs+3dnUthHYCobxOPemLzFTiNWtxpK3bDqSUDTGhX2ERwR/+SAwhS
         hrWJLF3jGvt9XNKNDXErycgEjESfrpoHMgj9oiI9f67mMohLrkOkWxUdQqdV7rhLOrZ5
         R7gRlZ3KPp2TQgj15zPAqLk5tbuVZ+OFfCJyDxn0vhuzHhMUryCYopZg4+0Q2EzZO/ZN
         SsP8cLtAC+4+G12tSX/JCaJJrxJtpKDrjaF5GGeWk4EXTMtXyadUrHQwnoVpG58IaOCf
         nsvXVTAmvKF5m+edf5zUBl9bIdgHUSkkqExKOUG2VyDeeyrZkkF8UI6HHGYMd2KFhmu8
         dR7w==
X-Gm-Message-State: APjAAAUEwvUA2TyAHq/e1SNf9GnYnOp/+ttjIyDf5aOu0yUQOxjHo6PU
	YNeBbQncodC1h02YT7tU7YS+ST1e9T3T12fJdX+pAc/uibeCjX9lh/jhScPvrrpURlZL7mWkVcu
	V9r3eEXxsmEGGhH3RlxnSG15eJjf1r9UMjT2RGa7avyBQ/nGx0AStq+HoPVuLldEIcA==
X-Received: by 2002:a62:2506:: with SMTP id l6mr4069555pfl.250.1559227404728;
        Thu, 30 May 2019 07:43:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwG9sPvlx5DsDsGZCsl+k4cyIM10m/vnfPje0l7eWjFdZYsTEOmPE/dw71BhSDFdZefvb6s
X-Received: by 2002:a62:2506:: with SMTP id l6mr4069499pfl.250.1559227404089;
        Thu, 30 May 2019 07:43:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559227404; cv=none;
        d=google.com; s=arc-20160816;
        b=yTojUXN5Nxs4TS20X18OJgalLMS0GWRwD+o7NjY+YurBSHXpZc1KvQEzZH54pv90wF
         JniTmnQfQIb326ghrIkv0eq9Zx+SApEnUQTUxy4rq153+z9tbLa4VgSoMFlf6OwmQJF0
         oKkn8ZLUrLVfNVrqgZaQeg4rkL6EDmlN5Pi12iLijP2+u28uYcjx9NpxPBzjCB0qHF/A
         5sVJ2zlZCpryelEqBFF+LmydrXxSNxFwrLJRImpKwQ9OQ1+eH0CopCQh470tiWRPJUnb
         3zxD9GnLKaQ5IWyKSp8WD9LEKS4o/QjDjezg5eCxovAm1QacnewHW859BDjzDnhCCiYQ
         3Bbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=rgEoTv+ob3nuU0s1PzvAuS7/7JlQcVGSqkG2dHU05po=;
        b=aES0VFZElN4kZBx3Fm0cTE9lvG6IlRz3J6eYYUJnBd5Ggg27kt1nnm8cp3bV8PqTXD
         Uw4VI+v/OFJDXAxWxkH+o7CC/IxTXg0ypejIayXf7AzdSrPJnng5L6n/yuXdlI3S0W71
         zcwC9GQj7XpP1TNMEwHwnI5qzcExZV67QBWqHS8rdNaPWu6ovxlJFgYKCdW2O0Za/6QT
         NLS6MIOcq0M7O8U1qB4qih1KggatQyV24/UPJiRax2Y7HQzzZlxjayHsi/bgoLy8Yxuz
         d1PVeLz47btLyGVfpcsjtNxFqx/Pl16k71Lg8FskEskkhSFoeswBRIt4XNsu9fuBWpjj
         QHsw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="fwQIgc/f";
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m11si3201019pjq.80.2019.05.30.07.43.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 30 May 2019 07:43:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="fwQIgc/f";
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=rgEoTv+ob3nuU0s1PzvAuS7/7JlQcVGSqkG2dHU05po=; b=fwQIgc/fkWXGK3UVvCSHkPNJy
	PDMw24C005vjS+rBEMLkWWHMb8/n5G5c4z7SOgvzYLDesczvTnSWIH9VMcmLmuhrOfaHFs19wJ5/r
	ViAyGkDpWs6UUr5G0T30QH8zCjlQEgl3pzo+jfMOQcj2mRHFY0wNDAVYs/eOxWuvpfwrls+XTJvvh
	F9onf0NqibALS9NgZYhCS9UvDz380yzI2zIVtEv144yfuymb+idvVL5HxXI25VIPhmMNe6tMI02Px
	AMr74BHFPY9bFN/g5Uu4jBP5Ww+YlEcFrvUJ8t/WQAqe26NTYendgBCqJddsbQInxkaxUeRWL4akL
	8K28/dX4w==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hWMGw-0007Cm-2t; Thu, 30 May 2019 14:43:14 +0000
Subject: Re: [linux-stable-rc:linux-5.0.y 1434/2350]
 arch/sh/kernel/cpu/sh2/clock-sh7619.o:undefined reference to
 `followparent_recalc'
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Linux Memory Management List <linux-mm@kvack.org>,
 "Sasha Levin (Microsoft)" <sashal@kernel.org>,
 Stephen Rothwell <sfr@canb.auug.org.au>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 linux-sh@vger.kernel.org
References: <201905301509.9Hu4aGF1%lkp@intel.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <92c0e331-9910-82e9-86de-67f593ef4e5d@infradead.org>
Date: Thu, 30 May 2019 07:43:10 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <201905301509.9Hu4aGF1%lkp@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/30/19 12:31 AM, kbuild test robot wrote:
> Hi Randy,
> 
> It's probably a bug fix that unveils the link errors.
> 
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable-rc.git linux-5.0.y
> head:   8c963c3dcbdec7b2a1fd90044f23bc8124848381
> commit: b174065805b55300d9d4e6ae6865c7b0838cc0f4 [1434/2350] sh: fix multiple function definition build errors
> config: sh-allmodconfig (attached as .config)
> compiler: sh4-linux-gcc (GCC) 7.4.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout b174065805b55300d9d4e6ae6865c7b0838cc0f4
>         # save the attached .config to linux build tree
>         GCC_VERSION=7.4.0 make.cross ARCH=sh 
> 
> If you fix the issue, kindly add following tag
> Reported-by: kbuild test robot <lkp@intel.com>
> 
> All errors (new ones prefixed by >>):
> 
>>> arch/sh/kernel/cpu/sh2/clock-sh7619.o:(.data+0x1c): undefined reference to `followparent_recalc'
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation


The maintainer posted a patch for this but AFAIK it is not merged anywhere.

https://marc.info/?l=linux-sh&m=155585522728632&w=2


-- 
~Randy

