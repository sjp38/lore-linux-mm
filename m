Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 337F7C10F00
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 14:00:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3E6C2075E
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 14:00:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3E6C2075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B73D6B0005; Wed, 27 Mar 2019 10:00:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 463FE6B0006; Wed, 27 Mar 2019 10:00:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 354586B0007; Wed, 27 Mar 2019 10:00:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E7C706B0005
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 10:00:03 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p5so6743476edh.2
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 07:00:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=r4bvgxUJvOLit1cwXAT+s3dCgELjzo+oWMoMU+h+WzU=;
        b=r0mOmCLRw4DhPSRcJ0ZWwlGQlWPECwYl8bNqrodgPqlJs2ucmo2DTRlWdJM3joDuwL
         68t0Pn/xJatnJayq0NX8KxLv/+uyhwFFinYaHhY+8b70fq8nuL7vSCW397UvU/qnklaX
         kR+hpALul1mNKrf3LadYB1R9ERKE1KQPpDCAdQZyIt5KDz6/hrXhq9iZJ7ulQXK1GpCW
         k4xFxEyetFZWBoRI3T9onUU+W0CYhPc9VN9sy8P95PYPpnQnv/a4/+g/FxYLYb9J1ANp
         RwkGYHWJb/ecj1nK7+KeDJ7LnjY2cpg0Cfxg7xYV0rhZspMP/SPSRCX+ZuCJ+Q9FD2/d
         NvHw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUzfpdluv3dO+Z3sfNIofObpEbjv8cP30R0cw7krNDJ3E5cj2cA
	PUlc2LdIjPUKr9GP8TopCxPsIpmmKnB1a4W/tMfLZE37Vbu1ofYF8nDYKskj151/Scq/F2R7kCX
	3mBDJBTR6IDKY2cfJk9pvr34VXzcxI7IRdrsJa7+SmiKOT+2f99QYAnSGlXoSy6L61g==
X-Received: by 2002:a50:95f8:: with SMTP id x53mr22848873eda.267.1553695203435;
        Wed, 27 Mar 2019 07:00:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKH7jdtYH9qhIqBA6p8zY9aKf6kNmkITUwckcwBfxY9ka7MrEx61cN3EG1pDpCjYglXlbY
X-Received: by 2002:a50:95f8:: with SMTP id x53mr22848825eda.267.1553695202516;
        Wed, 27 Mar 2019 07:00:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553695202; cv=none;
        d=google.com; s=arc-20160816;
        b=IFphLNVuL5tz79o1VdxCLjKozqsAYwrPPcCVr7jXamvb1c8l+lhdRv3jTsEP98LY4B
         WHOFveN3BnbxtzrxsPANYxp7bafVwuCQzZ1pj/CRBILxw2vdbSmViwCA+AQPjkLSlH35
         sSQxTMErkZI7OuZjTRCU+gGHqEkKSkl+tsGEIrC24iwUP9Fl0VVTSAPN8xbJ5TQC7lm5
         o8Y5Tk9JDp7Sw861GLh9H0NHkKzZg+cAU8bDb0p8udazfQLmvMhZ2dDCJKd4NL2NzAoR
         +oUw6bGd7pumIpKtVrNL7IMJKO8CXZgn0dFmSpcX71JP1k9vB9MJHDVbydtDxMxA9qxy
         PA8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=r4bvgxUJvOLit1cwXAT+s3dCgELjzo+oWMoMU+h+WzU=;
        b=OW4sRaYDDoTvqknS9/AI1WfcFRirwNF8alj89uahPE5Vtw6DAfR4xHP8ItN+mDrUVf
         4ABZCEFC237VepvwD5JjbGryxOTfIe08i15TBTvN3Kqw6K+mJiNtpyTj/Zz++tDyWLkN
         Zvhy6YgQpm7cysjFUtlM5TRyWL+CFxdA8PZaMBO6JwVgQU3a293mm+C+vy6iYFGtYSxU
         8BmYgMEgaHilU66psHJ2aL8sVAcYkCkYHYUfc5P2KaQM9ZIiTl4F61mfO8FTqaRTd0m3
         9mzXN6hkjP8NSSElQ+g6jieDNmwjsVdNyFZV1/m5eAUZOWVvz5bTZloY8AWsP3nYPhJN
         jGTg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q20si2424860eda.419.2019.03.27.07.00.02
        for <linux-mm@kvack.org>;
        Wed, 27 Mar 2019 07:00:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 53CCD80D;
	Wed, 27 Mar 2019 07:00:01 -0700 (PDT)
Received: from [10.162.40.146] (p8cg001049571a15.blr.arm.com [10.162.40.146])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id AB1803F59C;
	Wed, 27 Mar 2019 06:59:58 -0700 (PDT)
Subject: Re: [PATCH] mm/page-flags: Check enforce parameter in PF_ONLY_HEAD()
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org,
 david@redhat.com, vbabka@suse.cz, willy@infradead.org,
 akpm@linux-foundation.org, Nicholas Piggin <npiggin@gmail.com>
References: <1553689672-28343-1-git-send-email-anshuman.khandual@arm.com>
 <20190327131506.GI11927@dhcp22.suse.cz>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <e84f6e20-ccf5-5779-2733-7b259dc2493a@arm.com>
Date: Wed, 27 Mar 2019 19:29:57 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190327131506.GI11927@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 03/27/2019 06:45 PM, Michal Hocko wrote:
> [Cc Nick]
> 
> On Wed 27-03-19 17:57:52, Anshuman Khandual wrote:
>> Just check for enforce parameter in PF_ONLY_HEAD() wrapper before calling
>> VM_BUG_ON_PGFLAGS() for tail pages.
> Why is this an actual fix? Only TESTPAGEFLAG doesn't enforce the check
> but I suspect that Nick just wanted the check to be _always_ performed
> as the name suggests. What kind of problem are you trying to solve?

Did not hit any problem directly. Just from code inspection it seemed that
the enforce check was missing as compared to other wrappers there. I felt
that the commit could have probably omitted the check by mistake.

