Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22499C282DA
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 22:13:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3BB220854
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 22:13:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3BB220854
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 576FF6B0003; Mon, 15 Apr 2019 18:13:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 525166B0006; Mon, 15 Apr 2019 18:13:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3EDF96B0007; Mon, 15 Apr 2019 18:13:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 070EE6B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 18:13:06 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id p11so12111573plr.3
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 15:13:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=4ZfTjOkD7wTMuhEhFefxjBfdSCocPuylh3xV3xsWVRY=;
        b=mQQe1Q9t2zQ0fodMGmPjhB7J4D0szHU9XFn7j22+YCAHVavDaWyIHSnGJ5g2/kUx8z
         JFCJp2MS9USGwCfroV7iNDi/iuHvlnK/2kCOT1byE8byUKdh4jyjezQabTP7zWTsMx8L
         mntOhN8oDodYWpeJHICUukGl4MBr2BqLe9s1Wb7ySYSKeYORSFhLjrD9Y2jhiVMiXTR4
         J8FYPL3KSQesldsFnm56/wjgu43YitOrYmENfMkvRBHV2sAxiX5w6fWo3Xp+rFsvBnI1
         MSaDjhS5DEd8TKgSMYsppJu2fbIJcMtm519ZirGCzp8blacbPsVBs95gEFjNQiM0lsOZ
         jAiw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVtGX6O/q9aawc/kfqo3rJejIFhVvgVeqSNIfwpmHkSzH9kIbfG
	ovM6QIlAhvLYxtsUw4QTrr2zKyhAEKKWShkxPf4X0NhxPiv0KIqMW0vxvNafWX68HVOv426PXQk
	Xygwc6Ogra5eRm1J4ZgiHvy3pmspPM5VSSUXgQyZVIxckWmacf4Q1VJzEwthOHGddkQ==
X-Received: by 2002:a17:902:e110:: with SMTP id cc16mr78663663plb.147.1555366385721;
        Mon, 15 Apr 2019 15:13:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwYAuOvb2KDd8FOfvqbzsSpO0rT8fIkG7TOkKan+Wg0SPgO5F6Xvuiz8DXxhtFhcDU06UbH
X-Received: by 2002:a17:902:e110:: with SMTP id cc16mr78663604plb.147.1555366385083;
        Mon, 15 Apr 2019 15:13:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555366385; cv=none;
        d=google.com; s=arc-20160816;
        b=dEQxVlTBFeM916VP0Ffb0W9OIcvBdFUjD8j41vb0uZ7/t7gaMaQEt7kvsyoTjlCCR2
         Y/g0UK9vlTopw13BEWjtly+ecEKcsmT0KscecJdXnlTqX0xTyLn6xG6s20lmlMKn4rUP
         QIlLYK9eCgjQuRaoXZ8U+HSJ3gfTEf338P9tp6dOEgOzQKRToroORejZ5kgf8VOEJTax
         lJdGsBRB9KoZE72fhjv4O8mMGlgWTBqcATNw5AVm85JLPY1B4ybr6l6hhD2TALRtBflh
         eDOB1tyx2u09LUtnQWptcnEGFyaCC7+ie/RvgrgyXa0bkb0G6oA02nQZtbETLgVfLbOL
         BcVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=4ZfTjOkD7wTMuhEhFefxjBfdSCocPuylh3xV3xsWVRY=;
        b=gsYk0covdGq3hOvdavIhGFgiZkZ7rT8u9SL4JTSIabRpdQMkftlyy1eLZj8CuYdlZ2
         ytNmI3fljkaaLB56MLbViE/IPG959+5y9FoMW2+jc33z+Re3F/w1PqPHiSlLTxBevBMl
         b0rFHfMAOPzxLMddKKAXXbSAlfcgLXLXoRiPY12iBraWer2cQtfPCY94vRmHYg9BOLqi
         uV8BvV08kqYVZkUiDhbJBMC1jKNxoOJikzZmrohyi9/QOjw/miNA0sfZAF3NHtfKvkvX
         IlidZHDlrqSZwPHIXpG3JtA1GltENB3DwBaO7gnsoYkkaUFGCMzLpTf1oB3QqLemGsD5
         t/QQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id r11si41285692pgm.353.2019.04.15.15.13.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 15:13:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 15 Apr 2019 15:13:04 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,355,1549958400"; 
   d="scan'208";a="223807253"
Received: from ray.jf.intel.com (HELO [10.7.201.126]) ([10.7.201.126])
  by orsmga001.jf.intel.com with ESMTP; 15 Apr 2019 15:13:03 -0700
Subject: Re: [v2 PATCH 7/9] mm: vmscan: check if the demote target node is
 contended or not
To: Yang Shi <yang.shi@linux.alibaba.com>, mhocko@suse.com,
 mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
 akpm@linux-foundation.org, keith.busch@intel.com, dan.j.williams@intel.com,
 fengguang.wu@intel.com, fan.du@intel.com, ying.huang@intel.com,
 ziy@nvidia.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <1554955019-29472-8-git-send-email-yang.shi@linux.alibaba.com>
 <6d40d60e-dde4-7d70-c7a8-1a444c70c3ff@intel.com>
 <5082655c-6a24-a3d7-1b7d-bb256597890c@linux.alibaba.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <9bcf765c-c051-9086-b3fe-679adbe239cb@intel.com>
Date: Mon, 15 Apr 2019 15:13:03 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <5082655c-6a24-a3d7-1b7d-bb256597890c@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/15/19 3:06 PM, Yang Shi wrote:
>>>
>> This seems like an actively bad idea to me.
>>
>> Why do we need an *active* note to say the node is contended?  Why isn't
>> just getting a failure back from migrate_pages() enough?  Have you
>> observed this in practice?
> 
> The flag will be used to check if the target node is contended or not
> before moving the page into the demotion list. If the target node is
> contended (i.e. GFP_NOWAIT would likely fail), the page reclaim code
> even won't scan anonymous page list on swapless system.

That seems like the actual problem that needs to get fixed.

On systems where we have demotions available, perhaps we need to start
scanning anonymous pages again, at least for zones where we *can* demote
from them.

