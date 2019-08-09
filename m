Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B837CC31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:17:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7845F2166E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:17:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="M0Yq6MHA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7845F2166E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E91EA6B0005; Fri,  9 Aug 2019 18:17:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E43246B0006; Fri,  9 Aug 2019 18:17:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D31146B0007; Fri,  9 Aug 2019 18:17:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9C6AF6B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 18:17:21 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 145so62350626pfv.18
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 15:17:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UBTRxGqqf4dX5g2SlS3jqNIddApVyXkNPQNLT2Ez+0U=;
        b=M2gJDp0lW13dmycLRSzH3fRmZULGhmRpy6KSvzTikjes+5NvpZ3ouxOtUcFmO3eSfq
         7hp8kzL279g2cLjhYQSxV99naRzrq6OgGwPWL+sDBscBQhZCZNuwjwFyLaO7nAscsbtI
         Lsqf/z4EsmR/+lzUecjCeZpT3p6tMJABvjW3S22r4jR6+77T0ffNiGeeWBqm54tRer9G
         pFsfsvCHKervBc2zruDpmkQnigqRnXRzlLs4XXdSyAgf2ENLLTA0KTD16U/1NjiIeFV0
         RgaKTW0URcaJK10u1/iTBt5cFhqW5jVwlZ+60JrJ0hwdJ/6F3zfaF6GeXY95m7nmxcES
         nxQQ==
X-Gm-Message-State: APjAAAWQkEr/box4U04NX40q/J8qyk+Jfmv5gmBCesfQ26FBe+MvRljf
	GEXW9MHO7HXg86knkxYvC2JL4cQy+qN3jgxty/5KHkiOcwMgM1ZaMbF85W5AVklnTJCwVWDpBcZ
	dXvcAJ+gNOfH2a97s3U3UOz5VOQKpBODI0F54yXmXc3uiF613aRKkJUbhsXfm5UETog==
X-Received: by 2002:a17:902:be12:: with SMTP id r18mr20238643pls.341.1565389041286;
        Fri, 09 Aug 2019 15:17:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrC8AO8q9Jj2qWXPRz2TlR5+ZSM72dhhZ9wB0jjC3Vtqm01RIoJp7r/xvfjTLhxbcPLPTJ
X-Received: by 2002:a17:902:be12:: with SMTP id r18mr20238588pls.341.1565389040186;
        Fri, 09 Aug 2019 15:17:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565389040; cv=none;
        d=google.com; s=arc-20160816;
        b=L8YiVCdxI1lfpLuTwPzTsJa3V3XGGQ+tWjgt8qsPccyAknxiB+e7V39bRpM/rruQJG
         AiNGZtq3irNu3S4Rod9PuxAjaGFlx7H3VwhiamtsBJuKVu/k2tv1/nfWaLkqnmzGeR1K
         kIKZ9ZR5eZO8fhBjyx2NvGgZ3zFCYy1DZ79rlR8aWZ4u3nL2+Lw29Pg+o8q9M35JoTCH
         TN45ar0+xs1UR2xIGL/DP6ul5MiZAvVFMxyEnio6ogqtF47T7gzh1P+btWvdi04zTaYu
         pqVuc5PVUistw+5UCwZNIrEvvPyZTOomfBfSyoDQD0JqUCstrGloh9GRoUdpaH2ccfpY
         epPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=UBTRxGqqf4dX5g2SlS3jqNIddApVyXkNPQNLT2Ez+0U=;
        b=oe9TsiU9V4gfef4kteTKSFZSmuBFWi6wWr8FOxQI16KT8MlCMzmRSp5JDDQKMAhqNs
         EwWcbX17wYrWOBowjWyBDNdEHClVbgkZVTYihCqjcrlirseNB17/ALP69Jd9CLaEz6Fc
         QhjG+ZEvWvnPLUpPqx8jgCPqqaqxcASjLZEQ8lPcfcq0kPGufHc9iOF+kwwi95HgUIdh
         4oFugmNg3RuaiET4O8ZwhDGljykdC9+b8sKl4mOnEcXojsKSkxCwKySd/kijDfgdBuTM
         58ZkQjj8SvcMIDeRCsytrIzLze/rXx/MLjfK4G3qNl4mgPF3BnBgNh4iKD54B1Lm/jIU
         KM7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=M0Yq6MHA;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s24si3444131pgq.372.2019.08.09.15.17.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 15:17:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=M0Yq6MHA;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8646B20C01;
	Fri,  9 Aug 2019 22:17:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565389039;
	bh=sBCc7FSNFhlnRsGYMaaCt24naPV+9JGWf4SdSDBpZSQ=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=M0Yq6MHAY53t1ncV64OxCpQqedn+WGq7kUdkHQs/u4ha4+lqiISH5b3bRrmIog8Wt
	 o8ciIYK8TbwhCQwuiXofvHPxI9UqaGaq0sdOWGr5Xetzut3rRRFlbp/2r5gMkvzC1m
	 KsxqJdOSCt+CD15CCLeCix6toLaH2Y6YVAvmk3DQ=
Date: Fri, 9 Aug 2019 15:17:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, ltp@lists.linux.it, Li Wang
 <liwang@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Cyril
 Hrubis <chrubis@suse.cz>, xishi.qiuxishi@alibaba-inc.com, Sasha Levin
 <sashal@kernel.org>
Subject: Re: [PATCH] hugetlbfs: fix hugetlb page migration/fault race
 causing SIGBUS
Message-Id: <20190809151718.d285cd1f6d0f1cf02cb93dc8@linux-foundation.org>
In-Reply-To: <20190809064633.GK18351@dhcp22.suse.cz>
References: <20190808000533.7701-1-mike.kravetz@oracle.com>
	<20190808074607.GI11812@dhcp22.suse.cz>
	<20190808074736.GJ11812@dhcp22.suse.cz>
	<416ee59e-9ae8-f72d-1b26-4d3d31501330@oracle.com>
	<20190808185313.GG18351@dhcp22.suse.cz>
	<20190808163928.118f8da4f4289f7c51b8ffd4@linux-foundation.org>
	<20190809064633.GK18351@dhcp22.suse.cz>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 9 Aug 2019 08:46:33 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> > Maybe we should introduce the Fixes-no-stable: tag.  That should get
> > their attention.
> 
> No please, Fixes shouldn't be really tight to any stable tree rules. It
> is a very useful indication of which commit has introduced bug/problem
> or whatever that the patch follows up to. We in Suse are using this tag
> to evaluate potential fixes as the stable is not reliable. We could live
> with Fixes-no-stable or whatever other name but does it really makes
> sense to complicate the existing state when stable maintainers are doing
> whatever they want anyway? Does a tag like that force AI from selecting
> a patch? I am not really convinced.

It should work if we ask stable trees maintainers not to backport
such patches.

Sasha, please don't backport patches which are marked Fixes-no-stable:
and which lack a cc:stable tag.

