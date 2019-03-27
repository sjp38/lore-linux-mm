Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73208C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 20:42:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25D672054F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 20:42:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25D672054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD3E96B0007; Wed, 27 Mar 2019 16:42:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C81A36B0008; Wed, 27 Mar 2019 16:42:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B73026B000A; Wed, 27 Mar 2019 16:42:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7FDDF6B0007
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 16:42:53 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id j184so14793841pgd.7
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 13:42:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=Jn40aX9tTxirGNrHV4/9P2GgBwFUAwyaJN2kW6G8+kI=;
        b=V/d9kRsYZNbIBe1Yx+lJnO1j/unQHnO4NDu/ops4PvG7HRCgHWI2azwSVi1vYNL2Gg
         FP15ljw2EEp3XPuraud4gI1ojQxY1I90o4pIx9EhXnEUmm/44eFTtQx1rXPsLxgOQ6Dz
         ceSvuo9EcIR4S3rhPU/vE7nlhsRmrmjL6/QnedU1fxuctKyLnUlof0ydpUIf7jVNNif4
         aRjWUgYnFQNYekZh+B+U8C06B29N2KSozY8kJDSlx4ZVU/Rphb1zED+qyG61SRe/71t/
         BHrCT9hWelFE6nV7ZUsXLhWkUsqn8HlizQ7DKH/gQYQJS71GDwEz4rGTc/unSjDWMvZn
         I0ng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX0jMK1g9QhJL+1NrTMBKrVqmQkY6Vvh3t9z43ORzH+5K1STrFr
	Ajv5u+OYCzHXpi2shHkd16CnbV7eX74G/q/G9G+JeeVt8NS3mNCu2wxdeeYQxuom8CT+CuyX5+/
	c2mXwYYCufVAXhaBm6pRuRgONqQy6hMUjSp9zA5riz1X8hw5wAid/kfmOOW2E/7fFIA==
X-Received: by 2002:a17:902:6907:: with SMTP id j7mr37183658plk.32.1553719373221;
        Wed, 27 Mar 2019 13:42:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqykHZu7lRk54eFJW+TMjHVEiJ04IGUs5lZ2oMj4bloA45hc/q6VFS2zqgz7ige8om9CrF8G
X-Received: by 2002:a17:902:6907:: with SMTP id j7mr37183616plk.32.1553719372603;
        Wed, 27 Mar 2019 13:42:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553719372; cv=none;
        d=google.com; s=arc-20160816;
        b=VvHI4BdT+kl5vC0Eq4QCnsmuTUuvQ4JZSAF00LvbEiHFTZrgRiaNER+gXCn0/Uj3Ft
         6e+oADqbFEpog8HbMujRpZS6QO+Z4wOboXeLRLbeBo1GCCGFsX4Y49SErO2aT8hMGpkj
         PrqfqDgR8tZ+EWUt6XfOxaurAHWsr42LxOSFgZU7xwSa8Vm7L/O6VTGJaepVDU9hxao7
         Hw3gwoFhsTTE1aUAll3kXGQPAlMW9sYwOe5yPvl0TZm81sRtug8EMngi0hqOiYxgQRZs
         K9hB/3jVIwB1IqbXtgRGUqUEq6CROF9WesyCDKzv/iVBN+Ja7lIRbr4FzPrr5/nMmAUG
         K0ZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=Jn40aX9tTxirGNrHV4/9P2GgBwFUAwyaJN2kW6G8+kI=;
        b=XNuAowacR2hygEH2n10mYrKL1vLbdiLW2ldE6jG8cnuXFHVuXpHzfRWIzAzWC89N1d
         JG8cY+9plXq2A7GGfMvpqNWIuKkjPbqnhxzhw2j//Vy0PLnLYSO9h6tXQktEcE1LnD9p
         cdXeaKavmZYsb//44ATyrafKMRQTc2MlHejuaFMq/yknQ3kHYlunHR6lws7z5kPLav6m
         SBLGCdBohumNyE8JKP7eB7LP2Q0CwhdpGazioisRcc4DJ/JinON8UzxlrgYf52UfrUUP
         aifJScE1+gHBWTW4hxaXyNnsDlOiGUb3DS/iqux3B+for7t+X0761QyGjCTWp+uu5Hy5
         /Pyg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id k24si19030824pgj.228.2019.03.27.13.42.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 13:42:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 27 Mar 2019 13:42:51 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,277,1549958400"; 
   d="scan'208";a="310944366"
Received: from ray.jf.intel.com (HELO [10.7.201.126]) ([10.7.201.126])
  by orsmga005.jf.intel.com with ESMTP; 27 Mar 2019 13:42:51 -0700
Subject: Re: [PATCH 06/10] mm: vmscan: demote anon DRAM pages to PMEM node
To: Zi Yan <ziy@nvidia.com>
Cc: Keith Busch <kbusch@kernel.org>, Yang Shi <yang.shi@linux.alibaba.com>,
 mhocko@suse.com, mgorman@techsingularity.net, riel@surriel.com,
 hannes@cmpxchg.org, akpm@linux-foundation.org,
 "Busch, Keith" <keith.busch@intel.com>,
 "Williams, Dan J" <dan.j.williams@intel.com>,
 "Wu, Fengguang" <fengguang.wu@intel.com>, "Du, Fan" <fan.du@intel.com>,
 "Huang, Ying" <ying.huang@intel.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <1553316275-21985-7-git-send-email-yang.shi@linux.alibaba.com>
 <20190324222040.GE31194@localhost.localdomain>
 <ceec5604-b1df-2e14-8966-933865245f1c@linux.alibaba.com>
 <20190327003541.GE4328@localhost.localdomain>
 <39d8fb56-df60-9382-9b47-59081d823c3c@linux.alibaba.com>
 <20190327130822.GD7389@localhost.localdomain>
 <2C32F713-2156-4B58-B5C1-789C1821EBB9@nvidia.com>
 <de044f93-c4e8-8b8b-9372-e15ca74e7696@intel.com>
 <33FCCD53-4A4D-4115-9AC3-6C35A300169F@nvidia.com>
 <3fd20a95-7f2d-f395-73f6-21561eae9912@intel.com>
 <6A903D34-A293-4056-B135-6FA227DE1828@nvidia.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <c67d331a-d937-9fb8-9508-320c7cccba5f@intel.com>
Date: Wed, 27 Mar 2019 13:42:51 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <6A903D34-A293-4056-B135-6FA227DE1828@nvidia.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/27/19 1:37 PM, Zi Yan wrote:
> Actually, the migration throughput difference does not come from
> any kernel changes, it is a pure comparison between
> migrate_pages(single 4KB page) and migrate_pages(a list of 4KB
> pages). The point I wanted to make is that Yang’s approach, which
> migrates a list of pages at the end of shrink_page_list(), can
> achieve higher throughput than Keith’s approach, which migrates one
> page at a time in the while loop inside shrink_page_list().

I look forward to seeing the patches.

