Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E9F7C10F0C
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 20:56:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66449206C0
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 20:56:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66449206C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC78E6B000C; Thu,  4 Apr 2019 16:56:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D76E06B000D; Thu,  4 Apr 2019 16:56:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C676B6B000E; Thu,  4 Apr 2019 16:56:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 908856B000C
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 16:56:52 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id v76so2540084pfa.18
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 13:56:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ePSxE/LR+grC3Zuvu+LBwJf0bOHB5tOoWr9SqTY+k18=;
        b=gXC3ntwrM5fDJPKVgMaWwNrlpldiHT3nKINiiMTUbwR2RyJzDEKdhx8V/NIZ/te2Et
         S39fNL/mi7NYc00UTRrYkd8o3migQC//U9HHw9JtWzkaxAcnx6qLaUy/4vVNlKU/blxP
         j9T3qYMfcQG2s4rrVqY/BaGk0cMmUa3JRnPYyX0ZkNymMbctkZ1CNpQOvTaBsrkvL5Rh
         hFkJ4eF9aHlMSa9oXEmTA8yiXWdEAC18edL4GaQfpV2vvYoNmEc/BaihKmD6SWl7Hx1v
         /WM+QVE+St+VtXVBe6oPLFzwUf2iBRkxOIquTfEIutNW4TOa/8knxGdmlKgeYytgCi0F
         /tbg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 192.55.52.93 as permitted sender) smtp.mailfrom=kbusch@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVEZH2xs+JRNm0JO9AGwAW1msTLzTXjBvy9IbJvz6EnK6WM4NjO
	umCyICstz2cngqoveFmnjko0IYBVw8G0toP2VGviP4SeQX98zIzaqj0R37q385lexhUYoXeCGLH
	mAE8ggLkwJ9QLaVZkzlAXx9H6Wpde63F1NnDcPWIvUjgIlV7T7rcAq9TZLsS4tcs=
X-Received: by 2002:a17:902:8bc3:: with SMTP id r3mr8848526plo.53.1554411412046;
        Thu, 04 Apr 2019 13:56:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJmFUknrS6RPAWNQ9uqxtXOdMj7/dpvuScmWXNQ9HWMOZwnRf5b2y3egEgl+a40b0nanLJ
X-Received: by 2002:a17:902:8bc3:: with SMTP id r3mr8848461plo.53.1554411411072;
        Thu, 04 Apr 2019 13:56:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554411411; cv=none;
        d=google.com; s=arc-20160816;
        b=Uo6fkPkWX8IJee/jc37SJjXT0LACRXGgBq8jEbe84RBhIZhO7TM3h+VK9DJs+gnUfj
         dnKWFf0ybZeXMYl7bZe+0hVWcB+tPud0SxF6LtGJxq6mxl9jHFg548NRDX6514DI28eo
         a/Db83mNo6XM4Gbf/2NhByJGpCsMNH6tFkqcIIamjTh5MKf7OK/GN61hW6J4VHi+Og1I
         9Bwx3x6c3QlJaeegCK+rG9hc2UrdjB09h90gd+tq1f7wlJ2CmtZy9RjYTvIBESUTsEuJ
         t/Di4OxIMPpRd1gtK48K6h4pF+SmFrsZJ3ekLmCiPE5R9+qQK6ZUMcjfluK9hIslh0VG
         LjoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ePSxE/LR+grC3Zuvu+LBwJf0bOHB5tOoWr9SqTY+k18=;
        b=i0M3ZAmge/NTd6zEB3PgaoVvU57LXlQvoL3tpoKF8xKngsDb6DG075w6dLXAdhZLWk
         U3Vip4qRjL9kzMCwvNZW36j3oUbPtxaoFPt68nJAompBEwO4v0u8MGXgwiv+kW9Xgb70
         jruuDI/yzyeSxNgCm+Sik/OauDIUgO3AUuVWits+ZkwlDqroNEloqxtJ3YKY7Qx11fip
         e6zqOM/rgUXCas5968FGuEN48pYBs9LPL/u9ZypgFTd5xoecgxzRTa4vUJCLYOUNR6iV
         WL4gMuf6gTXNfXrzNcKpU9Rsl+VYrzSGiQGm9Htogaj8ztYlhXVEuLRmARMmdN+R3Ys2
         q8bw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 192.55.52.93 as permitted sender) smtp.mailfrom=kbusch@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id h17si17644801pfj.38.2019.04.04.13.56.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 13:56:51 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 192.55.52.93 as permitted sender) smtp.mailfrom=kbusch@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Apr 2019 13:56:50 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,309,1549958400"; 
   d="scan'208";a="335083553"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by fmsmga005.fm.intel.com with ESMTP; 04 Apr 2019 13:56:49 -0700
Date: Thu, 4 Apr 2019 14:58:18 -0600
From: Keith Busch <kbusch@kernel.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Len Brown <lenb@kernel.org>, Keith Busch <keith.busch@intel.com>,
	Jonathan Cameron <Jonathan.Cameron@huawei.com>,
	vishal.l.verma@intel.com, x86@kernel.org, linux-mm@kvack.org,
	linux-nvdimm@lists.01.org
Subject: Re: [RFC PATCH 3/5] acpi/hmat: Track target address ranges
Message-ID: <20190404205818.GC24499@localhost.localdomain>
References: <155440490809.3190322.15060922240602775809.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155440492414.3190322.12683374224345847860.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155440492414.3190322.12683374224345847860.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 04, 2019 at 12:08:44PM -0700, Dan Williams wrote:
> As of ACPI 6.3 the HMAT no longer advertises the physical memory address
> range for its entries. Instead, the expectation is the corresponding
> entry in the SRAT is looked up by the target proximity domain.
> 
> Given there may be multiple distinct address ranges that share the same
> performance profile (sparse address space), find_mem_target() is updated
> to also consider the start address of the memory range. Target property
> updates are also adjusted to loop over all possible 'struct target'
> instances that may share the same proximity domain identification.

Since this may allocate multiple targets with the same PXM,
hmat_register_targets() will attempt to register the same node multiple
times.

Would it make sense if the existing struct memory_target adds a resource
list that we can append to as we parse SRAT? That way we have one target
per memory node, and also track the ranges.

