Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1319AC10F00
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 20:16:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D0E9A2084B
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 20:16:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D0E9A2084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C85D6B0273; Tue,  2 Apr 2019 16:16:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 677396B0274; Tue,  2 Apr 2019 16:16:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B4726B0275; Tue,  2 Apr 2019 16:16:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 291B56B0273
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 16:16:34 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id w27so6451528edb.13
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 13:16:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Fgwlcj426vNPr1Zk7L7k5LY+HGdH7onlyfedTfEaV48=;
        b=eSybVogxvyfHY+ibfO9ZZPvTJJimtJ1mttuEE29ZUpFo2jdBcV3c070OnIkA47pyGg
         w+UNlv2lvr5OtJiUMiDEQZFUXUOH7KvMlGrZLVvW2R9umuNW1AKwT4/YdYJaNuU1ySbv
         2zt5caDZtP4VND5eupo7MA9uSImT5C0E+tAUIAnFC6jnsDGBQq5hCly70lwlmxu83dtv
         8h0toN195+pimhQ+vxxVXagBsWyhnhz8AXcUFV3ZXohn5CsBtA3E2+5A/CQ0GJc2Otl/
         FSgDcuIwXx8QN5PNOWGRd+6s+bWnTqvOs297bk9uRWTa4jl6biXsElMwBE1cSnjLVhfb
         f+Uw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAUUfnWu8AR94rF2wQ6+dL1HvazUG72x68FWIQLEykCNVSgxcEAf
	CiyLTjeFnMCMGd/t3TL//XZnwT8WjOYHhtbC1Q8awAtudOC8l7C8XUPsZnMLh2nVMJOtxCLSQs/
	ACOaE2NCSL0yAvh6CfuyC92QM36rEG/EWd4zxRbHV8X3f0x0ei3aY5DEypL00HCO0CQ==
X-Received: by 2002:a50:8bb4:: with SMTP id m49mr49397280edm.28.1554236193736;
        Tue, 02 Apr 2019 13:16:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDLBTcoD+/IY86E4zMPhXxIc2wrLvYIFf6WOiOwNOJefI0YaXvwyvFxrN4lWgEmFf0YPvG
X-Received: by 2002:a50:8bb4:: with SMTP id m49mr49397233edm.28.1554236192916;
        Tue, 02 Apr 2019 13:16:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554236192; cv=none;
        d=google.com; s=arc-20160816;
        b=qUZ8zBtlY1jDzULodo87yrc21oH+c9WAfUL2CegLsbQ31+6sJP7UIERVTq8zzCZGfe
         hVFGO0j0vhIn6xsymo78vnd7INCLq7UA8UXUPDafgXbSgs/9FBkoQjkeg3nlXnZM/710
         E75DxujZFj/0cSgoSCLn1lKdhfuAj5CUyxSAr+PkdKwWO2AlX75j3ACrSdTmce9ntmvX
         4WYwBFDU7VJH81Ne3Oan6XbGh2vfDOngASiGCSa14vO4929MUfUFkPNx6kfpyt3iNxy6
         iFJ6BWIik+aAkMtG1cxM/zZ5kHEvZJVPgizKtRrUVLCBHW1ocTIS2yxf4VdIXefsYbmS
         7TdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=Fgwlcj426vNPr1Zk7L7k5LY+HGdH7onlyfedTfEaV48=;
        b=fSA+YG8ha3xd4s6w3zqaLgVNcApd2kFRQxDWL/n4ZQkEZDym+UiGtOi0lgQ7gSpR25
         0uhqS0IxyBs6JVvUSqJywt3edAgB1lLBn5by0lpTCMsf6ASTtb57Yst/KFCMoSE/pPcD
         5b9IkYmVZayWVR5lQ8pT3bh3DJXTAVUKIM8TrYzr7HYgo8rGFm2Bh7bQ6xi+12WDnHWt
         eNp9ZnivN57njfapmWOE2kQBcqPT6t6zkiOq6MAXQaA4C+LhwVXxyxPWe3+ieYgWqkux
         EybojKegKByv1Xld94f53tDFl40SHfJyN5sbK8zzWAhzlKGUclyq2gPA5tA2rmOZSUO2
         YQ5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n10si3101970ejh.79.2019.04.02.13.16.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 13:16:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E90F1AEA3;
	Tue,  2 Apr 2019 20:16:31 +0000 (UTC)
Message-ID: <1554236175.2828.5.camel@suse.de>
Subject: Re: [PATCH] mm/hugetlb: Get rid of NODEMASK_ALLOC
From: Oscar Salvador <osalvador@suse.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Date: Tue, 02 Apr 2019 22:16:15 +0200
In-Reply-To: <20190402130153.338e59c6cfda1ed3ec882517@linux-foundation.org>
References: <20190402133415.21983-1-osalvador@suse.de>
	 <20190402130153.338e59c6cfda1ed3ec882517@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-04-02 at 13:01 -0700, Andrew Morton wrote:
> It took a bit of sleuthing to figure out that this patch applies to
> Mike's "hugetlbfs: fix potential over/underflow setting node specific
> nr_hugepages".  Should they be folded together?  I'm thinking not.

Sorry Andrew, I should have mentioned that this patch was based on
Mike's "hugetlb fix potential over/underflow" patch.

Given said that, I would keep the two patches separated, as that one
is a fix, and this one is a cleanup.

> (Also, should "hugetlbfs: fix potential over/underflow setting node
> specific nr_hugepages" have been -stableified?  I also think not, but
> I
> bet it happens anyway).

I am not sure of the consequences in older branches, but if it is not
too much of a hassle, it might be worth? Mike might know better here.

-- 
Oscar Salvador
SUSE L3

