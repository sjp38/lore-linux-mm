Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C4C0C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 08:01:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5850A21743
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 08:01:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5850A21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E29046B0006; Tue, 21 May 2019 04:01:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD9566B0007; Tue, 21 May 2019 04:01:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC7676B0008; Tue, 21 May 2019 04:01:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 968D16B0006
	for <linux-mm@kvack.org>; Tue, 21 May 2019 04:01:06 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i8so11810962pfo.21
        for <linux-mm@kvack.org>; Tue, 21 May 2019 01:01:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zDwQ1AGNT9sMrdu8PsfhUAsGIv/+5/rOm5HEectKloo=;
        b=s9Pno6hYi3Wl6jLPXqIq7AGM1P+e9PCvIYI0YPYW5KaWjOea6LTfNpJpdGX08wrNPv
         8pK0KmrNaeOJMzRd5ovcLj8Aui8BzRGzLpM+UbHni6ePzpgPkYCUazRxO3ZE3YQ6eA5Q
         ZBG+HHTjnvpii35i5AXRH1NyxdzNWT1McWTqCVmaN9TN/tDHReCb/uSkV5uAAArkQKYD
         83Nn64V2+tfwzyYpezP+cieJI3hwk2wHFqIrCfqJPTrAFfNZj+3WXJazIRRa98iNJnJQ
         nKTIJffTGAkMF3xyjbcKkzLOMMcICkphF1LoKXdj29aJenlNPI2wEfd+RXkohq0xz0LY
         Q0Lg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWZKW1pCwtorK+fekIJl9TpblNfm3yfQCeVxiKER555Vsv+uNQN
	885K5Jxxmd1VzyTO4bF6LmFM+aYZS/XcG84G5AMKjQ15c7gGHCrFU2IX7H0l5K8uKRAf1fwZ4sn
	IdkjLiRAbM8uS7e2Emf3y+F1T62p0AuiGgnuegA0ll7uGnSXDGdJAtQ99V6JpH/FiZg==
X-Received: by 2002:a17:902:4481:: with SMTP id l1mr67660351pld.121.1558425666171;
        Tue, 21 May 2019 01:01:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyleEwvg45UNI9ZDcwjPQWpz0iSjRVu/wkr2FH0Bwm62tzjxseF7UGMDSVAREuQ+QGj6BdT
X-Received: by 2002:a17:902:4481:: with SMTP id l1mr67660226pld.121.1558425664913;
        Tue, 21 May 2019 01:01:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558425664; cv=none;
        d=google.com; s=arc-20160816;
        b=RGye7Xx00xm2CIy+p/GpLRBED7ijWib0U+vJkWRTFzwG4pCrWGkv6J6Ba26ZCOyRnn
         krynbcWu7q/xKwUVey0kCgQR6r0VrbOv4kLPK6a2CRyYSubzMkSOCjRzx2SOMOoZ66pU
         cD9H+wiPHObW8x36I7XiLVMW5ScnCZvPLqR8jckCXpJcwGoYsB8Pj6wmDIdQ15bGIrB7
         Aa7bWDzlKVKdQYrTN/grJWHzUN8fa6Tfbd6fPe7IUm+NwRRQudtK11cppC2RvEFT916i
         itvBXhYMbirvMsq4KTOpY61+o0CCugEsHPOcTZ9aXt6nNJ2NBDS0ssAdoWFAi4Y4vUy+
         WWqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zDwQ1AGNT9sMrdu8PsfhUAsGIv/+5/rOm5HEectKloo=;
        b=Fob2u8qaGNsLjphKUb7kGHr+M2GFiO6CXTGxNiC98XdL0tsXEQDDbXp3BjK2/MuZx5
         GiDjbU5w6AGsflz7HB0DqUWGYm8UqEDGO6gJt/U0pG8HKn4ZgD0Oo7NmVW9AZF8l3pXd
         Ya/T6N2qdNX3WUEUJ/e4ZdsDC0VNU9vMT+F0B1U/P1eduxqpaSEWfGxL4NTbFrg09mD2
         2B1Ugd/u9lujlmWkVEql/xMHIddoj59cGGfLmOBcwnLDN9zrX+tQlV4Q4HkPzMRf3BG2
         Z/OfL7tEOjTLE0Y0L6PuPJlPINhqS1rj6GWBDXsUgWvkdW6RPkqH80ooR0mEXi0xozCT
         wqkA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id c72si21789379pfb.93.2019.05.21.01.01.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 01:01:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 May 2019 01:00:59 -0700
X-ExtLoop1: 1
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga002.jf.intel.com with ESMTP; 21 May 2019 01:00:56 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1hSzhg-0004xJ-9C; Tue, 21 May 2019 16:00:56 +0800
Date: Tue, 21 May 2019 16:00:10 +0800
From: kbuild test robot <lkp@intel.com>
To: Nicolas Boichat <drinkcat@chromium.org>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	Nicolas Boichat <drinkcat@chromium.org>,
	Michal Hocko <mhocko@suse.com>, Joe Perches <joe@perches.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org,
	Akinobu Mita <akinobu.mita@gmail.com>,
	Pekka Enberg <penberg@kernel.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/failslab: By default, do not fail allocations with
 direct reclaim only
Message-ID: <201905211524.RpQYbGWw%lkp@intel.com>
References: <20190520044951.248096-1-drinkcat@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190520044951.248096-1-drinkcat@chromium.org>
X-Patchwork-Hint: ignore
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Nicolas,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on linus/master]
[also build test WARNING on v5.2-rc1 next-20190520]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Nicolas-Boichat/mm-failslab-By-default-do-not-fail-allocations-with-direct-reclaim-only/20190521-045221
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF='-fdiagnostic-prefix -D__CHECK_ENDIAN__'

If you fix the issue, kindly add following tag
Reported-by: kbuild test robot <lkp@intel.com>


sparse warnings: (new ones prefixed by >>)

>> mm/failslab.c:27:26: sparse: sparse: restricted gfp_t degrades to integer

vim +27 mm/failslab.c

    16	
    17	bool __should_failslab(struct kmem_cache *s, gfp_t gfpflags)
    18	{
    19		/* No fault-injection for bootstrap cache */
    20		if (unlikely(s == kmem_cache))
    21			return false;
    22	
    23		if (gfpflags & __GFP_NOFAIL)
    24			return false;
    25	
    26		if (failslab.ignore_gfp_reclaim &&
  > 27				(gfpflags & ___GFP_DIRECT_RECLAIM))
    28			return false;
    29	
    30		if (failslab.cache_filter && !(s->flags & SLAB_FAILSLAB))
    31			return false;
    32	
    33		return should_fail(&failslab.attr, s->object_size);
    34	}
    35	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

