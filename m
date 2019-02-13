Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5C29C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 20:14:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90330222AC
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 20:14:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="xI+srN6X"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90330222AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=HansenPartnership.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 266CB8E0002; Wed, 13 Feb 2019 15:14:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 215BF8E0001; Wed, 13 Feb 2019 15:14:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DF7E8E0002; Wed, 13 Feb 2019 15:14:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id D64758E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 15:14:40 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id b8so2126723ywb.17
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 12:14:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=zUi3bbK09oyChFQKYzO9PYVuOwCnfm1vrHavwgrvpKI=;
        b=aQuum1yyk8gNfB+z6fA3msePd6A7DaIsWztBENMHXzAjviFE5lyXePV9mg25sByPd8
         PbS8dp0swQimngbFU+d90kAGBIQeEO/Mqk5qklelwj7VNv0inrb4pUav0Ju9/qZQ4PHB
         KNuYVTPBh8BRAOIXzW5JPabppDEn3wooHZW2YkSqgio7cyH6qIUzblGVOBe16AmggHAf
         pLKU4BSoxOLjGaYFpjKf8IypdjYqh/BJV0kT5kXzGTZsNE1jV8pYlGipn14Y7hijQJhi
         hVHEndKfm1ur+qcKwojRHWnrnlGdal7gFV4IbZiqEh8MxECobkkb507wg4yK7/srJw7y
         1jpg==
X-Gm-Message-State: AHQUAuZ7hFL2fcnzBlAoH76HQc+jtR8I1Ty2fx2oqx2jSdJl0HTj43pg
	1e7KufB+Jlkm+d80IviWJatRAscEGyqkH6+nKcoilHe0fBRA9WV0WW3HU+mz7joHLeJ59Ep50xp
	yLvGv5rXErIb3OZS0/1G6c9olIuuZAY9OpdC3Hh9nqaTf4PTrK4TcwILts76YYLmrTA==
X-Received: by 2002:a25:1687:: with SMTP id 129mr2278229ybw.11.1550088880473;
        Wed, 13 Feb 2019 12:14:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYo82PYgvNn8NvHcux2SnkZbParLLV2GjtK4PPKwpckmLNvKw4rNkt1kOV0b4t9snwR2UFo
X-Received: by 2002:a25:1687:: with SMTP id 129mr2278168ybw.11.1550088879614;
        Wed, 13 Feb 2019 12:14:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550088879; cv=none;
        d=google.com; s=arc-20160816;
        b=FgPfG6qIdGW2qRfChgXLflSBG9qG/iMBSZo48yv6rtm8dGfQBI0WheqRVT7GhsTzIj
         6XqmDdQKLgAkWWZiDBAn3SQERhjThkobykd/Qqoz6/fQwoyBliopM/xuyJhY8FAAoHsd
         5VnZrONqrDV+azlGD6+uFC/4kuCOGVinyCiNzxgKRLAqSwaEdE/XCvBog4eH/dvOzGDQ
         ddqSQ+4iDWGHBS/G81rNXBXcNyo7IK8FIyofGeVADTwhvib6fGPYOLa7ulg399V9fgFs
         zhf2yameHGRZZjHxrQBsJbU/2rRn1nv9as+1b5wyB41fLr68pVRoE/16h00uXCd3nN+w
         WaaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=zUi3bbK09oyChFQKYzO9PYVuOwCnfm1vrHavwgrvpKI=;
        b=FAmBLhC0AT/U07OmapgjEjEdGxnox4cv9UkwbaLXc8+IewXzf8wtbmqFWeavx+BczW
         fHxb2Kq3DXEC0Ug7GkSfeXQ2VnNhV8CtU5qhpxMV0+G4LHmKqCrXJHC2Csnzf0c8nb6q
         rHEjyHzYlRsd3A5H1NpJ6Hs/TvkxrQZfqoUCg9kczfT51fTxPUlTeKgOpKWgoiEkp3as
         NQtlZUuETBBtog7xDSLPSOVz07r8onfeU541LDzshqKWzdrUICx0UH4NX97io4Z8ZZe3
         CCxKbXWLHFv2SoulYwvbpoysRZWl/hiAzV/Z8skGmfg9A6vev0YDHWnoHXZAzD4c28CB
         v5KQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=xI+srN6X;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id 132si159232ywe.163.2019.02.13.12.14.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 12:14:39 -0800 (PST)
Received-SPF: pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) client-ip=66.63.167.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=xI+srN6X;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from localhost (localhost [127.0.0.1])
	by bedivere.hansenpartnership.com (Postfix) with ESMTP id ED5328EE241;
	Wed, 13 Feb 2019 12:14:37 -0800 (PST)
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
	by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id AHExg__6OIgB; Wed, 13 Feb 2019 12:14:37 -0800 (PST)
Received: from [153.66.254.194] (unknown [50.35.68.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id 1BE5D8EE177;
	Wed, 13 Feb 2019 12:14:37 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1550088877;
	bh=0InwHf7+mURVAKyXEaQpqNoLecFzymNi+/Deb4eyYCc=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=xI+srN6XtRVUQAx4e28wl7kirjboFHpZ7AE+H2UKiiuaetc074za9B9XQv3rDJqXj
	 qBiHpjBkDkyl63ykUhla4gL9N508Z74ZNDmKZPLfAsUciZ8WMNP9+jai4E1OS9PDi0
	 Iy555aTJ+F1dD7WuoArKQlZ86W98wsqelbEYJvGc=
Message-ID: <1550088875.2871.21.camel@HansenPartnership.com>
Subject: Re: [LSF/MM TOPIC] FS, MM, and stable trees
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Greg KH <gregkh@linuxfoundation.org>, Sasha Levin <sashal@kernel.org>
Cc: Amir Goldstein <amir73il@gmail.com>, Steve French <smfrench@gmail.com>, 
 lsf-pc@lists.linux-foundation.org, linux-fsdevel
 <linux-fsdevel@vger.kernel.org>,  linux-mm <linux-mm@kvack.org>, LKML
 <linux-kernel@vger.kernel.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Wed, 13 Feb 2019 12:14:35 -0800
In-Reply-To: <20190213195232.GA10047@kroah.com>
References: <20190212170012.GF69686@sasha-vm>
	 <CAH2r5mviqHxaXg5mtVe30s2OTiPW2ZYa9+wPajjzz3VOarAUfw@mail.gmail.com>
	 <CAOQ4uxjMYWJPF8wFF_7J7yy7KCdGd8mZChfQc5GzNDcfqA7UAA@mail.gmail.com>
	 <20190213073707.GA2875@kroah.com>
	 <CAOQ4uxgQGCSbhppBfhHQmDDXS3TGmgB4m=Vp3nyyWTFiyv6z6g@mail.gmail.com>
	 <20190213091803.GA2308@kroah.com> <20190213192512.GH69686@sasha-vm>
	 <20190213195232.GA10047@kroah.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-02-13 at 20:52 +0100, Greg KH wrote:
> On Wed, Feb 13, 2019 at 02:25:12PM -0500, Sasha Levin wrote:
> > On Wed, Feb 13, 2019 at 10:18:03AM +0100, Greg KH wrote:
> > > On Wed, Feb 13, 2019 at 11:01:25AM +0200, Amir Goldstein wrote:
> > > > Best effort testing in timely manner is good, but a good way to
> > > > improve confidence in stable kernel releases is a publicly
> > > > available list of tests that the release went through.
> > > 
> > > We have that, you aren't noticing them...
> > 
> > This is one of the biggest things I want to address: there is a
> > disconnect between the stable kernel testing story and the tests
> > the fs/ and mm/ folks expect to see here.
> > 
> > On one had, the stable kernel folks see these kernels go through
> > entire suites of testing by multiple individuals and organizations,
> > receiving way more coverage than any of Linus's releases.
> > 
> > On the other hand, things like LTP and selftests tend to barely
> > scratch the surface of our mm/ and fs/ code, and the maintainers of
> > these subsystems do not see LTP-like suites as something that adds
> > significant value and ignore them. Instead, they have a
> > (convoluted) set of testing they do with different tools and
> > configurations that qualifies their code as being "tested".
> > 
> > So really, it sounds like a low hanging fruit: we don't really need
> > to write much more testing code code nor do we have to refactor
> > existing test suites. We just need to make sure the right tests are
> > running on stable kernels. I really want to clarify what each
> > subsystem sees as "sufficient" (and have that documented
> > somewhere).
> 
> kernel.ci and 0-day and Linaro are starting to add the fs and mm
> tests to their test suites to address these issues (I think 0-day
> already has many of them).  So this is happening, but not quite
> obvious.  I know I keep asking Linaro about this :(

0day has xfstests at least, but it's opt-in only (you have to request
that it be run on your trees).  When I did it for the SCSI tree, I had
to email Fenguangg directly, there wasn't any other way of getting it.

James

