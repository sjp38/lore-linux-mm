Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1378AC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 04:21:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDE23217D9
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 04:21:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDE23217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CD628E0004; Mon, 18 Feb 2019 23:21:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77C278E0002; Mon, 18 Feb 2019 23:21:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 66C338E0004; Mon, 18 Feb 2019 23:21:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0F1BC8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 23:21:24 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id j5so4298445edt.17
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 20:21:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=mk8lOmZdcHUo1AoO8js8+taA/aeuEaMD/UOvEPBusTE=;
        b=k3oBqZW8fUlyjjqXduwprTz25IqaMqLb7EaDfpQ1u1emSTXLrzCA3PzO8BHH9/ktnQ
         seebhRkTqGwD/AXcK8z+R88yZM8td5kBhJrUwNGi5IerADb0irr0YY9oHJkGSmQLxSXZ
         af/oiPtazRnyGqo1Exxvl2u7bNsVQ2u9bCK463ds8+Rl4IvwEmb7YtUhDSp8j5EMuJGM
         B6KHnTNtCLALtx+idHO7asEjKb4BQhBVQkr9Us/ZiBWhk56YwhMQna4u0e9o8HmE+dnR
         BDQnTR8HxHoAYJADKJzltHvol/ka3ocuxWlhv9gS5HbUbngkz9eZsgwfJjM18zkJ09vN
         B6yQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: AHQUAuZb0bhvsumBpCTT/q7nkGZx/eRO569oZZSZjGq1xqu3z94LN5sR
	ujgk4LxFb/NT/wftslRyoIB24bcsaDSIZjUKhtaPeAz4cKuqqIFX8i1ACbiRcbA0S5nEaIFQRGr
	yKMXJoMRYz/bALarG7YqcY41ZfHdqUYt6+6lgwr4EwaH2K8+8G0hgyAX8zKc+4GQs6w==
X-Received: by 2002:a17:906:5e01:: with SMTP id n1mr17813921eju.99.1550550083627;
        Mon, 18 Feb 2019 20:21:23 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaorsmyC9ejjJSPRhRXBSOXwrgzjrKPzE7qGSI2xT1s1nkgp8MgTeHMbUcpu7MmZc+6TeVi
X-Received: by 2002:a17:906:5e01:: with SMTP id n1mr17813888eju.99.1550550082796;
        Mon, 18 Feb 2019 20:21:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550550082; cv=none;
        d=google.com; s=arc-20160816;
        b=dK/op4W0H0l1A5X+rA2t5VzzSBNwSf3MZcwucZBCjoKOrKJVGB2mGBGIaCQsctE4RW
         tvoUMAGBhgxQUnfQmmEFUDMae+SgHIak5edRbV+Vick8uijI/nzoS+peYRRO3iO+FpT2
         En4hxB9oWisbchYYlL6acHeRh/rDnzRmCLtybybUPpCyXvOefY5eAlPQzrt+u0qrknV6
         Nxe6rQyZH8/h/SNMAcj8BfBy+in2aHmc++2BpDq9SS6UgsYA4Qm9suOTpWxGdL13dqod
         nwTQjK8+v1U1oF8Ya86JN8dHC7pz1VfBvk/7XpnCN3RraCyUfmfPA+WPQaO79G0/z6zh
         OqoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=mk8lOmZdcHUo1AoO8js8+taA/aeuEaMD/UOvEPBusTE=;
        b=TO7UEXLtesCYLsSFj6DO9a47WVrMNiqqrV5MjfoQv50oBJBXhOXSlPMTUkIQ3bkPv2
         s6jmot+Y1OohpMIQfgJn08IF0wsHgon4Oqr65dwYuSvj/sNTK5u+HtJ3FTsCCR/yl1tF
         UmLPlBPJc22yy4rYjrYpYSWp2MejTv/KIqnYKA6r/SobDXuwNBjR2qyJEVaGdYnbeIqN
         vGkpK5OileMAfsBg5//TUnTR05OBlEX4fajfO+3KA0YFQ/d13/NJmSNBcuEap1xbaQ1d
         mUW1FbTunG9FeGj16ba2oiDqbPz0O4F86tij8Z/f8rl02dXE6+jC19PvuP25Gp1/VfeJ
         XsKg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w45si1559477edc.291.2019.02.18.20.21.21
        for <linux-mm@kvack.org>;
        Mon, 18 Feb 2019 20:21:22 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 93488EBD;
	Mon, 18 Feb 2019 20:21:07 -0800 (PST)
Received: from [10.162.40.139] (p8cg001049571a15.blr.arm.com [10.162.40.139])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B102B3F675;
	Mon, 18 Feb 2019 20:20:57 -0800 (PST)
Subject: Re: [PATCH v2 1/3] arm64: mm: use appropriate ctors for page tables
To: Yu Zhao <yuzhao@google.com>, Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will.deacon@arm.com>
Cc: "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
 Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@gmail.com>,
 Peter Zijlstra <peterz@infradead.org>,
 Joel Fernandes <joel@joelfernandes.org>,
 "Kirill A . Shutemov" <kirill@shutemov.name>,
 Mark Rutland <mark.rutland@arm.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Chintan Pandya <cpandya@codeaurora.org>, Jun Yao <yaojun8558363@gmail.com>,
 Laura Abbott <labbott@redhat.com>, linux-arm-kernel@lists.infradead.org,
 linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
References: <20190214211642.2200-1-yuzhao@google.com>
 <20190218231319.178224-1-yuzhao@google.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <863acc9a-53fb-86ad-4521-828ee8d9c222@arm.com>
Date: Tue, 19 Feb 2019 09:51:01 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190218231319.178224-1-yuzhao@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 02/19/2019 04:43 AM, Yu Zhao wrote:
> For pte page, use pgtable_page_ctor(); for pmd page, use
> pgtable_pmd_page_ctor() if not folded; and for the rest (pud,
> p4d and pgd), don't use any.
pgtable_page_ctor()/dtor() is not optional for any level page table page
as it determines the struct page state and zone statistics. We should not
skip it for any page table page. As stated before pgtable_pmd_page_ctor()
is not a replacement for pgtable_page_ctor().

