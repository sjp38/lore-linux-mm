Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 248C3C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 14:59:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFDFF2077C
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 14:59:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFDFF2077C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6EEE66B02B1; Tue, 16 Apr 2019 10:59:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69D796B02B2; Tue, 16 Apr 2019 10:59:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B4E36B02B3; Tue, 16 Apr 2019 10:59:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2388E6B02B1
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 10:59:40 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id g1so14274168pfo.2
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 07:59:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/KJ0+vd5hoLIvd8y6AOiUsx1FZBpW5JYfxG7/qiyou4=;
        b=tOjo4gWGsR3Sid6ibJW+ngy7RH5zdMp5EK/94HHKbsuzevV0H7OBnzp2FysF7fH7Pc
         wRJu1z6h55xPhq2VAfKu6wB4UTQ9t0MLWuRk1IaYM1bYuiGQM2Hn9cTOWURaeV3WM9O/
         O3J7mrCGhZ6MlrOpct1dlW+Bd2gQLZ4yu/H3wIzoSvgK84LIAQEmlwd96fCOpq5yMUCL
         RoGFDXs86rPHYnXnPqMxZ+wN60k7p0JYwMtP2lgKyX1nulx5mtUlldrRyO3o3Ka9RfAx
         HBXbvoKjKt4xZ02MqnWhBIFtpGxG5Tf0wZrJf6L+lm/Mr1d6qDr8FjF+9+HkN11273KH
         YNzQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUmRtjPsIcaAichunVGLKzamYVvXe4U+qjvNOoJ6lCxLPHzr44y
	uMxzvyZF6hpgmGkrv0GWJEohPQLLgSg6RGod7rgmw6p5LPco7B4D9RvTzfO7bN0DUDG7kr/RxTR
	BCjjEtcsopUCrJYoJTknCVSn77YfUckOx4WSGu4hF1/7nYUxO3Sfa3EPJPVgueg8myQ==
X-Received: by 2002:a63:5a1d:: with SMTP id o29mr76499319pgb.320.1555426779389;
        Tue, 16 Apr 2019 07:59:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBheA0d47M1m5ZVKI7uxYZIV3EO1zi+3YrU/8QxkaGy90BNfAGC0BPzUYmLaT6tKZC10l7
X-Received: by 2002:a63:5a1d:: with SMTP id o29mr76499262pgb.320.1555426778747;
        Tue, 16 Apr 2019 07:59:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555426778; cv=none;
        d=google.com; s=arc-20160816;
        b=Wdx0rFdX3JDO8FS/FC2PaQO3qVoUoRIixtihWo0DNwdi7h0rjtv2iQSqIfDe0CVF9G
         pKhbA/xgYNDQdgO0B9Q0aRxhQJH180R45+u7snsH4O8AZJ0x4EL/VDemS1Yof3PVRWSB
         7rMLNZ1/c7ZB1K/LcvBVUJYhXUWm5Zlsr1Xvs7gGjP7FZj/Q49APMes19C5f85oRfEwm
         VLbHXQHRjdAwTr1xFmvyQYQVeY6O8QX9yf/PA4EGdYqLi7VwpIRDIoqorZFiVZ0o2Jid
         /Ws6DEl5lhv8vd6NHFa4kTjb7FGKoxQ10UF7dsvzEPWPvTHfR65KhXbEtHBDho+qvzdp
         5FFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/KJ0+vd5hoLIvd8y6AOiUsx1FZBpW5JYfxG7/qiyou4=;
        b=offGuLR62oBUDa5AzAauj2vhgLcWmjXRhQ+eR3g2uK1902sMl5lE5EAxeim+qy4WMs
         JjLaAWV84/WdILilRjcYirJyaCE3lwJAz1bYy2bYYj4w2TCYSmAeS/wrBjDe29tZZV5Q
         lklTnGRFetBITmpAErQy/pVsI2MLr+1FFA5Kfi+WJRKUL8tY70ArbBF6uPHA02mkkdS/
         U5+axfdqv4u0cjSuUzZ2wLhTSksqwEnmed13sqpNop74yex3on72Sd9R/QNR9kWYDBk/
         xj5ApQRm5t2FInTLxuLmF380MqJx9k80/Z0TszKOpNSs+sR7Cvq/YHQ8jkDIHta5MzC7
         rRXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id y193si13541474pgd.483.2019.04.16.07.59.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 07:59:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 16 Apr 2019 07:59:38 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,358,1549958400"; 
   d="scan'208";a="143410589"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by fmsmga007.fm.intel.com with ESMTP; 16 Apr 2019 07:59:37 -0700
Date: Tue, 16 Apr 2019 09:01:30 -0600
From: Keith Busch <keith.busch@intel.com>
To: Brice Goglin <Brice.Goglin@inria.fr>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org,
	linux-mm@kvack.org, Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCHv2 2/2] hmat: Register attributes for memory hot add
Message-ID: <20190416150130.GA20546@localhost.localdomain>
References: <20190415151654.15913-1-keith.busch@intel.com>
 <20190415151654.15913-3-keith.busch@intel.com>
 <9f130b73-e5ae-0529-69a1-28bd2ca29581@inria.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9f130b73-e5ae-0529-69a1-28bd2ca29581@inria.fr>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 04:55:21PM +0200, Brice Goglin wrote:
> Hello Keith
> 
> Several issues:
> 
> * We always get a memory_side_cache, even if nothing was found in ACPI.
>   You should at least ignore the cache if size==0?
> 
> * Your code seems to only work with a single level of cache, since
>   there's a single cache_attrs entry in each target structure.
> 
> * I was getting a section mismatch warning and a crash on PMEM node
>   hotplug until I applied the patch below.
> 
> WARNING: vmlinux.o(.text+0x47d3f7): Section mismatch in reference from the function hmat_callback() to the function .init.text:hmat_register_target()
> The function hmat_callback() references
> the function __init hmat_register_target().
> This is often because hmat_callback lacks a __init 
> annotation or the annotation of hmat_register_target is wrong.
> 
> Thanks
> 
> Brice

Oh, thanks for the notice. I'll add multi-level and no-caches into my
test, as I had it fixed to one. Will need to respin this series.

