Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F2D8C5B57D
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 05:09:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 38642218A6
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 05:09:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="P4OKl98f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 38642218A6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD3C06B0003; Fri,  5 Jul 2019 01:09:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A5DCD8E0003; Fri,  5 Jul 2019 01:09:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8FDDD8E0001; Fri,  5 Jul 2019 01:09:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5897E6B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 01:09:34 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 30so4889126pgk.16
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 22:09:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rUlpRwlMw/mZITZY8PcgrG5h7ypTn+NLVEPkd0zOJCs=;
        b=NRDrDNc63SHTsnR9iOnWxfzU/3NOhWorMpp+ZMQQJW4xufiF37Hvb6oEjamDOOVNIi
         dOAgLpuB7WEPBN76x0fqxNGaN5qNmyuy745wdbBjU2B+D1FZS24zU1z9DaKanYchoASC
         hFdQOtcwTXvT7F7renLaeAuyPWluCPobybyl5MlolwqNHgZhkKS1hCMVYlW4Is9jwmtm
         otjuudvuFDHGUToHgQIFlt0vGHy3fakfzgWpGHXpLrdWPPYFZfRofWtgu4hlpZHhsGKd
         0jIS9XX2GcF+ShdVED1CP3gdDM5gZ9awYZ3CFQF+pooQl49l7M61DHso0nYQPl/WJ/H5
         kNMA==
X-Gm-Message-State: APjAAAVart0+snwDY4z8Q0FHhhRqIHqhJoKosRZYSzdsvDg2b6KQtwM8
	1lxx2PlVWjwc14PZVZ5nSz1Y8xnJjXGTA+76V5o4xZXh5Lpf/TQdWprbAMuTVy5/JBRXnek+Z1V
	NGZHCW/vadLgIgIxeU4/M4OLF1F9rVS9c1u5B2Y88wsscO5ctPY78tYNVYxlXUlpsPg==
X-Received: by 2002:a17:90a:d151:: with SMTP id t17mr2306558pjw.60.1562303373854;
        Thu, 04 Jul 2019 22:09:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxEIl60I28t6OYhxvalrhKanoar+9w31/SkO9aiWsE8udZ0RWInOuL/c9j1DK0mMs6J6qHt
X-Received: by 2002:a17:90a:d151:: with SMTP id t17mr2306469pjw.60.1562303373042;
        Thu, 04 Jul 2019 22:09:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562303373; cv=none;
        d=google.com; s=arc-20160816;
        b=Sr//Hnbi84lWXGilgV0uGbmS3zGK3NDdUF3T5DRlRddGCEDSwwkqQBPI4EWAA+UsgR
         qXklMKCH+4H7KjEfemkqJTykVjZ6QYosKMj/CmB68rTo8z1Los01dg2/OuzYxJehPR1S
         ffITlELyYcMolVmLHTCRyC+MkxpfjkfERa/CkJHPh8RgYugVURSnRVbkW6xWBF09ZKtW
         rVResG95325JhG2UHcslc40cwjkN8l/75mMpcLThvtzy/LIMGadlg4+Y2bQK9KsZAudc
         ms1SZGB5x4TbVE/XildoPFxeR4tHz9bjjkMRLMb//reUoooOoze6MuJ3HyNkwAqO25/q
         q9Xg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=rUlpRwlMw/mZITZY8PcgrG5h7ypTn+NLVEPkd0zOJCs=;
        b=HRjwF6v3oVXngAUMnmVHBLyTCT2ACVyCrrgsO4QjkAVPhFJvEDl1OWfoygMfYYo97F
         ps7pU5uM20PIEgUGoh7dnPR36qDYi7AzONW39DK7XLdTMmBSxABqwCbznm5vXbviFnuP
         h+Eua84YHbpNeAhN82rD0keXeS25SIEPfFLT59Yqinm+vtQCglTmobnZ+aTlY8Zqs72F
         JMrnxqiU25Y1306GT2MvGBccRBVRF3WVXhelmhI4tSrwnbyxx4b7b/o6Yz+FKL9VvSCp
         /s6PUoz2dUWHrmwLUjUr5xKecRacuiG+DE8ajt5hpkaUWGZQcxVuv4TNLYYvqn+SHGgb
         Uy/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=P4OKl98f;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m24si7196477pgj.127.2019.07.04.22.09.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jul 2019 22:09:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=P4OKl98f;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D6E60216FD;
	Fri,  5 Jul 2019 05:09:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562303372;
	bh=wR0nIi/UwUMSGPluFPib5tDAspOm5XZsVqmm1CXmVbI=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=P4OKl98fb+ZjukTs3Ul4LHLQpf19ItTNbpCiXVHaBroJKo7juozWa9+rwg+QRVQ5r
	 KHDL6G4XIRLw/7Hcr62hm8VB026oIHTxuCDJEdVV9wXflap1la8mnA35HpNM/jD+sM
	 eVmCLoL5d4v2SVi4yQcZ9e0avu4YcRam0u8fWNb0=
Date: Thu, 4 Jul 2019 22:09:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>, Randy Dunlap
 <rdunlap@infradead.org>, Mark Brown <broonie@kernel.org>,
 linux-fsdevel@vger.kernel.org, Linux Kernel Mailing List
 <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux-Next Mailing List
 <linux-next@vger.kernel.org>, mhocko@suse.cz, mm-commits@vger.kernel.org,
 Michal Wajdeczko <michal.wajdeczko@intel.com>, Daniel Vetter
 <daniel.vetter@ffwll.ch>, Jani Nikula <jani.nikula@linux.intel.com>, Joonas
 Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi
 <rodrigo.vivi@intel.com>, Intel Graphics <intel-gfx@lists.freedesktop.org>,
 DRI <dri-devel@lists.freedesktop.org>, Chris Wilson
 <chris@chris-wilson.co.uk>
Subject: Re: mmotm 2019-07-04-15-01 uploaded (gpu/drm/i915/oa/)
Message-Id: <20190704220931.f1bd2462907901f9e7aca686@linux-foundation.org>
In-Reply-To: <20190705131435.58c2be19@canb.auug.org.au>
References: <20190704220152.1bF4q6uyw%akpm@linux-foundation.org>
	<80bf2204-558a-6d3f-c493-bf17b891fc8a@infradead.org>
	<CAK7LNAQc1xYoet1o8HJVGKuonUV40MZGpK7eHLyUmqet50djLw@mail.gmail.com>
	<20190705131435.58c2be19@canb.auug.org.au>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 5 Jul 2019 13:14:35 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> > I checked next-20190704 tag.
> > 
> > I see the empty file
> > drivers/gpu/drm/i915/oa/Makefile
> > 
> > Did someone delete it?
> 
> Commit
> 
>   5ed7a0cf3394 ("drm/i915: Move OA files to separate folder")
> 
> from the drm-intel tree seems to have created it as an empty file.

hrm.

diff(1) doesn't seem to know how to handle a zero-length file.

y:/home/akpm> mkdir foo
y:/home/akpm> cd foo
y:/home/akpm/foo> touch x
y:/home/akpm/foo> diff -uN x y
y:/home/akpm/foo> date > x
y:/home/akpm/foo> diff -uN x y
--- x   2019-07-04 21:58:37.815028211 -0700
+++ y   1969-12-31 16:00:00.000000000 -0800
@@ -1 +0,0 @@
-Thu Jul  4 21:58:37 PDT 2019

So when comparing a zero-length file with a non-existent file, diff
produces no output.


This'll make things happy.  And I guess it should be done to protect
all the valuable intellectual property in that file.

--- /dev/null
+++ a/drivers/gpu/drm/i915/oa/Makefile
@@ -0,0 +1 @@
+# SPDX-License-Identifier: GPL-2.0
_

