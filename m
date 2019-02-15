Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DBEEC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 15:42:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BCCA62192D
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 15:42:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="Unvl08o3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BCCA62192D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BE318E0002; Fri, 15 Feb 2019 10:42:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56DA88E0001; Fri, 15 Feb 2019 10:42:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45C468E0002; Fri, 15 Feb 2019 10:42:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1AB348E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 10:42:04 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id q33so9120079qte.23
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 07:42:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=AO5+6GjAtfAdzflCMfirBHPryl+1cPDIOakSZMCQ+6c=;
        b=tMcx5yrcm3PfFHVZ5UWoUU4B2syZBrT5DRtdsEvvFZCUY6668i3EBaaP7veIVVaMIP
         52Y+P6GXsKcD10A2cKnYYqVWpkgnLRfaavfazMY3D7FOnuN4J2nVPHGG842BUiNK+8OV
         iQrI5QcgPokvFd6Gg539IXrFqNqZU3puF4CcYHjEdf1+2G8ku86CGvGn5UWpOgKcniC8
         Ui83kGttYmM1rKrmtIHVlZ1C6VP7Etb9owLnHicb83WqTs6eFZLvkZIQjp3zRCGNepJZ
         dvsq1P/ghP/f7GiMPAksZvnK7gR/C20oBmGFv0PdjlMuIwT+j7brcfxNLh0mYY6lct9+
         S53A==
X-Gm-Message-State: AHQUAuYyuvIcn/d7LtVxp32LZw30+6XoaU3WaW58oTecT4FN5tCHIsZ4
	u7DqBHTEcdQtxXdXkYPEyHSWtHyJfhj+lt4rYl2eVce4OcQ7KZrT1kwTOg9dwvOIFV3YOHJd/1C
	ODzJ+r0SG3AyM8TSZr/jozGY1VI/9yHwzbdfyV+MprvKnH4WHoCU13P16hsyWBfQ=
X-Received: by 2002:a0c:e70f:: with SMTP id d15mr7604452qvn.223.1550245323837;
        Fri, 15 Feb 2019 07:42:03 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaQbdHOfhRkOlXJ32QinilV5VR+eelQDCfwJpok+pTo0Z6eoyQ7ny16imeEsyemVUAZYivN
X-Received: by 2002:a0c:e70f:: with SMTP id d15mr7604407qvn.223.1550245323020;
        Fri, 15 Feb 2019 07:42:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550245323; cv=none;
        d=google.com; s=arc-20160816;
        b=dskboF6Cjy+9CDD+fZELU9K8I7s9Hv856VChbglJQkgX6/aTuaqqP/g6PQ87usjH3V
         HCPFHja40fMB1jcDdD2JSzLn2uMIw9B4YEV3wGGhMa3H1biyOKSzMaAq2HLLvv/pguls
         /HOUVjvhEWrOSFTNluVgM3SgnEaTGFyU6pzvzI6m6PHW6hdd4M7M/l31s09mNycvnUaa
         tOcidhcvgsvZuWF4TDuyyJzvjFl5OfICf6Rl1UUL43rUP/+FGjck3sikArBd5Fq3grUz
         xWrqVkF14Ox5nKUMtJ9mLgT7La7jnbAlAyUfQK0L/D0CG9io0NqZjCToJTC83oYdu+ZI
         Cw5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=AO5+6GjAtfAdzflCMfirBHPryl+1cPDIOakSZMCQ+6c=;
        b=QPAOZt4+FrdCdpxCu4XwE80U1n+Ts9F+k4/eTyUgwQQkhnj4oOodI7dtknH0z7Ex6w
         nTJIeKS2WM7/dFBgA1J635F7C2aPX5x6HfLh7OhpintUqAU4XCP72Y844ihKR+oerQnG
         gbo3UhAvfXd5mM01hsHO4HsndxEvlVWIlSdd3ymv4vGaVXEFzyAaYnL9whAc8SzjAUi2
         oOU9NOcXLw5L5uYQyzqpqVMGs7TlPyTLRP8hL9EUPkRj/b1E9vdp7ngQMVwW44OX+1j8
         M5eaYEnb5nllBe/8lrn/Hdy9+rnHsyo/sQwYjTrfLl9SY6/dQm1G9dZUVNPW9NxjLGW6
         aohQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=Unvl08o3;
       spf=pass (google.com: domain of 01000168f1d25e3a-2857236c-a7cc-44b8-a5f3-f51c2cfe6ce4-000000@amazonses.com designates 54.240.9.36 as permitted sender) smtp.mailfrom=01000168f1d25e3a-2857236c-a7cc-44b8-a5f3-f51c2cfe6ce4-000000@amazonses.com
Received: from a9-36.smtp-out.amazonses.com (a9-36.smtp-out.amazonses.com. [54.240.9.36])
        by mx.google.com with ESMTPS id j92si3763394qte.44.2019.02.15.07.42.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 15 Feb 2019 07:42:03 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000168f1d25e3a-2857236c-a7cc-44b8-a5f3-f51c2cfe6ce4-000000@amazonses.com designates 54.240.9.36 as permitted sender) client-ip=54.240.9.36;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=Unvl08o3;
       spf=pass (google.com: domain of 01000168f1d25e3a-2857236c-a7cc-44b8-a5f3-f51c2cfe6ce4-000000@amazonses.com designates 54.240.9.36 as permitted sender) smtp.mailfrom=01000168f1d25e3a-2857236c-a7cc-44b8-a5f3-f51c2cfe6ce4-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1550245322;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=ieoA9G/W7FjMw2f/8b6ijric5X7WLHj4SWCwlIfIT3E=;
	b=Unvl08o3EUDCs5oYoOtJ8OdPcFc3nBgaouZGWhaSGZlU9kTY9eNGTON+3/0G29W6
	6pXPvYuHZZIEeICI7KLo9AEm2ZplYtKkKF+PsXj0PEPeb2H8EbZirMGy+OxsrEYPu3i
	2bZjBAUyQ6w+UfRWab+O9lfJretpOK2oDiEyOQPY=
Date: Fri, 15 Feb 2019 15:42:02 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Dave Chinner <david@fromorbit.com>
cc: Jerome Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@infradead.org>, 
    Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, 
    Jan Kara <jack@suse.cz>, Doug Ledford <dledford@redhat.com>, 
    Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org, 
    linux-rdma <linux-rdma@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
    Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
    John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving longterm-GUP
 usage by RDMA
In-Reply-To: <20190215011921.GS20493@dastard>
Message-ID: <01000168f1d25e3a-2857236c-a7cc-44b8-a5f3-f51c2cfe6ce4-000000@email.amazonses.com>
References: <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com> <20190208044302.GA20493@dastard> <20190208111028.GD6353@quack2.suse.cz> <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com> <20190211102402.GF19029@quack2.suse.cz>
 <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com> <20190211180654.GB24692@ziepe.ca> <20190214202622.GB3420@redhat.com> <20190214205049.GC12668@bombadil.infradead.org> <20190214213922.GD3420@redhat.com> <20190215011921.GS20493@dastard>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.15-54.240.9.36
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 15 Feb 2019, Dave Chinner wrote:

> Which tells us filesystem people that the applications are doing
> something that _will_ cause data corruption and hence not to spend
> any time triaging data corruption reports because it's not a
> filesystem bug that caused it.
>
> See open(2):
>
> 	Applications should avoid mixing O_DIRECT and normal I/O to
> 	the same file, and especially to overlapping byte regions in
> 	the same file.  Even when the filesystem correctly handles
> 	the coherency issues in this situation, overall I/O
> 	throughput is likely to be slower than using either mode
> 	alone.  Likewise, applications should avoid mixing mmap(2)
> 	of files with direct I/O to the same files.

Since RDMA is something similar: Can we say that a file that is used for
RDMA should not use the page cache?

And can we enforce this in the future? I.e. have some file state that says
that this file is direct/RDMA or contains long term pinning and thus
allows only a certain type of operations to ensure data consistency?

If we cannot enforce it then we may want to spit out some warning?

