Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AA76C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 02:48:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DCAD62192B
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 02:48:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="SpFC1bFl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DCAD62192B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=HansenPartnership.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89FCA8E0002; Thu, 14 Feb 2019 21:48:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 84F208E0001; Thu, 14 Feb 2019 21:48:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 73D0C8E0002; Thu, 14 Feb 2019 21:48:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4BFE58E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 21:48:28 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id 187so2831320ybv.0
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 18:48:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=mA47N9RI4NsC4pjiCAz5GmHFekzmXDKJNXH8el/LXmg=;
        b=pfi+dZSqZ1ukkLvh/UA6VaIvw/k65DlFE2Ads2JP3FERdHx6FGzwt9yEARMGMMvgdg
         Z6rYuWOCnvWRgQmAMwC4ItnoA0UZHT/tZHv1ZkZexVfEiSC1+HUJX5LTnSb5fmntyjEq
         88SC6n65fmvxKdOoZveK4FpF8+EA0Wc3TQW7NicvDze/JwWy5GZeBFJ4cHOFMxnEDYDE
         ftuHUPfRPU5GDH8PD2K05eKXFkHRTqN+bmHP2NiMPucJ8nN2yv9wCNMmQBEJpkrDi84v
         2FfW1qL/neXoEKNs5fB7ZY5z40ygTOib1q7Strienq+chH8q3uGAVMIzXcwANMI1wfrf
         oytA==
X-Gm-Message-State: AHQUAuaN6Mv1q/4iG29hS+HPPHLTZJWwblNEYS08gQ1FFCeDfyhuPZBE
	K5HVFM8u9SPpm0nOBX+4WiGGzjsbLfplxd0GHcV/rqDM/GOQOY4zVntw+KarqU6mBC/AmoCF9jR
	mDf6/xRq7d5pypCWfLg1emm6rE+UDNCtLkEzKL50M+zCqPDfIXpSNz6+XHaltOLjeiQ==
X-Received: by 2002:a0d:cc89:: with SMTP id o131mr6257251ywd.144.1550198907897;
        Thu, 14 Feb 2019 18:48:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaWs7ww0EYKvXuUkLQ70/zSUdIxv1rpkY1907AIQvg/jYBysdJQEHwrtN9LJsXRbOyNTAFF
X-Received: by 2002:a0d:cc89:: with SMTP id o131mr6257221ywd.144.1550198907129;
        Thu, 14 Feb 2019 18:48:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550198907; cv=none;
        d=google.com; s=arc-20160816;
        b=OMm2JfQjhLcAIye+th7KlRvFE78yqiaf5CMj4MfA8jsRC7aj6asCOMLDovRnb4y/oF
         WIv0QYCGb69pSbT3gWG7dF+n5R1PrTOvd2MX9FYCmuhuXqjpsGSOzAaCdXnnrU04Iozg
         54522ZGWAOHt/UJ31L/NIc91A+HUoXXvieRysrXb+MD+li+5Xp/O4LkEJ4nBhCwxNQ8o
         OSZkZdb8+GicwDqua4l9yvg97XohY8w64eUOJgMal+7BuDOaHPrcqL3D9ExQHVdQJbUe
         ByQONvinRKwwpZtfumBvOKF66hXfU+XLAgcuJhXk4YTWDUFRsvo+W6lH81pGr7yzhD5+
         ZzRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=mA47N9RI4NsC4pjiCAz5GmHFekzmXDKJNXH8el/LXmg=;
        b=s5QiC2ecef0xEggYb4PO5gYhQ95Y9K9CBbhxLl4q5JyPi+rKZ4wWXEilH+/WZrJQRL
         tzepR7sZgHF9kYC32Sp8T9528B9tpersPqv7OgVMNSf4NDYXVWCK6sqj4zc+UsthXAkB
         MRnRZ9JvFss0N5Q0k0Ua5GDDn45hwlh5BbBAlTCS/NyKqpbif5kCVLMixPnGoZdUNjYQ
         aj79RIqnzvvexhlXYyTZF4s800AGOZ1hmQCO2eXZ3qN69Qjbex8bkQJfbKVARxgCGjCb
         ssQUEOg0BCiCQp3mEintD+S8HUjtE6QZa3RI2U9zSuW98Hlg/v0UpYVBf8NFBHag+Sli
         do6w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=SpFC1bFl;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id o17si2477297ybk.203.2019.02.14.18.48.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 14 Feb 2019 18:48:26 -0800 (PST)
Received-SPF: pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) client-ip=66.63.167.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=SpFC1bFl;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from localhost (localhost [127.0.0.1])
	by bedivere.hansenpartnership.com (Postfix) with ESMTP id AE46F8EE23E;
	Thu, 14 Feb 2019 18:48:25 -0800 (PST)
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
	by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id NfGbFDjpEDAs; Thu, 14 Feb 2019 18:48:25 -0800 (PST)
Received: from [153.66.254.194] (unknown [50.35.68.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id E51118EE15F;
	Thu, 14 Feb 2019 18:48:24 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1550198905;
	bh=Hdt5XqqSkBX1Pp/GVYTeN07WE45/gKKk88sNDiiMCbo=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=SpFC1bFlZbQaa6sggFEA2tXgWD2xOZyDuweLFKBKXQchgqCBqxBWwsqozGYcUxGRt
	 jMK0Hfy390lHbfHrXbt2c41ANfGSHXqxcUrkwnHF/GL+zciae68S1FhYwya2P6vCDP
	 KhYsEUucEmjYurFcGWZ3qW7bRXY7uJsXVydw/d8E=
Message-ID: <1550198902.2802.12.camel@HansenPartnership.com>
Subject: Re: [LSF/MM TOPIC] FS, MM, and stable trees
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Sasha Levin <sashal@kernel.org>
Cc: Greg KH <gregkh@linuxfoundation.org>, Amir Goldstein
 <amir73il@gmail.com>,  Steve French <smfrench@gmail.com>,
 lsf-pc@lists.linux-foundation.org, linux-fsdevel
 <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, LKML
 <linux-kernel@vger.kernel.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Thu, 14 Feb 2019 18:48:22 -0800
In-Reply-To: <20190215015020.GJ69686@sasha-vm>
References: <20190212170012.GF69686@sasha-vm>
	 <CAH2r5mviqHxaXg5mtVe30s2OTiPW2ZYa9+wPajjzz3VOarAUfw@mail.gmail.com>
	 <CAOQ4uxjMYWJPF8wFF_7J7yy7KCdGd8mZChfQc5GzNDcfqA7UAA@mail.gmail.com>
	 <20190213073707.GA2875@kroah.com>
	 <CAOQ4uxgQGCSbhppBfhHQmDDXS3TGmgB4m=Vp3nyyWTFiyv6z6g@mail.gmail.com>
	 <20190213091803.GA2308@kroah.com> <20190213192512.GH69686@sasha-vm>
	 <20190213195232.GA10047@kroah.com>
	 <1550088875.2871.21.camel@HansenPartnership.com>
	 <20190215015020.GJ69686@sasha-vm>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-02-14 at 20:50 -0500, Sasha Levin wrote:
> On Wed, Feb 13, 2019 at 12:14:35PM -0800, James Bottomley wrote:
> > On Wed, 2019-02-13 at 20:52 +0100, Greg KH wrote:
> > > On Wed, Feb 13, 2019 at 02:25:12PM -0500, Sasha Levin wrote:
> > > > On Wed, Feb 13, 2019 at 10:18:03AM +0100, Greg KH wrote:
> > > > > On Wed, Feb 13, 2019 at 11:01:25AM +0200, Amir Goldstein
> > > > > wrote:
> > > > > > Best effort testing in timely manner is good, but a good
> > > > > > way to improve confidence in stable kernel releases is a
> > > > > > publicly available list of tests that the release went
> > > > > > through.
> > > > > 
> > > > > We have that, you aren't noticing them...
> > > > 
> > > > This is one of the biggest things I want to address: there is a
> > > > disconnect between the stable kernel testing story and the
> > > > tests the fs/ and mm/ folks expect to see here.
> > > > 
> > > > On one had, the stable kernel folks see these kernels go
> > > > through entire suites of testing by multiple individuals and
> > > > organizations, receiving way more coverage than any of Linus's
> > > > releases.
> > > > 
> > > > On the other hand, things like LTP and selftests tend to barely
> > > > scratch the surface of our mm/ and fs/ code, and the
> > > > maintainers of these subsystems do not see LTP-like suites as
> > > > something that adds significant value and ignore them. Instead,
> > > > they have a (convoluted) set of testing they do with different
> > > > tools and configurations that qualifies their code as being
> > > > "tested".
> > > > 
> > > > So really, it sounds like a low hanging fruit: we don't really
> > > > need to write much more testing code code nor do we have to
> > > > refactor existing test suites. We just need to make sure the
> > > > right tests are running on stable kernels. I really want to
> > > > clarify what each subsystem sees as "sufficient" (and have that
> > > > documented somewhere).
> > > 
> > > kernel.ci and 0-day and Linaro are starting to add the fs and mm
> > > tests to their test suites to address these issues (I think 0-day
> > > already has many of them).  So this is happening, but not quite
> > > obvious.  I know I keep asking Linaro about this :(
> > 
> > 0day has xfstests at least, but it's opt-in only (you have to
> > request that it be run on your trees).  When I did it for the SCSI
> > tree, I had to email Fenguangg directly, there wasn't any other way
> > of getting it.
> 
> It's very tricky to do even if someone would just run it.

It is?  It's a test suite, so you just run it and it exercises standard
and growing set of regression tests.

>  I worked with the xfs folks for quite a while to gather the various
> configs they want to use, and to establish the baseline for a few of
> the stable trees (some tests are know to fail, etc).

The only real config issue is per-fs non-standard tests (features
specific to a given filesystem).  I just want it to exercise the
storage underneath, so the SCSI tree is configured for the default set
on xfs.

> So just running xfstests "blindly" doesn't add much value beyond ltp
> I think.

Well, we differ on the value of running regression tests, then.  The
whole point of a test infrastructure is that it's simple to run 'make
check' in autoconf parlance.  xfstests does provide a useful baseline
set of regression tests.  However, since my goal is primarily to detect
problems in the storage path rather than the filesystem, the utility is
exercising that path, although I fully appreciate that filesystem
regression tests aren't going to catch every SCSI issue, they do
provide some level of assurance against bugs.

Hopefully we can switch over to blktests when it's ready, but in the
meantime xfstests is way better than nothing.

James

