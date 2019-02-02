Return-Path: <SRS0=HJeg=QJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38D17C282D8
	for <linux-mm@archiver.kernel.org>; Sat,  2 Feb 2019 00:16:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED4BD20863
	for <linux-mm@archiver.kernel.org>; Sat,  2 Feb 2019 00:16:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="aF9v2W/i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED4BD20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D2DC8E000F; Fri,  1 Feb 2019 19:16:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85CDD8E0001; Fri,  1 Feb 2019 19:16:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FDCB8E000F; Fri,  1 Feb 2019 19:16:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 297498E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 19:16:50 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id m16so5927065pgd.0
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 16:16:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=ipSlJW+1g6r30pdiTxD0nrISKpvL6eDJqYpduy1rAGs=;
        b=MYJuiFCHSb9rE8kaLvu/a03m5yrrmC5eruWs3QqqfXYoAQO3ZluhZIxZbRpemK38//
         R5wa1XvffzcCocAG0GwXf6TWdJAFtQ6anVygQBpl13rBYF2mt/WFpUkDV+3ra2PNKXxX
         zWJnW9vcyQvRbj7PqDZMevRhrZj7j1JW52MfjaHnELAcdcKmi79j4LBFvsFCC6IJ79e1
         F8j87FiWHUeybGTyrbEyRlmBEwJb4i1BF+WsImffd1rir+5SzYTwYIbKErqQ+7DYVqtq
         ZYZpzOzErh9C/yh1TSq5yewH2Ogx9dMyAq0vMjsHEKLEZrmI881j3KImW/JPWLnZ+hGF
         lW+w==
X-Gm-Message-State: AJcUukeVhC/ERJzQAtBvghGterQvIflPTcJKFq4NgaCwK2oAhwAPMCj/
	vChBTCWWefpU7J8F5rARDDR1lEU7WChYTZE2ui2zStjTh07UN5BsgQUOjVB7d9hCF2O/PvKBMB4
	P2GaljmaTdKAM1bWKTQRgIUuXmbtat9GwYJw9HRVflaDAui9flsfbBdiJk4BE0oNBAiI2rFjWVO
	BvhjTsOUhaJJTdqx9hPLkum5sbA1wNt6SPAw43nKxC8ePh60UjR1kG+iFOmI832W4MKUvNInxSw
	DISWHwzLwF7YZ0ExOWuyOGX9/etdUf+s+f/GeJyLpBEAaJlRmKlOqhOCubhk3ctDY1uEiEKgswn
	Le/6YV0qBvqcWOZQyh0DFJ+5vAezhrKrSs/WnM5LvF7lfEIMnMcaUwtFi6jPrJUvEUISe5Q3XAc
	l
X-Received: by 2002:a62:8a51:: with SMTP id y78mr41203345pfd.35.1549066609669;
        Fri, 01 Feb 2019 16:16:49 -0800 (PST)
X-Received: by 2002:a62:8a51:: with SMTP id y78mr41203310pfd.35.1549066609004;
        Fri, 01 Feb 2019 16:16:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549066608; cv=none;
        d=google.com; s=arc-20160816;
        b=h8wDA3hr2aoqvhJZtJJYEzYxaquNsH7GD9To6WgXMA+MSf9T/i8Ao6jh9mSRiEX3YZ
         voylHe9TVvZXSajWqXEItUaXenhnQmokt3N//hSERZgvo8Ma/Co1ozAGgmcNnuVLH3ep
         srHvm9sKMEvI+uH3/Mntpf92HhuPDhCITc4vjSd7vTqAPj5Dyc+c6l4VT8VJ4WxIO6eu
         a+lppwBG1kU//8RMIInijD90r4Pkm47TxZF7HOpKxVhDsjGEDGY40OqMD6iG7nUcHP7B
         7MflV8gflTcXs8aK8/pUWKHFHivDNwK10R03Z56OC/8QsT3jPTTa9crfUMrggKsWZc5d
         OA8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=ipSlJW+1g6r30pdiTxD0nrISKpvL6eDJqYpduy1rAGs=;
        b=KY/HS3A1MAo9kDBItSA/w8nKRrgiVgiAdTIblKM0npTBP2FpHpRjRFSWvnVXo9/urK
         ov58fuUD5zcLxPCtt+gbIDG/b1DRutfZnz+hVoDdJfWFGi36X3Sfo0qq3qBMqUIa3tSN
         Nyng0xC7aRnN7NzO0BaDsMIHb4PIw/xAIgXkM76OUuKkYmd3gcx8tGdQAfg/S9eaLfJE
         b5N1gzi1vDEeaRG+bvFCQOqGfZSD63/B5wtq7QfN397NQWIKPG899/bEz2C9GBS297R/
         Ewsp6ctKXosaDUgon0i6YTQo6p7GE/HfTzki8Z02lfJYssjV4Gqg/CHucTXKfpvGs+Rx
         I2zg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="aF9v2W/i";
       spf=pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bsingharora@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t1sor14626426plr.61.2019.02.01.16.16.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Feb 2019 16:16:48 -0800 (PST)
Received-SPF: pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="aF9v2W/i";
       spf=pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bsingharora@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=ipSlJW+1g6r30pdiTxD0nrISKpvL6eDJqYpduy1rAGs=;
        b=aF9v2W/i5HOZrzIPQtqorTK7qotlx5s6j9lCA9ex9evRf53ziXKSxzU4wDqixu5NHZ
         Fr+JIfkf1y80RX1OnHZXX3wkRyjpWEOtKLDxOCvmTzCEw4caHXrsdT45QsBmfWSd18BT
         iaxcQ4pOvPoDPhkURPK1DVysGb1v0uphtreYOvT9fkXn368ZGMCsgw9J/uw9atzPf1SA
         /HUBvkbK7fq0bX2wdw7+f3FKSMT/QYpSAxpIWuU6HMUbsQV6d5SnlXKOVdPXBOtNfXPv
         Z+d8wxpoQeSJ0HToPAVlv/qYXPfLujd+D7UXuYbMJ5eiGZsCLef2zi1UvO/8aZPEKhrJ
         0RPQ==
X-Google-Smtp-Source: ALg8bN5ZoMwT9Myn+X+jdHsidHb67I9ULzIejPJr+69X3Id32jk/EewNAuG6gHLjx7K7gkbSC1BczQ==
X-Received: by 2002:a17:902:1105:: with SMTP id d5mr40488097pla.47.1549066608278;
        Fri, 01 Feb 2019 16:16:48 -0800 (PST)
Received: from localhost (14-202-194-140.static.tpgi.com.au. [14.202.194.140])
        by smtp.gmail.com with ESMTPSA id 62sm9301989pgc.61.2019.02.01.16.16.46
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Feb 2019 16:16:47 -0800 (PST)
Date: Sat, 2 Feb 2019 11:16:44 +1100
From: Balbir Singh <bsingharora@gmail.com>
To: Jerome Glisse <jglisse@redhat.com>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: Re: [linux-next:master 5141/5361] include/linux/hmm.h:102:22: error:
 field 'mmu_notifier' has incomplete type
Message-ID: <20190202001644.GL26056@350D>
References: <201902020011.aV3IBiMH%fengguang.wu@intel.com>
 <20190201224809.GK26056@350D>
 <626576501.100359304.1549062486006.JavaMail.zimbra@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <626576501.100359304.1549062486006.JavaMail.zimbra@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 01, 2019 at 06:08:06PM -0500, Jerome Glisse wrote:
> 
> 
> ----- Original Message -----
> > On Sat, Feb 02, 2019 at 12:14:13AM +0800, kbuild test robot wrote:
> > > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
> > > master
> > > head:   9fe36dd579c794ae5f1c236293c55fb6847e9654
> > > commit: a3402cb621c1b3908600d3f364e991a6c5a8c06e [5141/5361] mm/hmm:
> > > improve driver API to work and wait over a range
> > > config: x86_64-randconfig-b0-02012138 (attached as .config)
> > > compiler: gcc-8 (Debian 8.2.0-14) 8.2.0
> > > reproduce:
> > >         git checkout a3402cb621c1b3908600d3f364e991a6c5a8c06e
> > >         # save the attached .config to linux build tree
> > >         make ARCH=x86_64
> > > 
> > > All errors (new ones prefixed by >>):
> > > 
> > >    In file included from kernel/memremap.c:14:
> > > >> include/linux/hmm.h:102:22: error: field 'mmu_notifier' has incomplete
> > > >> type
> > >      struct mmu_notifier mmu_notifier;
> > >                          ^~~~~~~~~~~~
> > > 
> > > vim +/mmu_notifier +102 include/linux/hmm.h
> > > 
> > >     81
> > >     82
> > >     83	/*
> > >     84	 * struct hmm - HMM per mm struct
> > >     85	 *
> > >     86	 * @mm: mm struct this HMM struct is bound to
> > >     87	 * @lock: lock protecting ranges list
> > >     88	 * @ranges: list of range being snapshotted
> > >     89	 * @mirrors: list of mirrors for this mm
> > >     90	 * @mmu_notifier: mmu notifier to track updates to CPU page table
> > >     91	 * @mirrors_sem: read/write semaphore protecting the mirrors list
> > >     92	 * @wq: wait queue for user waiting on a range invalidation
> > >     93	 * @notifiers: count of active mmu notifiers
> > >     94	 * @dead: is the mm dead ?
> > >     95	 */
> > >     96	struct hmm {
> > >     97		struct mm_struct	*mm;
> > >     98		struct kref		kref;
> > >     99		struct mutex		lock;
> > >    100		struct list_head	ranges;
> > >    101		struct list_head	mirrors;
> > >  > 102		struct mmu_notifier	mmu_notifier;
> > 
> > Only HMM_MIRROR depends on MMU_NOTIFIER, but mmu_notifier in
> > the hmm struct is not conditionally dependent HMM_MIRROR.
> > The shared config has HMM_MIRROR disabled
> > 
> > Balbir
> > 
> > 
> 
> I am bad with kconfig simplest fix from my pov is adding
> select MMU_NOTIFIER to HMM config as anyway anything that
> will have HMM will need notifier.
> 
> config HMM
>   bool
> + select MMU_NOTIFIER
>   select MIGRATE_VMA_HELPER
>

Yes

Acked-by: Balbir Singh <bsingharora@gmail.com>
 
> 
> Cheers,
> Jérôme

