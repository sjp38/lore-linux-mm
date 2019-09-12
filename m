Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACF35C4CEC5
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 17:14:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 68B36206A5
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 17:14:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="e9bGHgQC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 68B36206A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 11CC96B0003; Thu, 12 Sep 2019 13:14:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CDDF6B0006; Thu, 12 Sep 2019 13:14:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED6556B0007; Thu, 12 Sep 2019 13:14:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0151.hostedemail.com [216.40.44.151])
	by kanga.kvack.org (Postfix) with ESMTP id C65E56B0003
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 13:14:05 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 6A1D6824CA39
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 17:14:05 +0000 (UTC)
X-FDA: 75926916450.20.alarm05_40be90487c431
X-HE-Tag: alarm05_40be90487c431
X-Filterd-Recvd-Size: 4180
Received: from mail-pg1-f196.google.com (mail-pg1-f196.google.com [209.85.215.196])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 17:14:04 +0000 (UTC)
Received: by mail-pg1-f196.google.com with SMTP id u17so13806120pgi.6
        for <linux-mm@kvack.org>; Thu, 12 Sep 2019 10:14:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=FayExANUP9ViuhmtK38JGVU4eZPGVpUKAMO8IOFz2K0=;
        b=e9bGHgQCszlUto/KbmGaO4oNWaXNGlSe6GE4SRluwUF8dVEW5DMzGFqipp0/WinPBh
         t9cBCJWVuO2gSgD/77JynmL1upu84BvMO16sJCgNAe5iMtAo+xpNCfNEtAQk9rmbcrLM
         lz/6fdY4iRiUqUyIueMVEh+MLB7AjRnLa3Wu+IgzaicRj4r26JDj9tPRoPBjWm7oCDgC
         0cU6ZEAkLuNJVA4lZEgRyGkwjutephLVRRK1hpMa3yLVM4Mdw0UhP+04M+AVJmE8mAcs
         6IcMFXH0N8oAGLJnh4KyN/o2mJA+C+Qou7+XEg1a/YQrQIqJKKvQb79PCdlEx7Z9gtLx
         J2Fw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=FayExANUP9ViuhmtK38JGVU4eZPGVpUKAMO8IOFz2K0=;
        b=QFZCY9+qtIA/HjuK6dGvE3Aqq7iTTMHjgLdA0+Zz5lnYDkg5ZeGjANon6y0ZfhLEOI
         j48TAt3SQwzDVRCNXt3siWjSNuhNAnzImV3+nsA/Sxy3h65EFphqgWysdQiPspDMsAZM
         v3it9GVXS9pLTx2hN+kue63EorBKfOyJ3gXns0HrRmB7QmAJYrFbNnj4vDUX7jy/MN34
         1iwuVwqthaYfevjO8dseBBIdBehGk7Mbd8jGpuE8nA3HUxd3xScYvmZrNqFY5X4/44Da
         2Pkm7myF03DTCTSnEG+77qsd7eZhmSUdtNqMjOmjZU6BQ/Hwczy5N0uuT/z80Uly8O0K
         e0VQ==
X-Gm-Message-State: APjAAAXA6xvG3sAUfy5ikSj/UxTKLbMWPQwx9zRcuDOYznTKb3e0R/gY
	QB+Thz1fqZnPi75xctLj3mE=
X-Google-Smtp-Source: APXvYqzMJFI9O5++NJ1Dr/5RymJQJdpHX78RprFF+Eln41evdXBfAlFauX7if8pCw84GvaZsJbjbGA==
X-Received: by 2002:a63:195f:: with SMTP id 31mr39719349pgz.225.1568308443521;
        Thu, 12 Sep 2019 10:14:03 -0700 (PDT)
Received: from google.com ([2620:15c:211:1:3e01:2939:5992:52da])
        by smtp.gmail.com with ESMTPSA id z14sm4825667pgj.22.2019.09.12.10.14.01
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 12 Sep 2019 10:14:01 -0700 (PDT)
Date: Thu, 12 Sep 2019 10:14:00 -0700
From: Minchan Kim <minchan@kernel.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: linux-mm@kvack.org
Subject: Re: [PATCH] mm: fix the race between swapin_readahead and
 SWP_SYNCHRONOUS_IO path
Message-ID: <20190912171400.GA119788@google.com>
References: <1567169011-4748-1-git-send-email-vinmenon@codeaurora.org>
 <20190909232613.GA39783@google.com>
 <9df3bb51-2094-c849-8171-dce6784e1e70@codeaurora.org>
 <20190910175116.GB39783@google.com>
 <c7fbc609-0bb0-bffd-8b1f-c2588c89bfd2@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c7fbc609-0bb0-bffd-8b1f-c2588c89bfd2@codeaurora.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.002111, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Vinayak,

On Wed, Sep 11, 2019 at 03:37:23PM +0530, Vinayak Menon wrote:

< snip >

> >> Can swapcache check be done like below, before taking the SWP_SYNCHRONOUS_IO path, as an alternative ?
> > With your approach, what prevent below scenario?
> >
> > A                                                       B
> >
> >                                             do_swap_page
> >                                             SWP_SYNCHRONOUS_IO && __swap_count == 1
> 
> 
> As shrink_page_list is picking the page from LRU and B is trying to read from swap simultaneously, I assume someone had read
> 
> the page from swap prior to B, when its swap_count was say 2 (for it to be reclaimed by shrink_page_list now)

It could happen after B saw __swap_count == 1. Think about forking new process.
In that case, swap_count is 2 and the forked process will access the page(it
ends up freeing zram slot but the page would be swap cache. However, B process
doesn't know it).

