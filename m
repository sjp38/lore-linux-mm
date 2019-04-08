Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89517C10F13
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 14:22:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52A5721473
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 14:22:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52A5721473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1A566B0005; Mon,  8 Apr 2019 10:22:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC7116B0006; Mon,  8 Apr 2019 10:22:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CDCDE6B0007; Mon,  8 Apr 2019 10:22:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 82EC36B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 10:22:47 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id e55so7062024edd.6
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 07:22:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=v1d5p7erISTsktQMTTTaFryyIoJDvVRGzgG0tuzHFkY=;
        b=CygzQuujqq6Vlaa6bIyMnEJLswCPaPPnUQc86axbdHRfYbiGpxLu1ebmf6rmI0lmSL
         C1cUuTsrcU0xysgSDVAz311tNx8UKQK7708gFJ0PeQmBowd1JaR6Yv8xSvckBTCH1Qcl
         B8uJ/MBVr2hDsJB+8Ul3s+A8RtIqODGF2Pka5jdxMYVfZOpNxnYIgT9G5SAP3E+7V9Ys
         ClY0XsifAZJrUe7NaweN/9O59iQ845Xi58VBdItevcP3W0odmONGTyUGc80ZNOHnOKPe
         EJfomyFvrtid9BZOUPZMLagGL9MZrwPvFDpEGrVbf84WMvl5m242K4lJyCeYJQVY5yNO
         9+aQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
X-Gm-Message-State: APjAAAVkbRs66XtS0mcC5gYBcChvVu3rK5ujDi5+zwXnXCCL1sL8AqPc
	g2ERbbs84S7dg65W49Yo3Ox+g8G5cg/qGNJS4Tbu0NRC8fPNcwqRwAxwzT5DLXTEs2CU4v0q3Kt
	HgX3FhnY/jCr77LY8EDjOmKKB5uviIFdJc1KjOmJXV9m6zsqT64i1xWnsNYgTpjGenw==
X-Received: by 2002:a50:d8cd:: with SMTP id y13mr1226577edj.184.1554733367045;
        Mon, 08 Apr 2019 07:22:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxgmlSsxIfs8UrrnvsELdyu4dQEcIU/XF9A0nhSvnUNZsqf58ftmyWLupg+Zb45SGMgBSFp
X-Received: by 2002:a50:d8cd:: with SMTP id y13mr1226520edj.184.1554733366172;
        Mon, 08 Apr 2019 07:22:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554733366; cv=none;
        d=google.com; s=arc-20160816;
        b=twfTaFJh1+svp+gUoZKMtUQ5SDb+gg0iejEPbo2T1a3ieDNu1SZlTDNPer4KoR7Fd6
         a8BEzA+wxHrXFGFeDJFkPOuapZFbmv68K1ZuU7c5P3SeKHHl8n/aS7XT8TxWj0rO2cHk
         2UQSUM0SzDNk9o4Db6Ux5jbVZVgKBxCQMc/umZCraD3blM8vliva76R1If8vhZeAQNGN
         ch6VQElcRJP11DiGUk90NY7SreA3CFedwgWXk4M7ZQVGMYUtlRwPhN1rTU2EOBRjT8/c
         QUqkjQsF+R4oqPyLfjC2jgsiF3/73X5bDq+Gr6Oe2zt6sYjMLfhrrJzKEICdKem3d5lN
         0SdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=v1d5p7erISTsktQMTTTaFryyIoJDvVRGzgG0tuzHFkY=;
        b=omNWj5rfflnfabHRUcsU1n9iKlpuUVaBtuuxIPz0P7uXlZ4Fks4LWlH8LtubB+iauT
         eV1M5rMl9QVOSQEVZXcw7Qz16PwIZXaGqxJvOyouNs1Bkb4E2o/I9qRWom90VVNhsbKR
         G3CG5ZCd7YBaFEZe6ETAe7eyY/ktztnVxcu3ZpFeBsvHR4GJ/aL4Kd+sUnb9CO4Z0Dic
         RDfcIeDzoJ4iYEY/RtBJ4UVX4Z6NvHylWSnC0E15ADOlAqThlODjdQeye1K/Kv7h7FmM
         I9tt+mHJlv3eXm/JxqEiFmprIT5lRyj+uxG1f/JYYhXxleywDSYU/nHToWsxxfCmg/A+
         QniQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b5si1659989ejk.50.2019.04.08.07.22.45
        for <linux-mm@kvack.org>;
        Mon, 08 Apr 2019 07:22:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E832C15BF;
	Mon,  8 Apr 2019 07:22:44 -0700 (PDT)
Received: from fuggles.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D3F153F557;
	Mon,  8 Apr 2019 07:22:42 -0700 (PDT)
Date: Mon, 8 Apr 2019 15:22:38 +0100
From: Will Deacon <will.deacon@arm.com>
To: Yu Zhao <yuzhao@google.com>
Cc: mark.rutland@arm.com, julien.thierry@arm.com, suzuki.poulose@arm.com,
	marc.zyngier@arm.com, catalin.marinas@arm.com,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	christoffer.dall@arm.com, linux-mm@kvack.org, james.morse@arm.com,
	kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH V2] KVM: ARM: Remove pgtable page standard functions from
 stage-2 page tables
Message-ID: <20190408142212.GA4331@fuggles.cambridge.arm.com>
References: <3be0b7e0-2ef8-babb-88c9-d229e0fdd220@arm.com>
 <1552397145-10665-1-git-send-email-anshuman.khandual@arm.com>
 <20190401161638.GB22092@fuggles.cambridge.arm.com>
 <20190401183425.GA106130@google.com>
 <20190402090349.GA25936@fuggles.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190402090349.GA25936@fuggles.cambridge.arm.com>
User-Agent: Mutt/1.11.1+86 (6f28e57d73f2) ()
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 02, 2019 at 10:04:30AM +0100, Will Deacon wrote:
> On Mon, Apr 01, 2019 at 12:34:25PM -0600, Yu Zhao wrote:
> > On Mon, Apr 01, 2019 at 05:16:38PM +0100, Will Deacon wrote:
> > > [+KVM/ARM folks, since I can't take this without an Ack in place from them]
> > > 
> > > My understanding is that this patch is intended to replace patch 3/4 in
> > > this series:
> > > 
> > > http://lists.infradead.org/pipermail/linux-arm-kernel/2019-March/638083.html
> > 
> > Yes, and sorry for the confusion. I could send an updated series once
> > this patch is merged. Thanks.
> 
> That's alright, I think I'm on top of it (but I'll ask you to check whatever
> I end up merging). Just wanted to make it easy for the kvm folks to dive in
> with no context!

Ok, I've pushed this out onto a temporary branch before I merge it into
-next:

https://git.kernel.org/pub/scm/linux/kernel/git/arm64/linux.git/log/?h=pgtable-ctors

Please can you confirm that it looks ok?

Thanks,

Will

