Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CADDC169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 19:09:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B2242084A
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 19:09:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="EcqTklMj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B2242084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1A268E0004; Thu, 31 Jan 2019 14:09:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC9508E0001; Thu, 31 Jan 2019 14:09:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CBA578E0004; Thu, 31 Jan 2019 14:09:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9D07E8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 14:09:04 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id i2so2438178ywb.1
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 11:09:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=oUC4FU8/VnKdsvd1Mpd4ds8bhHaz+ycIOa4ELv9SXhU=;
        b=KzOxPn1pUqPlLIWvSPMAu12HqiyiJHBhmG6CuCfS1vqtEqadCuCTk1l7N/gGG3uE6n
         F8f1KPM1dO3wQFmKdFxt2UeEELhfm12+6oPf9Y38tJBFAUnVTNVxWW1+RKLsB20CZyb+
         iELoZY96bPSDOe47P4s3Jy+o46BL2hqVPxCFKV7GfBY7oo1zGAXjohtRu9lvxEDru38m
         eUx9gXko7qpicLqRuDuB7VMSY056Hzsl56Q42DKA1rxu9PlUmAHjN9H08YKBT3nUGHOx
         ovy4M0YsebX1PU0kcQ1VYNoJ55zzPDsfVF634tp8FpocJdVQl+r/BeRi9r9YCyV5QbM7
         yvrg==
X-Gm-Message-State: AJcUukcU1szEQchqo/zhhegHCsyhJa4E75pQ8DjzgjxdJVMmHiIqDt4r
	x5zKdcA5zwzioC7BMX3dZTEVtEtILa37UqJ/B5qZjSEZ2uBGC+jUQkG4ulH8kjTVUtYnToGqASn
	AlXkHujqIgrgV2gLkQraX7y391dOiF4GhvPIpSiellGg2UqT5QBc8Iau4KjHkwmvPNfK/YX7lTb
	NGYpUyz6TC5HxBGgBDp4duYovkJ2cBdAbG8IU43wt59JqAgJ80gpP17bw16FI1Y1biKsbcxtIH8
	lHVOEB2GkBkxhaGyL/Y2pObh/1g7YYv0ZU9PL3lp+Ft9tz/nMZW/iaS8TWboXgDCRhcfLYKIJ0p
	05KAlw3cBVMhLEUvtDzlvGUCowM5/37CQP3KdXSA1V2uwmtEPj2MGpOcdn+tOlM4szntUJg372C
	w
X-Received: by 2002:a81:6188:: with SMTP id v130mr34786205ywb.389.1548961744416;
        Thu, 31 Jan 2019 11:09:04 -0800 (PST)
X-Received: by 2002:a81:6188:: with SMTP id v130mr34786164ywb.389.1548961743882;
        Thu, 31 Jan 2019 11:09:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548961743; cv=none;
        d=google.com; s=arc-20160816;
        b=ti2jZpNF9CPfpBZrAadB2pYzrUY3mAy70T0I3G+OUlIFBHuGkLWwFbO7+d/Z5oYjzh
         myDksFnbzZxAMP/FdlkdbSjRIdCUf2shHSp5l0Y/1nl2kjdzr6F3Dqk4lj0tRPrnCPq2
         XRDWgREH2n89y45VcRoA+fIgTLBp/cHg63kC/AmEHZV4h0ph+qJnkH2p3Falb62gB1C7
         clOKM7RP8KZm1c/7og2Ii30J2RMRJw74oVsc7QNL1whUcWOvpSIsRBVn4idrLmbf30sK
         fDnkJcfFY2RMn9WyJsqgBZWr+kRE+QZC7faKE5/rFLM/pG7RFOWd049h/JtOIeR4ikSx
         olrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=oUC4FU8/VnKdsvd1Mpd4ds8bhHaz+ycIOa4ELv9SXhU=;
        b=s3llNJOVI+uDaAzBu9sqa6kTSCSHVPlzWv8xyGncqCka4V29Xl5eQBU1IqcZ2eK5dr
         KyapO5IBzi5sW5l78DA4I93Np05uNu0YIzjuOZWyB0GkqtHiNhAAQs01VYB3vf1jIA8E
         pFhvOwOI/7wzrtk6YATzmURSAiCIEVJsVT5sC9StBHum627PUdbsrxbBN75BCnLqS7TO
         zlFwuCBYi5lEf6ueNeBCWXnjAuAKlo6CU/LkLDhwvbY+9CxbZCgObNrpHVJOSCXhncy9
         CnsxbrtlmC2BN4zi6dsWlqCmjKIaD0VYBgPvk67Whov1LAysKvqOk8aLU8LnRZtRXRqO
         Qzxg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=EcqTklMj;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.41 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m10sor2880836ybc.43.2019.01.31.11.09.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 Jan 2019 11:09:03 -0800 (PST)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=EcqTklMj;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.41 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=oUC4FU8/VnKdsvd1Mpd4ds8bhHaz+ycIOa4ELv9SXhU=;
        b=EcqTklMjPwIuRTZ7IFzFmVGFnelzvLo0DACl8Xhfu+zaSXCEAxd7SSCyWaDvqfQXMk
         MTdXzScp5wHUcidNEiHBqNs8ZAIm7rNRw7OVAIQN41fr7aV1MKwgkzc3sy00JlsByeY2
         AMUngl6H06O/EYfWPaqolNcebwDn78QqO2YNA=
X-Google-Smtp-Source: ALg8bN54A77sdRfkNvNhvDvQHa8JiqnHLCy3kg+/ebm0KyDHN2kWjJe2pxfd8XCfzuKsJbyGtk+anQ==
X-Received: by 2002:a25:3b51:: with SMTP id i78mr29742739yba.144.1548961743241;
        Thu, 31 Jan 2019 11:09:03 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::7:7e97])
        by smtp.gmail.com with ESMTPSA id r20sm1923230ywa.13.2019.01.31.11.09.02
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 31 Jan 2019 11:09:02 -0800 (PST)
Date: Thu, 31 Jan 2019 14:09:02 -0500
From: Chris Down <chris@chrisdown.name>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org,
	Johannes Weiner <hannes@cmpxchg.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: Re: [mmotm:master 203/305] mm/memcontrol.c:5629:52: error:
 'THP_FAULT_ALLOC' undeclared; did you mean 'THP_FILE_ALLOC'?
Message-ID: <20190131190902.GB6743@chrisdown.name>
References: <201902010206.hcZ8gj0z%fengguang.wu@intel.com>
 <20190131110757.6b975f1e787dc7adf414a162@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190131110757.6b975f1e787dc7adf414a162@linux-foundation.org>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000300, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton writes:
>Thanks.    This, I assume:

That might be desirable as well, but it's mostly because of lack of guard on 
CONFIG_TRANSPARENT_HUGEPAGES :-)

