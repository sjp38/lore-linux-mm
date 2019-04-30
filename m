Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5B4EC04AA8
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 10:45:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A658620675
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 10:45:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bxHjCkoa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A658620675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B87A6B0271; Tue, 30 Apr 2019 06:45:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1419D6B0272; Tue, 30 Apr 2019 06:45:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFE436B0273; Tue, 30 Apr 2019 06:45:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 894E16B0271
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 06:45:21 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id e9so2704665ljk.0
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 03:45:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=D0Zsz5cuLJP69SdJwEsKGX6QwExtlT9EFiLTZhEUga8=;
        b=twbKV/4Jt7+fczZicQEjie42hp+JFXaudfyOqNPlV/QHbIKtcYnjVZ6wZpYgarJDch
         ywC1Lx6NHPt+aW9oA78Zj9VuOqLHdVsJCHZS21/DGn11PRhx7Se1GXQNWOwWEHXIRZ6+
         p8FroU9esyyq0c3b2izvJGGeS+/GeW4OAO0jawJba3f04Ctsy6K1YkoKKq/aGSLDQnJ8
         fdGJxhVbH47NtkF+wVd7ZH2qaXO0SmCMDJ3g9ThtOYmkh/K7mkdlYONtr8XXKBcM02Wg
         j7aPGhJGCpNf/lqHMcDTk0zjVV6mTDSnENeUJv7tuz8c8xF6yBJtRGFiHtZYB6Wv4+aM
         DvfA==
X-Gm-Message-State: APjAAAUeZvlabIuQKEMoq2gsVYOicNpZFV5JPCAxnrCdXmY55aWQP5is
	HQP9djzWdjwXTzjX/dfkjSAg1tD6DNU9Ofl3L3XTim1kxsVITlKUZV+JK9G8iBG41s9XqCuAOmd
	K8ftBFsRrC6dhyMYrr6cvE59L3/Zbuigsg6VnfO7kE771exVVMcSKIAAN0Wdgptl8yg==
X-Received: by 2002:ac2:55b2:: with SMTP id y18mr11725964lfg.133.1556621120726;
        Tue, 30 Apr 2019 03:45:20 -0700 (PDT)
X-Received: by 2002:ac2:55b2:: with SMTP id y18mr11725904lfg.133.1556621119547;
        Tue, 30 Apr 2019 03:45:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556621119; cv=none;
        d=google.com; s=arc-20160816;
        b=aJMKTkfjZEFiYcs5Aw+5RO+G4qBPiasDnV33EMNJK+Xt9uX/POO5NCKZklQVU1oWbL
         oastWRYwtfmVoBUCvGoJRnxJsXnlrLRwLGYxFG0RU8qm31+BmTS9BdmOmPXzvlBpZdGy
         PiWLd5GEhJfFOKfo26OVFYE4cNhSlGXImxSlLrNpDalEX/BQ8D6ezvUwqF9/kR5/q3yr
         BuCuYcVwLBqVk9iuc+dZa/Bv/SSnxALBtWUCYV4wja7z3lHtGmLrUVenBJUR114yBLkD
         OEwC8MhaL2VI95k+xTvpi716sS0NDpoxzEOera7hV1sm1YxZWGOpANWdHibDKa0C5xi6
         9NtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=D0Zsz5cuLJP69SdJwEsKGX6QwExtlT9EFiLTZhEUga8=;
        b=zQuPH7RSvVJFfLyQx8QwwEKtEWof+sNIp5DgHKV+qdcpMkG7gylkEJRkG5UmZvQ04G
         FBvxyNIcxdHIPmgNtXMYGaE8qyu5LVvIJ1XbPfePDEfI4up/JJ6RnX6zUqfTkRwOojVR
         zZt2TjJgfL6gl53cCSFlh5ijqI1NIAN/tutjgeZn5PX4+xAPB+w1Hz8sol+AFslsYcjz
         pjwn6yqDOenNg3uiIl7tNM3YecuUW9QOwCeCyNzyT4cqnKv8YnZXL4xXX/7P+68yel36
         Y+Nv2B4p+d2JBtdAzLnu1MWDXi9ULwNHTIFFlbup/tbLdpr+Ibm2PJi0T6gMoUzBovMp
         eiYA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bxHjCkoa;
       spf=pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=gorcunov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r18sor18922579lji.31.2019.04.30.03.45.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Apr 2019 03:45:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bxHjCkoa;
       spf=pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=gorcunov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=D0Zsz5cuLJP69SdJwEsKGX6QwExtlT9EFiLTZhEUga8=;
        b=bxHjCkoavoWP0hn9Y3zvg9uBa6/OyLqHI5jEpHTFTvFUZkg/G0SnClzHnlOncwQfd/
         8AJpSAjDKpJaytE5xuwaK8gHuPdq3EOYGTfkU0JbE7sC8Ept3JJ15+MYRxb0x6PzHfl2
         AhWWFagFddh06QfYTxLFTEHlZJkd4lu28BlpyDa+VOERo0+dvzK56HWlS3dT7dUGD1DB
         9lv1ZMGobUYNU9iAUHymErxAMtS8tuhcTNTsWxyb517TlnsEZ+yHZCXFmOMhDfwxEiNa
         rLFDeagMOuR1rkkIJHALJXo0SvmLP3t9/Vcc5XhzVX6i+qNdghV+L0LRvWzGPB3Jma5t
         +fXA==
X-Google-Smtp-Source: APXvYqzDf7wlVV/tS0AVM5oO9IvgsP46PdHqrHNLvAfCdN4WQJCHqmCHp4cUQ7a3+BNNLwzEOz0lLA==
X-Received: by 2002:a2e:3e0e:: with SMTP id l14mr35352423lja.125.1556621118804;
        Tue, 30 Apr 2019 03:45:18 -0700 (PDT)
Received: from uranus.localdomain ([5.18.103.226])
        by smtp.gmail.com with ESMTPSA id f1sm7277893ljc.73.2019.04.30.03.45.17
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 30 Apr 2019 03:45:18 -0700 (PDT)
Received: by uranus.localdomain (Postfix, from userid 1000)
	id 68F874603CA; Tue, 30 Apr 2019 13:45:17 +0300 (MSK)
Date: Tue, 30 Apr 2019 13:45:17 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>,
	akpm@linux-foundation.org, arunks@codeaurora.org, brgl@bgdev.pl,
	geert+renesas@glider.be, ldufour@linux.ibm.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, mguzik@redhat.com,
	mhocko@kernel.org, rppt@linux.ibm.com, vbabka@suse.cz
Subject: Re: [PATCH 1/3] mm: get_cmdline use arg_lock instead of mmap_sem
Message-ID: <20190430104517.GF2673@uranus.lan>
References: <20190418182321.GJ3040@uranus.lan>
 <20190430081844.22597-1-mkoutny@suse.com>
 <20190430081844.22597-2-mkoutny@suse.com>
 <4c79fb09-c310-4426-68f7-8b268100359a@virtuozzo.com>
 <20190430093808.GD2673@uranus.lan>
 <1a7265fa-610b-1f2a-e55f-b3a307a39bf2@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1a7265fa-610b-1f2a-e55f-b3a307a39bf2@virtuozzo.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 30, 2019 at 12:53:51PM +0300, Kirill Tkhai wrote:
> > 
> > Well, strictly speaking we probably should but you know setup of
> > the @arg_start by kernel's elf loader doesn't cause any side
> > effects as far as I can tell (its been working this lockless
> > way for years, mmap_sem is taken later in the loader code).
> > Though for consistency sake we probably should set it up
> > under the spinlock.
> 
> Ok, so elf loader doesn't change these parameters.
> Thanks for the explanation.

It setups these parameters unconditionally. I need to revisit
this moment. Technically (if only I'm not missing something
obvious) we might have a race here with prctl setting up new
params, but this should be harmless since most of them (except
stack setup) are purely informative data.

