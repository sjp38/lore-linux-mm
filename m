Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDD70C43381
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 15:28:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5D2E20842
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 15:28:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5D2E20842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B5908E0003; Tue,  5 Mar 2019 10:28:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 365168E0001; Tue,  5 Mar 2019 10:28:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 207AC8E0003; Tue,  5 Mar 2019 10:28:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B9E4A8E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 10:28:02 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id o27so4666225edc.14
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 07:28:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=rqZeCh5C9TkCBKtZLyPcIqLgKZP2743+t2M6aZrupTc=;
        b=AqqDFCx9LVvclK60a+xIXKTwycsE6x+V/oOXvDraL2+HlyF4iWEG2PB4qL3DEaQErf
         DQsCePE7TWakDIqMvFLKhakl3UtLR8ac5h4v95UL2n1TnzRRy/Mjmem2K2LbCWG6OAFp
         9EtER8g5Ter1pA5AE6xK2ZETLDtSlEiVSyezx03867eTZf4+Pyzf+J50yam0U+/yE3j9
         Fd6UGxcey02pSnZ6ev9TnWZYL9xxxKkmkUFSmGpVYqRsEepbPH2mfUZfBIyGXR25EN8G
         1yfusInzBaGOaJCerXtBj9ODNIm6YwT5xMvwLhuLS0s7UuQuCiD1Dr5BeCzoRUOj6AD2
         jmJg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAXu7hjoNSWKuE7Q2ZmZeZl6rKzIg3O1IomJXL+CcaVTCdJhxxPm
	LIw4wj57hYxrLnM0u8ECLKcU1QP/+7cvGZFbuFtYBv4ffdSkVA6VliTGxm2rkIttq+wAJFPsMnt
	ZC+ECtU7tnHR01ZsqgSAXx1gqOTL51HI7boiixFdOB3xR1klV/I2i/sdgX41yg3Cu6A==
X-Received: by 2002:aa7:c1d6:: with SMTP id d22mr20444258edp.180.1551799682278;
        Tue, 05 Mar 2019 07:28:02 -0800 (PST)
X-Google-Smtp-Source: APXvYqzAIXEzHJIqgkMBzZ1kzPcuBzw6xozsEDuJVLa6eWtw+J26Xc0teMlq3hOcfI6w9TEgLBYl
X-Received: by 2002:aa7:c1d6:: with SMTP id d22mr20444214edp.180.1551799681350;
        Tue, 05 Mar 2019 07:28:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551799681; cv=none;
        d=google.com; s=arc-20160816;
        b=CAFdUoROwgJ35MQ4BoE6fqO6ldXHEcb2UgzoBSSjfdkzC8yR+vj4Swx720AGBG486B
         vuFLI7yQtniFmMTWx3lYOBRBeVUcQU1c96/N8rpc3pBMspyJ++ipqPiH/7JGL5NhaRR4
         poek+KIf6Xw0tAJTvOFw4cHQo6D/1Md1AGtrg6+r0b0m8QD7owesfaaepXiTWc8hJD4W
         Ngteg1VOyYfCcbLUS0dYzu5Tnw9BOZ8Bf7F3I9xke5lFmEsJf1cXwzpkexv/k3WIbksd
         8OQ4orko2KiE+/WwsZs8kQGFTHWWNQ6AEzbsSTg02ZsJ9099/OfA2BGVfUnRRw+RHDxP
         zBiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=rqZeCh5C9TkCBKtZLyPcIqLgKZP2743+t2M6aZrupTc=;
        b=UHyHgCLWyCe9GpRFoYEAaaf/KAf/mBeCFMTJYnakoyRisnFoAwaj6y9FePEeR4QLm/
         cQx6loDNygwCm4OCQp0aP1ECZPyzvIZliPyEq5lElISpF8+fCnTjZ58GJcVowDeuceAe
         z0d6YUhxHq+re4ywBbQhmFM9ZSL4YnJMqsTpsxbZioTA/7GifNSP6FnVU7xScPz40W42
         hm6MhFGns3I/15HcFrygR59/79/vuBxlUDmvFvKHjGjB9oUtIX1V69nLPHjp6WTFJ2Lt
         HxLcdxwVf2Fqsjidh7L+qE8dPg40gfcXHvmoqfBt7rqUQgW935bGb2lMotZjbdPGQ0j9
         iFMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp16.blacknight.com (outbound-smtp16.blacknight.com. [46.22.139.233])
        by mx.google.com with ESMTPS id p18si2882240ejx.292.2019.03.05.07.28.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Mar 2019 07:28:01 -0800 (PST)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) client-ip=46.22.139.233;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp16.blacknight.com (Postfix) with ESMTPS id F1DBD1C2DD6
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 15:28:00 +0000 (GMT)
Received: (qmail 12450 invoked from network); 5 Mar 2019 15:28:00 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 5 Mar 2019 15:28:00 -0000
Date: Tue, 5 Mar 2019 15:27:59 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Qian Cai <cai@lca.pw>
Cc: vbabka@suse.cz, Linux-MM <linux-mm@kvack.org>
Subject: Re: low-memory crash with patch "capture a page under direct
 compaction"
Message-ID: <20190305152759.GI9565@techsingularity.net>
References: <604a92ae-cbbb-7c34-f9aa-f7c08925bedf@lca.pw>
 <20190305144234.GH9565@techsingularity.net>
 <1551798804.7087.7.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1551798804.7087.7.camel@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 05, 2019 at 10:13:24AM -0500, Qian Cai wrote:
> On Tue, 2019-03-05 at 14:42 +0000, Mel Gorman wrote:
> > On Mon, Mar 04, 2019 at 10:55:04PM -0500, Qian Cai wrote:
> > > Reverted the patches below from linux-next seems fixed a crash while running
> > > LTP
> > > oom01.
> > > 
> > > 915c005358c1 mm, compaction: Capture a page under direct compaction -fix
> > > e492a5711b67 mm, compaction: capture a page under direct compaction
> > > 
> > > Especially, just removed this chunk along seems fixed the problem.
> > > 
> > > --- a/mm/compaction.c
> > > +++ b/mm/compaction.c
> > > @@ -2227,10 +2227,10 @@ compact_zone(struct compact_control *cc, struct
> > > capture_control *capc)
> > >                 }
> > > 
> > >                 /* Stop if a page has been captured */
> > > -               if (capc && capc->page) {
> > > -                       ret = COMPACT_SUCCESS;
> > > -                       break;
> > > -               }
> > > 
> > 
> > It's hard to make sense of how this is connected to the bug. The
> > out-of-bounds warning would have required page flags to be corrupted
> > quite badly or maybe the use of an uninitialised page. How reproducible
> > has this been for you? I just ran the test 100 times with UBSAN and page
> > alloc debugging enabled and it completed correctly.
> > 
> 
> I did manage to reproduce this every time by running oom01 within 3 tries on
> this x86_64 server and was unable to reproduce on arm64 and ppc64le servers so
> far.
> 

Ok, so there is something specific about the machine or the kernel
config that is at play. You're seeing slub issues, page state issues
etc. Have you seen this on any other x86-based machine? Also please post
your kernel config. Are you certain that removing the block from your
first email avoids any issue triggering?

-- 
Mel Gorman
SUSE Labs

