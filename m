Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E822FC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 19:52:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 875DF222D0
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 19:52:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="wLQSK0O2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 875DF222D0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E833B8E0002; Wed, 13 Feb 2019 14:52:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E0C0B8E0001; Wed, 13 Feb 2019 14:52:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFBB28E0002; Wed, 13 Feb 2019 14:52:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8D4A78E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 14:52:36 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id t6so2407101pgp.10
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 11:52:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=2f1lFodsSgzmJKSkAYwuY3dpy4ATVGq6St5kDfLoRtY=;
        b=k81qi2q207FgN/ifTFyvADqTyVFGXqKsZDTHRoYOlnvrz21zcDK2y2vGK4We6RD5ij
         EjJrPr7kBUiJSIYLVhsmv2PsiwsCz3iIzXygREc7LxZ2GT1NbJ52A6dXbKIB98Ug1TSv
         TNJQLIaUZyAiHbnstJuhRdVp+0Ss8qSjTAX1SYDg6QRa1n4Wx8TTuL+eGmCFY6VUkpbi
         s+k+/ing7KqOwg/jpgm3C7+bNrXswpTFUxUAWuwcF1MlwcxeGBOOzMW1BB80xeP3Iyd0
         aRdPcGSk/gszW4mv0pgkwKBOfQYXIZvcG++kLtkVrt8nqfQlGM9FtnCWBwVsfO1nNt+8
         RJXQ==
X-Gm-Message-State: AHQUAuYLeb+39Z13j4Z/RfdCiPs7xR7tDZr7yRPh0pzMs6PZ57WV8OyZ
	hrh8Gt9aYooRqZO84Io1ANrnaM2q1CbkHWwCaPRyKOUQZr68KwrbzQxiHxT7uaXGRsaHQhIaZSo
	svvJVNhL1v1zksz4yxk72U/xHyZF3czFxclIokFvXedwajXVbBUY3J0Lstx9nv6c=
X-Received: by 2002:a62:4bd5:: with SMTP id d82mr2038616pfj.85.1550087556248;
        Wed, 13 Feb 2019 11:52:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbKIVr0/BuGKZ8SGNDqMD+Htw41t4MzHUa8f9oZ0k3JkaHXV3xjYcWoHzLazcbdQICfm8zD
X-Received: by 2002:a62:4bd5:: with SMTP id d82mr2038562pfj.85.1550087555387;
        Wed, 13 Feb 2019 11:52:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550087555; cv=none;
        d=google.com; s=arc-20160816;
        b=L5lWIck9jfHHMICrpAyMfqeUtnsf9NfAR2URS3fn4lqalzdKkxynKA1IE8WCoGLB6T
         t00OUi6tiveB+0d0/WKy2xF22HmQFctTJ+Vww450AQ9Kj4R6aYaOLgFGeS1DgBQaSNcl
         VgvroLeXNDqchF1ZMETUsdcGznMOA+Z/cDBJqe4hzJb9+5ATBkFdMnVa8Rl6uxZYiMU8
         sdJ8+vFq5BdvKeasHyWutu8wanB2lYjWi6l5QII9mLCpFFVCu2K+s/uPoBSztUkm1jkM
         +dIOzTfU20bMyqbvmLCwRVwMC1rr+/zgbzwluOgZEAOwSGQagTI4f8e//8xfDSEWRcNG
         w30g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=2f1lFodsSgzmJKSkAYwuY3dpy4ATVGq6St5kDfLoRtY=;
        b=g2mseJN/Th358jc65DIwod5TYHGZ1hDxtNeYt9rhZVuVoVaKZM/2l3WqZJBIJFrxS9
         vNi8J90jRwp5dMrhuZOURu0vLzcuPMBNqEvCs1g6xQc8YRqlkrDUDm+Ax7bSwjK/1+wF
         SSEm6EHeuCIKe9kTTUjDv+tcEzQlbeuRaeM6+u6r3EcuoPXOMGUwtOUchXisOB9JUcr9
         DUamIdjytlQxl/b9PhonwBxVRwZUywzdJ+UArMzeQK1cBOSmtxUflVPA7eUSQOEUbGk3
         uKmY8ztR+xI6rJBnrrSWFIHvVGULaotw261S/qD73xh2vQ+2l7FD/eY62mvyeq6/l2t1
         7+wA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=wLQSK0O2;
       spf=pass (google.com: domain of srs0=8kuc=qu=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=8KUc=QU=linuxfoundation.org=gregkh@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d14si160339pgn.390.2019.02.13.11.52.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 11:52:35 -0800 (PST)
Received-SPF: pass (google.com: domain of srs0=8kuc=qu=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=wLQSK0O2;
       spf=pass (google.com: domain of srs0=8kuc=qu=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=8KUc=QU=linuxfoundation.org=gregkh@kernel.org"
Received: from localhost (5356596B.cm-6-7b.dynamic.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7A3E2222D0;
	Wed, 13 Feb 2019 19:52:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550087555;
	bh=QPejU1nGrklF7jDizGBjyiGrwlYJaw0zDwsmtyviJMw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=wLQSK0O2xlZnT8wJXZOUBFdQqO7UePZ5A18ViCuRUzPEfsk9BViBVbFcu7TJYzAIP
	 OYdioetc94BDZEXy7TG3isjRJz5nwKtj/8lsH2cZM2T7fyS1p7CNQJGt2BSEumDLhs
	 wMLq7YZsaokSPjRFfREA6ZMUROGf6jlyXAi2K4+0=
Date: Wed, 13 Feb 2019 20:52:32 +0100
From: Greg KH <gregkh@linuxfoundation.org>
To: Sasha Levin <sashal@kernel.org>
Cc: Amir Goldstein <amir73il@gmail.com>, Steve French <smfrench@gmail.com>,
	lsf-pc@lists.linux-foundation.org,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	"Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [LSF/MM TOPIC] FS, MM, and stable trees
Message-ID: <20190213195232.GA10047@kroah.com>
References: <20190212170012.GF69686@sasha-vm>
 <CAH2r5mviqHxaXg5mtVe30s2OTiPW2ZYa9+wPajjzz3VOarAUfw@mail.gmail.com>
 <CAOQ4uxjMYWJPF8wFF_7J7yy7KCdGd8mZChfQc5GzNDcfqA7UAA@mail.gmail.com>
 <20190213073707.GA2875@kroah.com>
 <CAOQ4uxgQGCSbhppBfhHQmDDXS3TGmgB4m=Vp3nyyWTFiyv6z6g@mail.gmail.com>
 <20190213091803.GA2308@kroah.com>
 <20190213192512.GH69686@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213192512.GH69686@sasha-vm>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 02:25:12PM -0500, Sasha Levin wrote:
> On Wed, Feb 13, 2019 at 10:18:03AM +0100, Greg KH wrote:
> > On Wed, Feb 13, 2019 at 11:01:25AM +0200, Amir Goldstein wrote:
> > > Best effort testing in timely manner is good, but a good way to
> > > improve confidence in stable kernel releases is a publicly
> > > available list of tests that the release went through.
> > 
> > We have that, you aren't noticing them...
> 
> This is one of the biggest things I want to address: there is a
> disconnect between the stable kernel testing story and the tests the fs/
> and mm/ folks expect to see here.
> 
> On one had, the stable kernel folks see these kernels go through entire
> suites of testing by multiple individuals and organizations, receiving
> way more coverage than any of Linus's releases.
> 
> On the other hand, things like LTP and selftests tend to barely scratch
> the surface of our mm/ and fs/ code, and the maintainers of these
> subsystems do not see LTP-like suites as something that adds significant
> value and ignore them. Instead, they have a (convoluted) set of testing
> they do with different tools and configurations that qualifies their
> code as being "tested".
> 
> So really, it sounds like a low hanging fruit: we don't really need to
> write much more testing code code nor do we have to refactor existing
> test suites. We just need to make sure the right tests are running on
> stable kernels. I really want to clarify what each subsystem sees as
> "sufficient" (and have that documented somewhere).

kernel.ci and 0-day and Linaro are starting to add the fs and mm tests
to their test suites to address these issues (I think 0-day already has
many of them).  So this is happening, but not quite obvious.  I know I
keep asking Linaro about this :(

Anyway, just having a list of what tests each subsystem things is "good
to run" would be great to have somewhere.  Ideally in the kernel tree
itself, as that's what kselftests are for :)

thanks,

greg k-h

