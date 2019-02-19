Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16B2FC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 03:08:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 952CC2064C
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 03:08:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 952CC2064C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD1448E0003; Mon, 18 Feb 2019 22:08:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D7F298E0002; Mon, 18 Feb 2019 22:08:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C20D18E0003; Mon, 18 Feb 2019 22:08:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7FB3A8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 22:08:57 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id d62so7980831edd.19
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 19:08:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=BQpYoTi/BO7c3Ih1NH4UHv0k5Uk2px89X9AFWSAol00=;
        b=s9N2AJDsb2xMVEljUY9zkfcjQ9004xf7Ji9pzWYmWnqFvFVaLPoG5JQi8zy3h2hAem
         EooGw5zqSU8S4YmAhx+uEAHluT6pBABXsG/vN3UwzBeVLmXFWhJYLy9w2mLdB6mdKV3E
         yC4cxKssj0fodHioifTlo9hQ7pqNZ74GPbBAkGdFG9lDzf+5pLkapJfR97xSwK1usblV
         DmqN394NNQ+arPao2t86yXlYpVO3xjJfjIqZzQg5pCmTjKYqxXrgNjQGy0w1YQNxZjil
         6lc1+jTXzPp12TrIiVNpcfY/wRq/Fm//PYgr8amOkKVtfJJgSpNGr7kR4ydo/zctGygI
         yg+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: AHQUAuZ8rB0CYxQZaZqe9A/0tjTkEIOhebjCkMtYGTv8Isru33+Jl8xM
	d2bpgHsR0Q6dGXbFIbnQWgR6zv5aHvIxAkqTm2qZ/4pzOBMJiHsRj8Q29d/c/FFx3vBapliIy7c
	rCBVd5ubs1F0xmg1KF3NMgsEIRELMhKxDd5wl5UwGc0usRtwvYw+4uP3NrFIvHY/Sow==
X-Received: by 2002:a17:906:6043:: with SMTP id p3mr18415210ejj.72.1550545737049;
        Mon, 18 Feb 2019 19:08:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZKYlOY5TelaCYXyUiD23nwv3LPVPV6MEWl+B8AAtF/dsz28A3oQ3s3N446euJCq+bC141Y
X-Received: by 2002:a17:906:6043:: with SMTP id p3mr18415176ejj.72.1550545736114;
        Mon, 18 Feb 2019 19:08:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550545736; cv=none;
        d=google.com; s=arc-20160816;
        b=V6K3+eIankpFuBmHT5kvJ04mvMlJctKLj7mjUKj7ws1+pL2uzqcwbTD63PGA8oqnAG
         zyrI3dk3K5f+jTRgbEYGYw9YJeOi33lk9yo4dBL9OdgmsyX/QYADDonRghnO20nEWcW4
         Qkh/OcGCE2FoQ0k8AB0iuYv2i51eeoWlhDU0i47rBLLovCIPvbakPcVd8YOrpO6lQpZg
         qxLfha+mJ81XY+c199l0OQtDy3zM7TQ+IkGxsjouo1698nT7JtOYR/LzJ40pI05KdkRs
         4xQxksE/YO3tfADXCAheggyZ/xUTcRIQCu5ivicx/L5DqOcY+WpoNhYQ759D3StVuRlZ
         yWHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=BQpYoTi/BO7c3Ih1NH4UHv0k5Uk2px89X9AFWSAol00=;
        b=BlwTabppPOjrWlFahWDtdWYvx9LO/Mk6jL8p2Bfr/YRDiYZ0hsU/UmntzchAuhr7O2
         ura7aJ/jrZJbHNfJVQ/8cP1O24xu+lbk3ugmJawt02bxs9EPNYP2OFWTMVaBIybvVdDK
         cnDjV9wfwSNCybzhdmkEkcFWYtxF65Y9cGw80VSIUn+vEDNNVO/SZSkQQRyK2CPZqCXD
         4q+sKujeycnAUhohUniUhdKa/SqsZVyujdf+TNqhk1th+GP0jf169A57AVu8+rNIgTDg
         5QrZwyTOhXXihGNbKj3IRC/EyOxFXiEgqzt5pwxZIYRTYiYKPcYUxrHZQmsI8NXTy2OC
         tn2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p1si6288441eja.16.2019.02.18.19.08.55
        for <linux-mm@kvack.org>;
        Mon, 18 Feb 2019 19:08:56 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4CB1480D;
	Mon, 18 Feb 2019 19:08:54 -0800 (PST)
Received: from [10.162.40.139] (p8cg001049571a15.blr.arm.com [10.162.40.139])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0EB4C3F575;
	Mon, 18 Feb 2019 19:08:50 -0800 (PST)
Subject: Re: [PATCH] arm64: mm: enable per pmd page table lock
To: Yu Zhao <yuzhao@google.com>, Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will.deacon@arm.com>
Cc: "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
 Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@gmail.com>,
 Peter Zijlstra <peterz@infradead.org>,
 Joel Fernandes <joel@joelfernandes.org>,
 "Kirill A . Shutemov" <kirill@shutemov.name>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linux-arch@vger.kernel.org, linux-mm@kvack.org
References: <20190214211642.2200-1-yuzhao@google.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <f67b5468-2144-c51f-6cf0-ea7ece93b502@arm.com>
Date: Tue, 19 Feb 2019 08:38:54 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190214211642.2200-1-yuzhao@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 02/15/2019 02:46 AM, Yu Zhao wrote:
> Switch from per mm_struct to per pmd page table lock by enabling
> ARCH_ENABLE_SPLIT_PMD_PTLOCK. This provides better granularity for
> large system.
> 
> I'm not sure if there is contention on mm->page_table_lock. Given
> the option comes at no cost (apart from initializing more spin
> locks), why not enable it now.
> 

This has similar changes to what I had posted part of the general page table
page accounting clean up series on arm64 last month.

https://www.spinics.net/lists/arm-kernel/msg701954.html
 

