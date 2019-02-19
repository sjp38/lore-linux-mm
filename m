Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88825C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 12:48:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FCF82146E
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 12:48:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FCF82146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D7E8A8E0006; Tue, 19 Feb 2019 07:48:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D52FF8E0002; Tue, 19 Feb 2019 07:48:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C693D8E0006; Tue, 19 Feb 2019 07:48:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 82CED8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 07:48:03 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id u25so3328363edd.15
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 04:48:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=NcVxnB6Xf4N7UX+f5oGSWeYVaIxtWnrvv1WFZ3giqtM=;
        b=HZhsxPWtzTTaChN+XuwnYBpeZA2W6GQBSFwv7qT/M9IG3iSEuAPKVCWrvB+9+fMUrt
         8d8E/fbGA7tLqrYcMJ50Q8Zfzk5e7Vql4Goex26SNYkQdZeeG5ZuGjhoVV5stPOfZZZL
         P0rhWmtngNASB24wA3uHmaguSBj4Tcu79Bv9YPMNNhXEpkJ7AiaDC5FAppWja7VqfwqX
         sQZI7Etl4YRLKyZERRVltlSUwnCM1LYIMYJ9nt/k4nUYJpE/kU93PxgiGi55GqSBOth0
         qMd4AwX9TO8T3zn8WNYDFLT88PXNjZa5LkSNNdQ4ZvssdiAQnGSyaSZXrtKTmlhYRA/C
         rtgg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
X-Gm-Message-State: AHQUAubVZNSXK/z+/P94KVk70mlnmp8PZokTI88js22eHzT0Nk+D+8zs
	xWYM5kDafwGmlL0KSqfVaQpsIvi5P4IJjgYc5icc33M9WmRvPYqRODwLeVf7pb08svXjh0TkWoh
	Ian7FUyCQA9SIhqj+AeIeIu2CwLPqoDQCz5hfnEPA44wfJ7ZRB0R4aZzzCTYLSRskcA==
X-Received: by 2002:a17:906:b350:: with SMTP id cd16mr3158171ejb.203.1550580483031;
        Tue, 19 Feb 2019 04:48:03 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY8LXhIA55UocpHJSkP9CkqD6MTsJ180rHPOMhWdnmFkVe6L1cPzZv+12Jacytrwy4OmQHY
X-Received: by 2002:a17:906:b350:: with SMTP id cd16mr3158123ejb.203.1550580482174;
        Tue, 19 Feb 2019 04:48:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550580482; cv=none;
        d=google.com; s=arc-20160816;
        b=vohepsOa5FX7+8R4346ajgAz9aqYNK2qDogH3E1vxiOjrITV20CD2VsxeK7rijBUWa
         HXo4Q1GlC/AuNUcitxp31zRAHiqYse6nJ7v7zDdRi5KCmpVP7Ny/reKaBrvM2qJucEzH
         I5JbTYP+4G6x03l491+hHEDHzEWp1wll5Y73FGJ2ipEs5nLMitSafcue0R5xUQHdLeX4
         hKBJjkpT2GwEUsZWazYSsUQVD08CaBLsUnbejlw6WDSQjVWF+j5f6JKNhV5lziW1x9ql
         rfzsrDUF9t3hQJhRtS2TbWs/gkfiFfiLMzrL2tFXI5zbmB0zsfmCAt8Njj23cT1Si0dC
         t+fg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=NcVxnB6Xf4N7UX+f5oGSWeYVaIxtWnrvv1WFZ3giqtM=;
        b=kT/UU5PxQm/XchNkG/N0VhzamRPj3OlYVBiOkbn2FoK2f5s9xFJ4yE6LV7pM+BSbWg
         aWP+cvhGLHEmq0T1USc7hyU/m3BzCATsOjBi+BeQ/YxtbAiDgqabGWGuDxE9jk6MSM1V
         rzv6VHIZB6XL+SYmkFw+H0XUqMRG2mfj+ubwIjOfQIaS11/sOAWyxnjq4yOQm7+UQ6cc
         thutiSwOjkMv7/bL94rOUfU2kIyf9unuaocrsAqvFK7DuWuSsaZlEgtRFqvPkMPDPJvt
         VKUHoKBUEdX9EOYNRAh4vD+ZOpW3TDBvegugU6MtADZLjjC2PB/v23T+sFqsMqSddLe0
         UmOA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v45si1321279edc.90.2019.02.19.04.47.35
        for <linux-mm@kvack.org>;
        Tue, 19 Feb 2019 04:48:02 -0800 (PST)
Received-SPF: pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1488AEBD;
	Tue, 19 Feb 2019 04:47:33 -0800 (PST)
Received: from fuggles.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2434B3F720;
	Tue, 19 Feb 2019 04:47:31 -0800 (PST)
Date: Tue, 19 Feb 2019 12:47:28 +0000
From: Will Deacon <will.deacon@arm.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org,
	npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux@armlinux.org.uk,
	heiko.carstens@de.ibm.com, riel@surriel.com,
	Tony Luck <tony.luck@intel.com>
Subject: Re: [PATCH v6 09/18] ia64/tlb: Conver to generic mmu_gather
Message-ID: <20190219124728.GC8501@fuggles.cambridge.arm.com>
References: <20190219103148.192029670@infradead.org>
 <20190219103233.383087152@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190219103233.383087152@infradead.org>
User-Agent: Mutt/1.11.1+86 (6f28e57d73f2) ()
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 11:31:57AM +0100, Peter Zijlstra wrote:
> Generic mmu_gather provides everything ia64 needs (range tracking).
> 
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Nick Piggin <npiggin@gmail.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> ---
>  arch/ia64/include/asm/tlb.h      |  256 ---------------------------------------
>  arch/ia64/include/asm/tlbflush.h |   25 +++
>  arch/ia64/mm/tlb.c               |   23 +++
>  3 files changed, 47 insertions(+), 257 deletions(-)

Typo in subject (s/Conver/Convert) but other than that this looks sensible:

Acked-by: Will Deacon <will.deacon@arm.com>

Will

