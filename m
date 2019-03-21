Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4578C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 23:31:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62CCC21900
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 23:31:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62CCC21900
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 01BFB6B0003; Thu, 21 Mar 2019 19:31:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE7396B0006; Thu, 21 Mar 2019 19:31:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DAE5C6B0007; Thu, 21 Mar 2019 19:31:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id A42286B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 19:31:50 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id o24so377077pgh.5
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 16:31:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xB9JEZwpOHF8UAWyaiN7jGDy8s7fjnx0RvVCSyrsmBo=;
        b=VHVya08FHbF1+wnIjIdTHcnDmc8liQ5qJhUSOP0NOL2mDLCq8PGmv7394NouaoInfC
         Z8xtFUuFRYaY2JoSzs3gv8FLffxgsqif+NCgFaaswjq8T9s7chbSKJG0X6omps273QX9
         lqVb/M0uGlWyZ0FkzjZ1z3G859DLcVc8ZPvQfgGdDgM9hblYMKKqMKjW8s+fZwxMrdOJ
         SO/Zoh8Jn8/sMxeQp/tjiJ/4DyMbsBNNXKTCdtDu59A54rwBdzxKMD/xzTGV+dNEd6eS
         8DeuhzvS9+aUjinCVnQLeeA+FdFXpSYjagSU9y0JJAHNbuZDd2aSrrJXuXozxn94Jcbu
         mDCw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAVNW65RbevODxVlHp3XIpXhQs+YZ5NgXmdUrB1gFuvgo7mwlbCv
	hKovAw1Jf8mjrYrswhCVjvP1noSWq+/npKrF1f8lxvBD9J7uQoJ4vFFUQaweGGrjwtGhIjm1Y6a
	Fyzyh8Bf46s22kuClOvP2WwRNLT6a5qJR74MGHMn832AC3k6MjxhuK/tJG3pkVVfYJQ==
X-Received: by 2002:aa7:8d49:: with SMTP id s9mr5145631pfe.248.1553211110358;
        Thu, 21 Mar 2019 16:31:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxMsAxBW8udb535cUG5tk3IrTdkgLiQ4nb8qPB4rY7/VtLrYKcTEZSrBVFHTsl68VYmG5D+
X-Received: by 2002:aa7:8d49:: with SMTP id s9mr5145582pfe.248.1553211109650;
        Thu, 21 Mar 2019 16:31:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553211109; cv=none;
        d=google.com; s=arc-20160816;
        b=JKaKybTrN/sjphsgDyMY8EwtDZo5pGxkpL5aT8OqHGZRR+foKj36Qn9hbxSmnaTIoo
         ZJNuCBi8vlpIGlb4nMNBgMXT4jUfEJjCq6WnOWHXhkD76fgaXJi7ckOHuqjditCpEesf
         XhtsUvIvHkAlCdq9znkTa6McVL8vd0kHXV6FH4Qs2fpJnbjC9JD5Ak7h5Dr5N8VgU+7M
         U0FUSE6/yMtr4KjVi92sGPPV02ONcHk8lg0qtbXCBMGJtGkapjcvEs0YMoi/lf5RyKtw
         ueV63K7EkqYiwCgpiole5qj7zlZ2cwSh4EdU9XYXpHVKdp9Pk+NRWHqG6Yw0DyozGXjK
         K+gw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=xB9JEZwpOHF8UAWyaiN7jGDy8s7fjnx0RvVCSyrsmBo=;
        b=XTBUBeIPTqesXFMpWU6g+1R7TUBYXwZSp2oOlq0RK+4QQX6714rVwpZOKGbDUxjCxJ
         j56psP1z+21TfA1VUNWMDrjRjVs+XoGhlyn27Rq/Y3kwDqxpeGAIEtbPK2GBJAtx0uDd
         f9vB2G+nl6XkGa/fjt+m4I5uU3rk7wMtuKNPx9EKWY+GGp8NC2bNRP7iS7pCSzb28zhS
         4FQC+bPUktngYXm9LpIgvPtID6Xz1gy5dLC6W0UugyAICAjTuaR/xAAh2qHG9vBWZpkP
         td0nVCCpBZ7NZueCjvKkC5Zg4aAkGOULP8K4rtQE8lCk6SFJGocZQL8aWqB9hC7dTF9X
         7fsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f3si5122081pgs.557.2019.03.21.16.31.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 16:31:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id EA19EF39;
	Thu, 21 Mar 2019 23:31:48 +0000 (UTC)
Date: Thu, 21 Mar 2019 16:31:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: "Kirill A . Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>,
 Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: page_mkclean vs MADV_DONTNEED race
Message-Id: <20190321163147.cc2ff090a7388cdb7030eed0@linux-foundation.org>
In-Reply-To: <20190321040610.14226-1-aneesh.kumar@linux.ibm.com>
References: <20190321040610.14226-1-aneesh.kumar@linux.ibm.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Mar 2019 09:36:10 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> wrote:

> MADV_DONTNEED is handled with mmap_sem taken in read mode.
> We call page_mkclean without holding mmap_sem.
> 
> MADV_DONTNEED implies that pages in the region are unmapped and subsequent
> access to the pages in that range is handled as a new page fault.
> This implies that if we don't have parallel access to the region when
> MADV_DONTNEED is run we expect those range to be unallocated.
> 
> w.r.t page_mkclean we need to make sure that we don't break the MADV_DONTNEED
> semantics. MADV_DONTNEED check for pmd_none without holding pmd_lock.
> This implies we skip the pmd if we temporarily mark pmd none. Avoid doing
> that while marking the page clean.
> 
> Keep the sequence same for dax too even though we don't support MADV_DONTNEED
> for dax mapping

What were the runtime effects of the bug?

Did you consider a -stable backport?

