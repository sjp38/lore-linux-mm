Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6DBAC43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 05:38:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 827BF20835
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 05:38:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="jX+ZXQx4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 827BF20835
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 14F6C6B0284; Tue, 30 Apr 2019 01:38:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1005A6B0286; Tue, 30 Apr 2019 01:38:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2EDE6B0287; Tue, 30 Apr 2019 01:38:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id D59126B0284
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 01:38:26 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id x23so255080ith.8
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 22:38:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=0VaZ99/42myj1FUXHKYXX+Rl3OaCNMwGJa9NC9KEQIY=;
        b=pgjz81lc+53ACIwUdLo1fa66Xp1PEyeEp6LYsFnR7DjsuaMlcItcDUwjjBdj//zONP
         eFuXoDPRsbtjnWLfmJdcc+0+s8VifVG26iwSZR/+uaxSxK6g3nbAWjvq+ViySKhX0Cu7
         vXousa/7VNugEOrYfN2qWT96ohSouy1HmisDgXLBYORBZsDvwuXXZHmpKg1UUTZoM/Qi
         kHw6n8mHy2VFSO08pe4NGicrlSKbl32v22r2ZUk7zf+X6U3J20TB65+zp0cEhTHIQtsS
         Oeww1Dwp8qOc0BpIlniFx6Q2Ra6QSWcoSUE79cOGIbDHuHIfOfHqtkbVcHN+ci06jdIK
         Xtgg==
X-Gm-Message-State: APjAAAUm6r9J8BPI0Ge7ftjYW8cqA/ncO6snp3fbf6pFHW3LIKM6AVZ1
	1oaop9GHI9NMm2Wer79GTzy8Yi7qUMCdhV54IhEuqW79WiRLCHsUy8Ye+nbC7pdtt4SkH+vN0s5
	wI/3q11X6JHSwTZZYmnMO2ig6USkpws6I1eW1DIAKLPqKrPSAKWnQ9QHQZZBXy6QOJg==
X-Received: by 2002:a5e:c804:: with SMTP id y4mr17677184iol.67.1556602706606;
        Mon, 29 Apr 2019 22:38:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqsv+PTciLZKE48AiitmxfHnU1tHI1bS9HMoQHRdv7ogZnQNCoPqi0hv2N6hJl7B9qQttj
X-Received: by 2002:a5e:c804:: with SMTP id y4mr17677159iol.67.1556602705756;
        Mon, 29 Apr 2019 22:38:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556602705; cv=none;
        d=google.com; s=arc-20160816;
        b=vjuz8e0n+7ESUQL5rwjZEZF2c5+Y7snJ2ZqbEbMfSguKI6tE4wjhC5WCko2b5mUuLw
         GErOfyOQ/uJ+xSi+pkoTfCguj4sG7a1HaSFCUEFuLjyymiXCa6/FBtCzAlCPLhTKMQpY
         UyIPFLghmbT57b/grSS5GZbK1Yl6984h3k+esx4vB6XqS9KCxb5qix1SrBmeEsSvYsle
         b1PEFqyZZTysZa7PFCHJ1E+r8uCmWE2HNr7eN3ny+S61XvcpBk8hnJh4ZtTvXeZMva0b
         L0/hdh4je6SWbThdAztOhOj6usYujjO6IOCkcrWki25GPXOSIzpBa6QBJN8O8Twifdny
         aCzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=0VaZ99/42myj1FUXHKYXX+Rl3OaCNMwGJa9NC9KEQIY=;
        b=ea3sBZ3W0KrtW2uE8UnnQjVrz2XnG5Kle+PHIYVYznYPG4IvRWINUif9JebVLrfG1/
         2rqfmNABPdY73vy9pZucf5t5CfR9N8j5D8n63IqmkCMKBsNkVZNiJAZXnbYwcond8j8u
         W34EPz3PZckxbVFnfLf/YnNKXHmP7Bf0FC6s2WA+JHUOvv3rZDLq+koTpcoC98VhAJKE
         YyH8I0vhgWDx1oN259UUCOiLgxlZj5ELNlH9UOADvagwz9ngCenf/rxAzrVhjLVTxV5c
         EwMO0Cj1JdsVCC+WRfGOUIl/L9k2cTXSh1nz0AZGaNskL3P/9slp3T0/uX6qSLmctRwA
         S8Zg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=jX+ZXQx4;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id a186si1219294itc.11.2019.04.29.22.38.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Apr 2019 22:38:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=jX+ZXQx4;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:Subject:Sender
	:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=0VaZ99/42myj1FUXHKYXX+Rl3OaCNMwGJa9NC9KEQIY=; b=jX+ZXQx4dWZoDeduDfZkC/43LY
	pnP4zwze/rk3LT9LdIFmFSdAYV2zOyHnohbIB70XW6LnH/5FPnccRkK74lJujftuXeATCYFX/d3p1
	ezFFKCmqupvSru6eiN7DnCZJ3D5EP1SnBSKUfNC5JRViDCN8ei4/DEO0Uo8Mq+NJR3mYyteYCbrN4
	iUhFUg/fR2qTSntctNJwQUsGU6GPZzt3Oj+22T5oaG3Dt2AbfeenySG2SQxHjuXHspXU67zofaduQ
	fWmsQXjuEsQz76NWb9BoQuUAPdkshZcN52oNlcpbOqq0sCD6j+9ku5j/zdN6ZJvXKpm6YdGxAOD3h
	ulnKa5Uw==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=dragon.dunlab)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hLLT5-0006Uu-WC; Tue, 30 Apr 2019 05:38:16 +0000
Subject: Re: sh4-linux-gnu-ld: arch/sh/kernel/cpu/sh2/clock-sh7619.o:undefined
 reference to `followparent_recalc'
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org,
 Andrew Morton <akpm@linux-foundation.org>,
 Linux Memory Management List <linux-mm@kvack.org>,
 Yoshinori Sato <ysato@users.sourceforge.jp>
References: <201904301231.JpYYMMcK%lkp@intel.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <f5370e99-f5a5-8296-25dd-d6685bfedfe3@infradead.org>
Date: Mon, 29 Apr 2019 22:38:14 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <201904301231.JpYYMMcK%lkp@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/29/19 9:48 PM, kbuild test robot wrote:
> Hi Randy,
> 
> It's probably a bug fix that unveils the link errors.

Yoshinori Sato (cc-ed) has a patch for this.  I guess that it's not in the arch/sh
git tree yet ???  or wherever arch/sh changes come from.



> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   83a50840e72a5a964b4704fcdc2fbb2d771015ab
> commit: acaf892ecbf5be7710ae05a61fd43c668f68ad95 sh: fix multiple function definition build errors
> date:   3 weeks ago
> config: sh-allmodconfig (attached as .config)
> compiler: sh4-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout acaf892ecbf5be7710ae05a61fd43c668f68ad95
>         # save the attached .config to linux build tree
>         GCC_VERSION=7.2.0 make.cross ARCH=sh 
> 
> If you fix the issue, kindly add following tag
> Reported-by: kbuild test robot <lkp@intel.com>
> 
> All errors (new ones prefixed by >>):
> 
>>> sh4-linux-gnu-ld: arch/sh/kernel/cpu/sh2/clock-sh7619.o:(.data+0x1c): undefined reference to `followparent_recalc'
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> 


-- 
~Randy

