Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA5BAC32753
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 18:19:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9665620644
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 18:19:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="HlM3xjHD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9665620644
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 141878E0006; Thu,  1 Aug 2019 14:19:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F3F08E0001; Thu,  1 Aug 2019 14:19:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFCC38E0006; Thu,  1 Aug 2019 14:19:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id B21258E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 14:19:56 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id y9so40114109plp.12
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 11:19:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=5iAUdcOxMFuCect8GbQj41Pg/Zzzg1Ipw+dm1mRuSp0=;
        b=nqn9IcYiGzi33bU2h1/Fj0ceIFINFmuKR5NCo8cmXQglegE7D7wHn5fm2wkQw1CtNj
         xazHTvt6/FfuVfxpu5fXp+g9ymnaePNO1FCzgO2bQPUTty2TBxae8f2Li3IzH607UKzq
         zldBlymuK/uqQ+B9fSqeQCM4QgLSFeu14fIwCSUSY+YG5bq0VGEWjeiANw0cp0J9jLhx
         POANgSrDpb0hKN37KnPfF2aX/M/1N+3l8hc2wWtYaQ5gmntu5mo0K4KEGWjjIrXRrIDP
         DGgCbD1rYHvq30ZFFNAL/cAsV8m9rrVxQPJmtp0jGjZ0nhJlvoXbCj2PdNGDIfEd+g86
         2yPA==
X-Gm-Message-State: APjAAAWyaybN6lOavwRl4yTqbDG8sYGTmq2xYi6W7lt7avYd42G9RVTL
	xlGVy3MyiLzam32A8qRtl5kw5Z6IO1hRJOuYfKc8Ph2tpd08XsD+n9W0/KUINhoEJ7qRbY11nB9
	+ktoRbezGNKdkP05/eaK1lubXbTl6+arqWdF3vOtt1YPbxDgIXafr3WQQfOr2Yg1AAw==
X-Received: by 2002:a17:90a:8985:: with SMTP id v5mr116169pjn.136.1564683596160;
        Thu, 01 Aug 2019 11:19:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5gDNM1yV3o+KSZ0BVLCYttoxtTXXaOoosgBylQopIlapjG7xZ80jJU2s3Ho5I9sLCGONT
X-Received: by 2002:a17:90a:8985:: with SMTP id v5mr116130pjn.136.1564683595470;
        Thu, 01 Aug 2019 11:19:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564683595; cv=none;
        d=google.com; s=arc-20160816;
        b=tRDXZWitLpWBz/66ZkgdpORW5Xs8Fejw9603U+T4T1tluDJZIrZeLfQKxEkeb1sIvQ
         LgeHCmX+zR51B0IYSJb54m6+amvLBeWQ/2w7IBgDzLAWcUUdjKjTRCLYbBFY6TobxwXN
         hTpsMkh9XLEkMhKVWcDkJCnnlyw6PaxJyqpvIOcPlEHv16bC575Y3GpxIFV/bFmeKORj
         dAfmd1fgCX9dKG5JheRcPx+0PVJrjEEA+Ck8T7VVqRevARm+/E5TIMDZXshNpDuN72Be
         b0bkzyxVW+1UR6wl/6qmePmGKnrU3a9No+NnWGe3Dmjmp7R9hbvZ3b9eD0/tkhCxCSqX
         NulQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=5iAUdcOxMFuCect8GbQj41Pg/Zzzg1Ipw+dm1mRuSp0=;
        b=h/bxyOt5dyJ25gPVNrFnF08sZQhPssDnA/NzH8i+DqpZFVyymUWfXGp6RMKDMklzUU
         GkIpK6RlUnGaLvGiKi1Q9Iy+NFg2pIBWPCt+whxyH9wb1ghDNmyO1bgsUrkilJCzdJg0
         Bj2ONxPMtr63xcG2/BMkQYFcw3RY7jQ9tIl9CS4BeqQJlarLNQAf6qiULqqfK7QEZZVS
         riF+ZLeXUm6vY19yU59fgyNyp1GymFg6ZXM7vmnCnFJvhCU9c+cv0F6XmeS+1VSpdjJQ
         rYWL6uFFK6k94jMPIeyVC3lDbti+2SF1iGot8Df6uJOFoUC1VGQVgFyrOmANL2nwoONs
         aQDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=HlM3xjHD;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c23si34791752pfr.8.2019.08.01.11.19.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 11:19:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=HlM3xjHD;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6429C20644;
	Thu,  1 Aug 2019 18:19:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564683594;
	bh=q+8ENR75Wy6t1l+2MP7lncHhAHQqOj5Ajtb+pAArq+E=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=HlM3xjHDnfgu7lCpxFF7/2BzBSM1XM0GtsPJAEmUfWWJJ7gKt0QaaSWHN17Uuk/fq
	 2dkuzuyXO0Bd8Twz7KMdE/VurZ/7pDM272K0QTEyne7qnWTy9o9IHGYocVBjUzOY0N
	 tjYmdI27Vi8b9ktGRAtYe2yk+mMYtSxiVxZcKFaQ=
Date: Thu, 1 Aug 2019 20:19:52 +0200
From: Greg KH <gregkh@linuxfoundation.org>
To: Masoud Sharbiani <msharbiani@apple.com>
Cc: mhocko@kernel.org, hannes@cmpxchg.org, vdavydov.dev@gmail.com,
	linux-mm@kvack.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: Possible mem cgroup bug in kernels between 4.18.0 and 5.3-rc1.
Message-ID: <20190801181952.GA8425@kroah.com>
References: <5659221C-3E9B-44AD-9BBF-F74DE09535CD@apple.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5659221C-3E9B-44AD-9BBF-F74DE09535CD@apple.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 11:04:14AM -0700, Masoud Sharbiani wrote:
> Hey folks,
> I’ve come across an issue that affects most of 4.19, 4.20 and 5.2 linux-stable kernels that has only been fixed in 5.3-rc1.
> It was introduced by
> 
> 29ef680 memcg, oom: move out_of_memory back to the charge path 
> 
> The gist of it is that if you have a memory control group for a process that repeatedly maps all of the pages of a file with  repeated calls to:
> 
>    mmap(NULL, pages * PAGE_SIZE, PROT_WRITE|PROT_READ, MAP_FILE|MAP_PRIVATE, fd, 0)
> 
> The memory cg eventually runs out of memory, as it should. However,
> prior to the 29ef680 commit, it would kill the running process with
> OOM; After that commit ( and until 5.3-rc1; Haven’t pinpointed the
> exact commit in between 5.2.0 and 5.3-rc1) the offending process goes
> into %100 CPU usage, and doesn’t die (prior behavior) or fail the mmap
> call (which is what happens if one runs the test program with a low
> ulimit -v value).
> 
> Any ideas on how to chase this down further?

Finding the exact patch that fixes this would be great, as then I can
add it to the 4.19 and 5.2 stable kernels (4.20 is long end-of-life, no
idea why you are messing with that one...)

thanks,

greg k-h

