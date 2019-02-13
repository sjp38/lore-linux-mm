Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23018C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 11:47:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE93B222B2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 11:47:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE93B222B2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CF548E0003; Wed, 13 Feb 2019 06:47:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 67FE48E0001; Wed, 13 Feb 2019 06:47:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56FAB8E0003; Wed, 13 Feb 2019 06:47:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 192B08E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 06:47:38 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id y2so1534467plr.8
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 03:47:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fqKvzr2qY3/hju/1gw51bS7xXDgLxNbCAQ3D2Gsiok4=;
        b=mmVU0v3bzN1PoIt67Sam3zarEjVZxD5KYHPAoZbTe7U9z+CDrwQrP1oi8JOkfLoT6M
         SEIBjwHcNQLla2kF1UPMUMtYoBxg87UlA/SrG6Lz+R/RVPKISE2NUqLUVzyAY2zGBUWh
         7gbFmc5Ca5zGseM0Zw0dJfXosVqGkx+TARXfIyXTZ8tpIh76M+AHlrYNtVhAgJgbvmXj
         Ekr7Ep5ijRX4z6pOnXiL+R6Q95FZxBrvG2QqjJXKScSWcmVm8yid/sMK9AZ0mTIuCT6q
         3V69NILkX37+/7dffcfE22zuFaw5XO2ip6jlbF7POkt8i7zAJ9g4slAfdOBlh11L+CT6
         a5Ww==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuYCG4Ma5j+EvhWSj4ZKYfu7Y9XW585JzPeivrOu41S2YCfyLmMk
	qWJi9pOK3MCK4UkZqS1v3GxCpSllHW33FC9n0JLrbe4nSwcnyECbKgZwXN9gb00ODZpeuBpG4Hu
	Vzbi/7cBiWnyKsW8KbuE8ymZ3rwYPjSwzzR+BhSbHLv8iq/4hk+yo3n8C0fF9+Vg=
X-Received: by 2002:a17:902:bcc2:: with SMTP id o2mr71355pls.69.1550058457770;
        Wed, 13 Feb 2019 03:47:37 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaQL3Kxeehsj7PatmyYhy5whAvuBRrqSVCnb+CgLLCBAc1qZgGX7XEH80PvXGtEZXvwGd7R
X-Received: by 2002:a17:902:bcc2:: with SMTP id o2mr71297pls.69.1550058456917;
        Wed, 13 Feb 2019 03:47:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550058456; cv=none;
        d=google.com; s=arc-20160816;
        b=yiUwoyZqWTU1TmbzKVfJJqjAYVhbz6yeujCwfvgdK4jGI7gR9CPZWGXDZuqc6rZBy9
         TD04JrVZlACK8gzRLgp4f/mQApEuT1ScUtYWg2YN4kw//yaJY1TGMSZm/GyakhLV2g6T
         OBQq9FIkVUsT7a+CIJ7YVG7+pCy0JHndCpMkqSFPHPhaaBTEjGcaG9zqeQwBrC6wXiaq
         Y7NuyVxCnxF9fj1Iv58Wurqz7vDGhDe5BODI56sOcbBfw+1SIVnjIxea+F1SmBppIF1Y
         QrhoYTO7g15zK4pN8b0Y9xl5iXW03I8ZtWxVftD+acDbq9D3hsgmI5SwpcurUH6qOjal
         gOBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fqKvzr2qY3/hju/1gw51bS7xXDgLxNbCAQ3D2Gsiok4=;
        b=WufRo/djpTImdb8FQceJeicgx11Go3ha3gCmxrnSSeA/EC/zPoT/Q5dyF7qt6gLkVO
         gxUCUqy00TR23GXyDxdU3wZiOM+CoMowfuM4Om+W0DTtmllQEq+2hN7PLNEmLme25DX2
         S3H6GYq54sMq9lyJHohmNomWLZ6CLeDno1vmJXUEtvfTbLz/67nrhYM5OHA5A0gJavKR
         /cJ9fuTkra5IrMhvbDKSF1Ptyz2PEe6jLjUhgOnMvbsLBplzegB9c34txxfsY1cjuVze
         OCwjhLk9NlFQLAyTSC2l+MPeFQnY+PtEBzI4/ezaqyPQ449EAa+7ixS67Ri5yhuzaHCg
         YPkA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v4si15553723pfm.71.2019.02.13.03.47.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 03:47:36 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2384AADAA;
	Wed, 13 Feb 2019 11:47:35 +0000 (UTC)
Date: Wed, 13 Feb 2019 12:47:33 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Yong-Taek Lee <ytk.lee@samsung.com>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] proc, oom: do not report alien mms when setting
 oom_score_adj
Message-ID: <20190213114733.GB4525@dhcp22.suse.cz>
References: <20190212102129.26288-1-mhocko@kernel.org>
 <20190212125635.27742b5741e92a0d47690c53@linux-foundation.org>
 <201902130124.x1D1OGg3070046@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201902130124.x1D1OGg3070046@www262.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 13-02-19 10:24:16, Tetsuo Handa wrote:
> Andrew Morton wrote:
> > On Tue, 12 Feb 2019 11:21:29 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > > Tetsuo has reported that creating a thousands of processes sharing MM
> > > without SIGHAND (aka alien threads) and setting
> > > /proc/<pid>/oom_score_adj will swamp the kernel log and takes ages [1]
> > > to finish. This is especially worrisome that all that printing is done
> > > under RCU lock and this can potentially trigger RCU stall or softlockup
> > > detector.
> > > 
> > > The primary reason for the printk was to catch potential users who might
> > > depend on the behavior prior to 44a70adec910 ("mm, oom_adj: make sure
> > > processes sharing mm have same view of oom_score_adj") but after more
> > > than 2 years without a single report I guess it is safe to simply remove
> > > the printk altogether.
> > > 
> > > The next step should be moving oom_score_adj over to the mm struct and
> > > remove all the tasks crawling as suggested by [2]
> > > 
> > > [1] http://lkml.kernel.org/r/97fce864-6f75-bca5-14bc-12c9f890e740@i-love.sakura.ne.jp
> > > [2] http://lkml.kernel.org/r/20190117155159.GA4087@dhcp22.suse.cz
> > 
> > I think I'll put a cc:stable on this.  Deleting a might-trigger debug
> > printk is safe and welcome.
> > 
> 
> I don't like this patch, for I can confirm that removing only printk() is not
> sufficient for avoiding hungtask warning. If the reason of removing printk() is
> that we have never heard that someone hit this printk() for more than 2 years,
> the whole iteration is nothing but a garbage. I insist that this iteration
> should be removed.

As the changelog states explicitly, removing the loop should be the next
step and the implementation is outlined in [2]. It is not as simple
as to do the revert as you have proposed. We simply cannot allow to have
different processes disagree on oom_score_adj. This could easily lead
to breaking the OOM_SCORE_ADJ_MIN protection. And that is a correctness
issue.

As a side note.
I am pretty sure I would have more time to do that if only I didn't
really have to spend it on pointless and repeated discussions. You
are clearly not interested on spending _your_ time to address this
issue properly yourself. This is fair but nacking a low hanging
fruit patch that doesn't make situation any worse while it removes a
potential expensive operation from withing RCU context is nothing but
an obstruction.  It is even more sad that this is not the first example
of this attitude which makes it pretty hard, if not impossible, to work
with you.

And another side note. I have already pointed out that this is by far
not the only problem with CLONE_VM without CLONE_SIGHAND threading
model. Try to put your "only the oom paths matter" glasses down
for a moment and try to look what are the actual and much more
serious consequences of this threading model. Hint have a look at
mm_update_next_owner and how we have to for_each_process from under
tasklist_lock or zap_threads with RCU as well.
-- 
Michal Hocko
SUSE Labs

