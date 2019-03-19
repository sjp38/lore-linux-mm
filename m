Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B855EC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 16:40:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78C0720700
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 16:40:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78C0720700
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0758D6B0005; Tue, 19 Mar 2019 12:40:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0274F6B0006; Tue, 19 Mar 2019 12:40:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E57FD6B0007; Tue, 19 Mar 2019 12:40:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id ADE886B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 12:40:10 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 33so19697pgv.17
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 09:40:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=jh21C47itlJwh4vEjICHSh55rkLPcqv5wnXS0CNc4NI=;
        b=sqlHcWNAiLFlMKmrh7Ij6bFBTRodWk8+T1J4N0N1XgV6ZSQNtyXur2QLBCFeixmBtZ
         8+L4FBi+Oud8yLVmXU+DvER7B+QCvCoeN8Nh3ax+YaRVphr2ZxjHx4QJSMTwVUSxWWLt
         HVwfdeIZdP0Yg4C+z/XE184Bc92E2tEUf3q3Tg8lM+6lnyP6fv8PrCzhFWQJAHVeHVye
         JRWG/i2Y59pFODKE+1gXeUR14G365KCAYjaHrYEk7+qpEK6/SRoF9uQkXiIbpkLIMKat
         GmDxosDK2WccS0/QMCqOg/+oW0ouhQhKg0eNhqTzmWOc9J5YT7VvwypRjGQUKGJsiqRz
         wF3A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAVhuAym5lmMJzVvswnVwAE80EFTCAyuEHmEv2dfSgzWnr1sNlrY
	9L2Lvxa12FhFw5x6awaURovzMkMD9+zueyKm519cYr8kr53uiEx8POnOn91qeaR4ZgVc7WfUeJS
	YkEMNPCNF2QVJXhAz8Aq7wa/MDrtLfKmaW+fb5kZjQEgvchWu/f9EKhkDC4UgKdfOVQ==
X-Received: by 2002:a65:64c3:: with SMTP id t3mr3081081pgv.14.1553013610265;
        Tue, 19 Mar 2019 09:40:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw1oOo+0HC/eGbDEMQ1w3jSrFgr8tV+gJjFkg0EdCzQAS+ERH5z4EiKfuWTZFNGCfqruvlU
X-Received: by 2002:a65:64c3:: with SMTP id t3mr3081020pgv.14.1553013609289;
        Tue, 19 Mar 2019 09:40:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553013609; cv=none;
        d=google.com; s=arc-20160816;
        b=sfJAN4oTgB6iYZT4D6k3eugEwZX4tYn6m8WcLCUsVIGpptoqSotlaG/VWhMnWKF8Ax
         ardMe5JBeo2Htwz+k/D0tu66yyp+m4rx7So93BHOZDsiu12kwvkh2+5BbXcOnjQjgbS+
         vrMrU3MUvi+TKl2RvI++kIJymvDqMSEhpFKAJp5mHl8OLBCoBy27Dl/ozyiRLi7RqTH/
         sKF2w2OrlVvn+AIsRYgHCynKXqwGAM80dBJ68eQLz79cPFjKR95l9//uhz571iRPAARZ
         K+KpyIenHNCcHFy0oa9EEGza5lktJDMk5pJG1DoBSENM96AMil4whl22YlcWIKkAZWi+
         pfMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=jh21C47itlJwh4vEjICHSh55rkLPcqv5wnXS0CNc4NI=;
        b=XWMW+9OSCb2HGdtdELwFvogul5iUP/MEJZOV9597+9RHFMeN/rX+0hDKRbkuEqfDZT
         Ubo667acGzU7uYMpSGSQ8VxtYa0AONb+Vz3f5Ip6xynWtRNvdHRn3Qh5njrrSNaktN+6
         REVxTlQQXDpq/YoRT0FMl8z6lfuNBdP5gG0nMTRY3ewFrMO75OKYbJFCjolIUcijacpX
         +NYJnx4490/CSmGMIdo3KZci66DnDdhlwGEa/CKBo9NX5ZUkM8TANsNYGcxYn6JOw21S
         9QfrlUL8xuA78bohTFUl2aQMgCceIsnJi49vG/V2Q4WvALCkYoooixU+dmi59DbL8LZJ
         zWzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 24si8287899pfp.261.2019.03.19.09.40.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 09:40:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 9FBC23A68;
	Tue, 19 Mar 2019 16:40:08 +0000 (UTC)
Date: Tue, 19 Mar 2019 09:40:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Felix Kuehling
 <Felix.Kuehling@amd.com>, Christian =?ISO-8859-1?Q?K=F6nig?=
 <christian.koenig@amd.com>, Ralph Campbell <rcampbell@nvidia.com>, John
 Hubbard <jhubbard@nvidia.com>, Jason Gunthorpe <jgg@mellanox.com>, Dan
 Williams <dan.j.williams@intel.com>, Alex Deucher
 <alexander.deucher@amd.com>
Subject: Re: [PATCH 00/10] HMM updates for 5.1
Message-Id: <20190319094007.a47ce9222b5faacec3e96da4@linux-foundation.org>
In-Reply-To: <20190318170404.GA6786@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
	<20190313012706.GB3402@redhat.com>
	<20190313091004.b748502871ba0aa839b924e9@linux-foundation.org>
	<20190318170404.GA6786@redhat.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 18 Mar 2019 13:04:04 -0400 Jerome Glisse <jglisse@redhat.com> wrote:

> On Wed, Mar 13, 2019 at 09:10:04AM -0700, Andrew Morton wrote:
> > On Tue, 12 Mar 2019 21:27:06 -0400 Jerome Glisse <jglisse@redhat.com> wrote:
> > 
> > > Andrew you will not be pushing this patchset in 5.1 ?
> > 
> > I'd like to.  It sounds like we're converging on a plan.
> > 
> > It would be good to hear more from the driver developers who will be
> > consuming these new features - links to patchsets, review feedback,
> > etc.  Which individuals should we be asking?  Felix, Christian and
> > Jason, perhaps?
> > 
> 
> So i am guessing you will not send this to Linus ?

I was waiting to see how the discussion proceeds.  Was also expecting
various changelog updates (at least) - more acks from driver
developers, additional pointers to client driver patchsets, description
of their readiness, etc.

Today I discover that Alex has cherrypicked "mm/hmm: use reference
counting for HMM struct" into a tree which is fed into linux-next which
rather messes things up from my end and makes it hard to feed a
(possibly modified version of) that into Linus.

So I think I'll throw up my hands, drop them all and shall await
developments :(

