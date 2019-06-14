Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0D87C31E4C
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 05:27:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C3DF20851
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 05:27:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C3DF20851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 07C956B0003; Fri, 14 Jun 2019 01:27:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 02C3A6B0005; Fri, 14 Jun 2019 01:27:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E367C6B0006; Fri, 14 Jun 2019 01:27:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 990266B0003
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 01:27:28 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b21so2079072edt.18
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 22:27:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=k18mZU8HLAE5tIK3Sa8uo3iOF/03B7Dnvk0U0Mui1B0=;
        b=R3ugCYMJMFexrRr8k4j3kdexM4M78hRCekRcbYyf0VIQIaZRMRqIszeqJEBkjwYw3c
         +KjRUtNQeScoVeGwniz9XgR3DvU9AgS/8fD7ZtPvll1uj1WnirmA/XNw4GZ6bm1mIBlH
         arNJXsyDTGO7mcqTX1NWdiRCZD7DukwuIcGmqfVNFXs4l1NDfdyR4xaObeMHPpKatkqs
         RmB3LuS0RPoMZb3AS3kFkYs7vxaUig6aAXq3wqd5yjl8Yg9DUPN4wWgpTUwS8Xcncdr6
         XvUtq5ilKSpN124PVnLHKXHfPgJcyr4Bkv5N1CMY57I5WHpqZf2MGepAzCn/ccfJXkZu
         2t8w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUKRr1P9lLOJ/3Y7wnEvE4aOlDUOAJU4wilcP2/WRnLmoYYve/r
	4Mskd2CC0lRxMh2f2iSbUB4oo7piWpkxHM6NjDlAYDDREtMyqERdO9M7Tt0xi7oeKpQ7/KLgMP2
	C0EpRkRlC1yFTbuI1Qt+FfPEIXOLb27hUcAC2SIIS6NhzTQPDAAcZoO+1GRi3CY+bVw==
X-Received: by 2002:a17:906:355a:: with SMTP id s26mr10112274eja.219.1560490048197;
        Thu, 13 Jun 2019 22:27:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhlctEeMmIGPLQ1rLg98INQHYbsOzMPQeLfP6szQzLJh1Hy7bCKfvgl4Y1Ldydh4y/Mj/7
X-Received: by 2002:a17:906:355a:: with SMTP id s26mr10112245eja.219.1560490047418;
        Thu, 13 Jun 2019 22:27:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560490047; cv=none;
        d=google.com; s=arc-20160816;
        b=ybwUMy9UKRqYntfXk2JuWptabXXFz1/RPJwagiPz2Dr3zwBw04qQrT4qjJrun+Iljo
         hRpQJC0cQZdtMfya2hkKAz+6RwWzoy7S5y32cTVH9XA25Q4ev5PQM84i1DRdDIYXUvzk
         dS9uSFMXMUZofT8RW46Rq2POJpt/yDM+fikr6eH9/MNPhsTZgo8vHqMblunrE5QOreHT
         w23R/o6xgh0amIeDoxW2J9rLxk+8pnT1hSboQMJ+pW457cCPPx10+PrYYZ2POj/UeyRq
         NngtIVluYOPUfc7G90MSEOlpARiWrcGgF9hPbQ2pkdvUlViBJ2St5AYTVoDzLO/bsayw
         AKXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=k18mZU8HLAE5tIK3Sa8uo3iOF/03B7Dnvk0U0Mui1B0=;
        b=mU71CoPyuFdxmdN7ZdirlVZW+dOFLtp47lShl4CFaJTS7JUpcBygV6XjIlI9fuuERr
         FXYB1EhRDen8UFmlOi1N+OmGVaR//QJAcyVmEXGfP3GzYp3Hm7gDp9yJrztePviEfecY
         rU2VUFt8iIMc8tScThfG1yrBCKt/CaPkwQEzhkm1QYRmb9Q9ZuyuZiw/orCxoR1Mbrdr
         7CPka/TrHrt1bZTNIf0EsaIcrEeRwl/20DwviGLf405aoHKXeI3NzBLpYxy6sAys9Tic
         OahWsf6UpsAjKxO3bZPEPTfEHkQ/TpmqVlhwTHZ4yiVxhrRJJ9aITJ+kpnkCkFy7VzBC
         548g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id w19si1203677edc.371.2019.06.13.22.27.27
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 22:27:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 937E2367;
	Thu, 13 Jun 2019 22:27:26 -0700 (PDT)
Received: from [10.162.41.168] (p8cg001049571a15.blr.arm.com [10.162.41.168])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0CC353F246;
	Thu, 13 Jun 2019 22:27:22 -0700 (PDT)
Subject: Re: [PATCH] mm/vmalloc: Check absolute error return from
 vmap_[p4d|pud|pmd|pte]_range()
To: Matthew Wilcox <willy@infradead.org>
Cc: Roman Penyaev <rpenyaev@suse.de>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Rick Edgecombe <rick.p.edgecombe@intel.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>, Mike Rapoport
 <rppt@linux.ibm.com>, Roman Gushchin <guro@fb.com>,
 Michal Hocko <mhocko@suse.com>, "Uladzislau Rezki (Sony)"
 <urezki@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
References: <1560413551-17460-1-git-send-email-anshuman.khandual@arm.com>
 <7cc6a46c50c2008bfb968c5e48af5a49@suse.de>
 <406afc57-5a77-a77c-7f71-df1e6837dae1@arm.com>
 <20190613153141.GJ32656@bombadil.infradead.org>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <4b5c0b18-c670-3631-f47f-3f80bae8fe4b@arm.com>
Date: Fri, 14 Jun 2019 10:57:42 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190613153141.GJ32656@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 06/13/2019 09:01 PM, Matthew Wilcox wrote:
> On Thu, Jun 13, 2019 at 08:51:17PM +0530, Anshuman Khandual wrote:
>> acceptable ? What we have currently is wrong where vmap_pmd_range() could
>> just wrap EBUSY as ENOMEM and send up the call chain.
> 
> It's not wrong.  We do it in lots of places.  Unless there's a caller
> which really needs to know the difference, it's often better than
> returning the "real error".

I can understand the fact that because there are no active users of this
return code, the current situation has been alright. But then I fail to
understand how can EBUSY be made ENOMEM and let the caller to think that
vmap_page_rage() failed because of lack of memory when it is clearly not
the case. It is really surprising how it can be acceptable inside kernel
(init_mm) page table functions which need to be thorough enough.

