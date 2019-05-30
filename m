Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B46A2C28CC1
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 01:00:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78609243C6
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 01:00:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LMp1JMUR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78609243C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 13BA36B0266; Wed, 29 May 2019 21:00:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11BD36B026D; Wed, 29 May 2019 21:00:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F1C8D6B026E; Wed, 29 May 2019 21:00:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id B9DE16B0266
	for <linux-mm@kvack.org>; Wed, 29 May 2019 21:00:20 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id r25so1132533pgv.17
        for <linux-mm@kvack.org>; Wed, 29 May 2019 18:00:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=XRlSYLoD4E5PFdWf0blCPVXMfB6705TGt4fGp1hTonw=;
        b=iPADtkpuXd3rNyEEGOHry6k7TNgG4iyQxWLmWWz1KmAr2fCDbgs8V1U/wWSR7kw+BJ
         VufqHzIDvvB58/p+H+pIXPKAkAHLGXt4l01JuhwHhHWpcokWXFnDZUXnoZejUsw5/aCZ
         +MI/7qH25u44dwAMnD6ac9fNgA235cqNy+cPrO/bA3gU7GkZU4bRCypGruFCCb9KFLmy
         IQEPJCKzIAbbMmElJLnlrPi9L67muCzKPpge2cdp57wobpr6p/bEXmXjvxzF1bJmyne4
         TxYXigFBz1DwLB4rmd1vnD+P01wxHBxRL/WCnv0eH5W+EaKyQk2JK66c0Mdj6pJJMH/9
         h2bQ==
X-Gm-Message-State: APjAAAVQHOwpmu/H0JWVINf9z/m/6X+4c0J/XDZXPhhrmdqTQXQopHm2
	0A8NjRQDs319GelBiG9+KQkHmB/4As2nSkbPlsayvnXZDcxyvjOOb91TSGOmqwmR/BoLnmEoNOL
	iIfZyt/qbONnt+QvcZcKF11krioATczybZJs8SC99X+IvD3HTPkM1bElObfIKWbY=
X-Received: by 2002:a62:bd0e:: with SMTP id a14mr726597pff.44.1559178020430;
        Wed, 29 May 2019 18:00:20 -0700 (PDT)
X-Received: by 2002:a62:bd0e:: with SMTP id a14mr726493pff.44.1559178019244;
        Wed, 29 May 2019 18:00:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559178019; cv=none;
        d=google.com; s=arc-20160816;
        b=sbN/z4rvxE8rSNfAp7Dp0j9om/vGaHGSn20bHlnK5Itn+BDQQGy+T9VXoTEjqMv/w/
         jDQ3T/W0SNABSdrjIVSK64GOlb2cAZ6/CukhvQNOvfF1Pkd4qco2s0pyVCRAezPH++YP
         +VIOCTgCY1WWbEUleLzMJ3PZN1xdpJ5onYMen8RXQOj+QcOCYjsAsVPnsuKDDYieFNwW
         Q1OqIF1ixIBhjbR61XsEVP74yzTWlEbxTBfXsz8OWfX3Ime/8hRhBLoTQRBTkoMmaC+l
         aKxjAvbF6nB7T4nmbuIcUpt2MREcUf41zo60q60LmxpfhOG07CZVEVqXD7WYB61XBxkO
         kRQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=XRlSYLoD4E5PFdWf0blCPVXMfB6705TGt4fGp1hTonw=;
        b=TduielNTH9yKCk9NVFwOWaEioov0eJ/vLGEZfXzohqFwzrRXVVuIn935itU8UlYDzp
         tRDquUS1VqVL/C/vRB8XZMRpNx2qtHutbsuGWcFOu33x9K+5Amdn70F17N0CWjJ7dcDn
         vVig4HE+ZOcdsIbOQmWy3JIyOLkrPFLH9++iCcpy516iRLXVfhb9UJwzkUg5eh+ZhMhZ
         pFrmQWWDzQTUr7PmlMiA4fZXvA5Y/lvxxAWk2RvvP+WMAfzdPRha5rLF8nxZaVPMSAfQ
         TBXOyWx0uVm7wIouer8ZOWB7AtqiCQ9bZZEEXmcAgJNy3nPOsN4oLVVKg+pTsJzP8voH
         IQAA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LMp1JMUR;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t97sor1388302pjb.0.2019.05.29.18.00.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 18:00:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LMp1JMUR;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=XRlSYLoD4E5PFdWf0blCPVXMfB6705TGt4fGp1hTonw=;
        b=LMp1JMUR5OF0ObdvCOQBIrzuxvqpSThxpnR/XI/qwMNyLrdIzK0AsjNtsEWIUHq2gE
         YJYh23NUT9JFSyvMPc5TR+gMOBMYuLEPP32mv0l1RMCyL8Ubew+asrpi1kEoKCQSbWXE
         xd0+41OXxJf46aEkpDBM2BkuOn3utI1/R6IgRCytdJrrsmawfrCax1e1BOw8oA74mBcj
         urRewhtBiCo7GiX8N4XCYal6Q1L+Tl84H9N1hEnTj3dvlf5ao5DClL/rVPWjxJ9Hwdnl
         r7iIbqeYyRgP1FRjYO1Cd6P1FW3PGVDBUy/ddXF9uR4sbMjaQUW2gdgOm7OeNX0q07bd
         ubkA==
X-Google-Smtp-Source: APXvYqxqwbIwYQ/1yzfwdYwflNKWsqdcWd22sixyaOeEbpdtllSoeSpuTwEbWi4MsjTxY/QSWz5GpQ==
X-Received: by 2002:a17:90a:db4d:: with SMTP id u13mr628664pjx.43.1559178018805;
        Wed, 29 May 2019 18:00:18 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id x7sm856271pfm.82.2019.05.29.18.00.14
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 29 May 2019 18:00:17 -0700 (PDT)
Date: Thu, 30 May 2019 10:00:11 +0900
From: Minchan Kim <minchan@kernel.org>
To: Hillf Danton <hdanton@sina.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 7/7] mm: madvise support MADV_ANONYMOUS_FILTER and
 MADV_FILE_FILTER
Message-ID: <20190530010011.GD229459@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-8-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190520035254.57579-8-minchan@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 12:36:04PM +0800, Hillf Danton wrote:
> 
> On Mon, 20 May 2019 12:52:54 +0900 Minchan Kim wrote:
> > 
> > With that, user could call a process_madvise syscall simply with a entire
> > range(0x0 - 0xFFFFFFFFFFFFFFFF) but either of MADV_ANONYMOUS_FILTER and
> > MADV_FILE_FILTER so there is no need to call the syscall range by range.
> > 
> Cool.
> 
> Look forward to seeing the non-RFC delivery.

I will drop this filter patch if userspace can parse address range fast.
Daniel suggested a new interface which could get necessary information
from the process with binary format so will it will remove endoce/decode
overhead as well as overhead we don't need to get like directory look
up.

Yes, with this filter option, it's best performance for a specific
usecase but sometime we need to give up *best* thing for *general*
stuff. I belive it's one of the category. ;-)

