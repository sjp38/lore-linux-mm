Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10825C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 17:50:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D37AE218A1
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 17:50:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D37AE218A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 618FD6B0299; Fri, 15 Mar 2019 13:50:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5EFB36B029A; Fri, 15 Mar 2019 13:50:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E2236B029B; Fri, 15 Mar 2019 13:50:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0DF456B0299
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 13:50:15 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id f12so10893284pgs.2
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 10:50:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=A5xhj2FEytWRKHeyYO2csICL/EL3s1rTh/48RKr6pRk=;
        b=i1GtL6q1XW9nygmG3Gpi6yRMh8vFE2wsSmicGACN49kudDvGTBMIGf+61rIVgojSM6
         FooaXIhg7E190HTbw2fM30tW77Dj+ulPZe/AT/qDdSqZIrTI/VWiIgEoWkIG9elxJNwr
         MkcrogYwJdcHENJ/hdFMCz1JXRP463tJALtdE4hkI+Rz/BLsj87u2KdPTaFlTvJfT3HB
         CfnTMReN1YkvjKWrgeNR6uz1thEybfoJHukMUxjV0xx0tl/+ORIvwb65xx9tGgr6kIit
         QNYqCsVjbt+QPbsLQKaNK9wcmeMrqPkb9LCP7wD8qE2Zwu+SeIsNxNIfcYBO4lOaBlvC
         HeuA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 192.55.52.136 as permitted sender) smtp.mailfrom=kbusch@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVypQ4GX3GCa0vvyDK3HjtkCckFZMN1dL1tiPXG3gsPbUo748b2
	s5mj3P9TA2/+OlSL0ji9auEIdfZz2dwV/FaJ3Jevc65IjW12HmNquNWHBSPTWNLxUIRzMO5vVWS
	3/FSI6FEHJiIk8KDekf1XMGv5xbAERBCRCl3oRB/GAG2pvsK0eBYHAAGwHP2pWh4=
X-Received: by 2002:a17:902:6a89:: with SMTP id n9mr5419093plk.223.1552672214733;
        Fri, 15 Mar 2019 10:50:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwH6JprLrTsPVyPfY6GeAtp7AZUeNpxcJx489afEn0AOvPSi+dM00/6I3GyrYaA0thSlEpS
X-Received: by 2002:a17:902:6a89:: with SMTP id n9mr5419002plk.223.1552672213248;
        Fri, 15 Mar 2019 10:50:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552672213; cv=none;
        d=google.com; s=arc-20160816;
        b=U5oAnqpfohTNQ55MWmNy8jR8PvQB8JqBNUvt+6x46YR9VN6/gZT1oEmdD8GPtYJg0U
         8dtum351v7IA+oWd30VlCh/i5hhCrHTvaOdkZ3n0AFyFrwgsjG9FJ8rXTKqDBbgbA/cb
         PlSSs2t5zR1ZGwTjVYjURRTGKqp3eb97Sm5mN3TfeT8vQSkPNsP8GZE63JZis4X/Wgut
         iBQA8kGNtjbklbn6F1PFqS/qidLNShqH+s6upoX4XB42byv7g22t5smZi2YNOR9sFH8/
         ZlG66ctAuEYQmPKJpwf/0cxPCbL1sHeFauuOtR+goGcLWSPIg03t8i9fnNZ4jihQfvt9
         qfVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=A5xhj2FEytWRKHeyYO2csICL/EL3s1rTh/48RKr6pRk=;
        b=wkUVM8cDmmLt+qN0eXl5aMITapiB6MJenARbee4hizA/6I0MW6ZP5WW8QudUgk6d9X
         IsjOmV8BAVzPUxSXdrmkOkdaMRdgf55xLrr+FAlCiT6236+TKbraUhCcyTKr8jtEC905
         bR0rEQUnTxfYzh/wjmE6XqsRSGrEPxaS6mrTgglXUOVeZ5QVWapx3nBiTI0CeuIGJ5Sj
         kjHWlxhYmChKumJnyET3WYjK3XcbIg+PwVrHVrx0Po9goJAYpWB7zdfCOMM1CWZnuAdd
         eIy3pEiyolFZ6KCsYA6127mKMZvwr/Qcza+BpejVXIFXii/SowJraer2PksbHA15SmwT
         azBg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 192.55.52.136 as permitted sender) smtp.mailfrom=kbusch@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id k8si2249458pgq.588.2019.03.15.10.50.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Mar 2019 10:50:13 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 192.55.52.136 as permitted sender) smtp.mailfrom=kbusch@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 15 Mar 2019 10:50:11 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,482,1544515200"; 
   d="scan'208";a="152724750"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by fmsmga004.fm.intel.com with ESMTP; 15 Mar 2019 10:50:09 -0700
Date: Fri, 15 Mar 2019 11:50:57 -0600
From: Keith Busch <kbusch@kernel.org>
To: Keith Busch <keith.busch@intel.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org,
	linux-mm@kvack.org, linux-api@vger.kernel.org,
	Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Jonathan Cameron <jonathan.cameron@huawei.com>,
	Brice Goglin <Brice.Goglin@inria.fr>
Subject: Re: [PATCHv8 00/10] Heterogenous memory node attributes
Message-ID: <20190315175049.GA18389@localhost.localdomain>
References: <20190311205606.11228-1-keith.busch@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190311205606.11228-1-keith.busch@intel.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Greg,

Just wanted to check with you on how we may proceed with this series.
The main feature is exporting new sysfs attributes through driver core,
so I think it makes most sense to go through you unless you'd prefer
this go through a different route.

The proposed interface has been pretty stable for a while now, and we've
received reviews, acks and tests on all patches. Please let me know if
there is anything else you'd like to see from this series, or if you
just need more time to get around to this.

Thanks,
Keith

