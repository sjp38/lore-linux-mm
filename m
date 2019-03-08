Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 447B0C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 17:32:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03BC620868
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 17:32:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03BC620868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=canonical.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A29C8E0003; Fri,  8 Mar 2019 12:32:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 554BA8E0002; Fri,  8 Mar 2019 12:32:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4426B8E0003; Fri,  8 Mar 2019 12:32:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id DD82B8E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 12:32:19 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id e18so10453602wrw.10
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 09:32:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=y41igMRdVdi6O2TKhS1LdJCmwZwAdJ7DsR9RZUvhSc0=;
        b=CSATdFI1+s44TKZx69gpGBs+0BMEU44eGPxjvDqrCeonfOpEsncJvr4SBGqs79F9dm
         ENBbknEinAKAYzfy7TFDdUHH1GyS2kC+Pbsh06JLcLdcAQLdioCCQGrPy45tn+PFTXQd
         YtQG5PUaRcNNqCmEa5agRLcEHgSxafepd2xIgzw2H2Hly8/SfyVOM/H+MJJXNGLmuSgN
         vCCWzTgo1kGEsnv3XGjlh7C8xBztBzfa08HVHrDVt5IsqoMH5YkS0ETTlFd6uGHOCmbE
         TCqNfUvoRQvmPXNvdj7ntFK2wYF20v5Uyg0We5gHQinH+TrRvQlN0gtyHDnfj0atdsf6
         ru3w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=andrea.righi@canonical.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
X-Gm-Message-State: APjAAAXxZzKP4QriaGPare0jBPA4/jmuQk3xdjLUvY4LrzULNkYysaEd
	nduqWexa/Gsxv2I87xGFJPecBqqLJLGUjI1qoAr6U66uBusRveKV35Rg0ZICcG9HfTKjAVrq7+s
	BKGiuzVvJq9VLpPoME2z8/CTsaT0nmG7sHSeQNXO6bRBNErKx3wecP3N3ouuJF8Kn8CqBaEa0zE
	cqJLjVVHge8OJVcC1Gt3Q6dx2CoenG7/F1WQjHwMfQTLO71PRE3mOHw/xSTVmu2rjrk/VSh/ubY
	Cs+5isNYD+HDnBcOnp6pE4BBY1erRN3BwudPzp/4f/0DAo9PmL/pQgQmXLRkdWSMbHXWxVChKin
	YQIiqZScctYjyn8rBTJty6eWjqdHRVqHjGR7pgUN1aCUPNaDGsn0RJmFtf1QJvFla6vPU3vURZJ
	n3wfotZgf+/vQd6Ze2dSxkqizLD+0p/N+NnClT5m4lYKT2XOLjLDxzuiBo22/LF9XETjG1KjRx9
	ACrDyPMkI2u7cjp8FDBDvwPM6pLPYskhp5NMcHjIQobQSgTspa/1T6UCTM5CG9FVp5HadEOaKzr
	FtkAawwRXZUpELE7rXmZBNUZXvb/vYzHoy0v9eTjBCIY83n/9Mie9L266/KVdzZiQU8gFxP1ZZJ
	5Y/26aD9pmDA
X-Received: by 2002:a1c:2c4:: with SMTP id 187mr9623263wmc.77.1552066339449;
        Fri, 08 Mar 2019 09:32:19 -0800 (PST)
X-Google-Smtp-Source: APXvYqwoZZFBJNGw+O76Sq8BMMtyY3nJKkrSJk0er/PSPhVnZq0VAkqTaUKAG3/KHbkSXhRjWeo/
X-Received: by 2002:a1c:2c4:: with SMTP id 187mr9623233wmc.77.1552066338526;
        Fri, 08 Mar 2019 09:32:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552066338; cv=none;
        d=google.com; s=arc-20160816;
        b=ZY+tf9p/+Gy3VDsb7wnWpinm+sGI4y1azE1GbjeTykX6i3LkIGy2JH3JRxMFe7CK+X
         PlGoU5Dxd5JhBTbpOyrjLf1sR5NuTWNvIGFsP0b41tQdU1T79mCdxNBnOn0n38m3CwtD
         GpaS+83fVBUrBvxVCwGcUhKP/M054l/GYPDlzptvpFELHSBkL0TOpQSFBfHq6v/ScEIu
         VdM2tymzn5zkljPxdFbpLLFFRwDvpLAbjgi4mGPM+7Kprf5VZRMF+qPeyrPIVEloipaE
         Cmm+fEH+nC7XtyiOYq6hNu2pDuWa3GfSsaL3i1T9rrAGfeFX8cs3llZ5r2on7MGvT4+h
         Bccw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=y41igMRdVdi6O2TKhS1LdJCmwZwAdJ7DsR9RZUvhSc0=;
        b=I7qq5ScNNfYEREZXDbB4JgoyVp4r/B7ox3f99z+mC4hBXdjscfsIMUEKKkzeOQRtru
         ZSnjfgPP57mggzPFOLR8P+abdTEWHb8wVkmF/3qH4AFXcyfrqLA7nec6h5oF8Ri9DmxL
         JmWOmgY8V2rbyYuqsYWcqmyK5hqwqhW/7sD+7MTnqG9TBOHzkwcUIyI/rpCJQgAoC9k1
         RuEY6g0KnHwURJACauqWdLGOxUPvploTHMaiQ/mUH01ocdqO02xdIu5ajY3+H9Cn9yLp
         zSvtz0IBLPzLVsCuaOV04uA6j8Hb0oBpJgD+0aaL1JjTIZc7PomWAU2EpnOigbSuyVg8
         CfjA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=andrea.righi@canonical.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id 135si4990285wme.47.2019.03.08.09.32.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Mar 2019 09:32:18 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) client-ip=91.189.89.112;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=andrea.righi@canonical.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
Received: from mail-wr1-f71.google.com ([209.85.221.71])
	by youngberry.canonical.com with esmtps (TLS1.0:RSA_AES_128_CBC_SHA1:16)
	(Exim 4.76)
	(envelope-from <andrea.righi@canonical.com>)
	id 1h2JM2-00058m-3Y
	for linux-mm@kvack.org; Fri, 08 Mar 2019 17:32:18 +0000
Received: by mail-wr1-f71.google.com with SMTP id i9so2199040wrx.4
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 09:32:18 -0800 (PST)
X-Received: by 2002:a5d:6288:: with SMTP id k8mr12639928wru.173.1552066337672;
        Fri, 08 Mar 2019 09:32:17 -0800 (PST)
X-Received: by 2002:a5d:6288:: with SMTP id k8mr12639905wru.173.1552066337361;
        Fri, 08 Mar 2019 09:32:17 -0800 (PST)
Received: from localhost (host22-124-dynamic.46-79-r.retail.telecomitalia.it. [79.46.124.22])
        by smtp.gmail.com with ESMTPSA id l18sm8233877wrv.20.2019.03.08.09.32.16
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 08 Mar 2019 09:32:16 -0800 (PST)
Date: Fri, 8 Mar 2019 18:32:15 +0100
From: Andrea Righi <andrea.righi@canonical.com>
To: Josef Bacik <josef@toxicpanda.com>
Cc: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>,
	Paolo Valente <paolo.valente@linaro.org>,
	Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>,
	Vivek Goyal <vgoyal@redhat.com>, Dennis Zhou <dennis@kernel.org>,
	cgroups@vger.kernel.org, linux-block@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 0/3] blkcg: sync() isolation
Message-ID: <20190308173215.GA10148@xps-13>
References: <20190307180834.22008-1-andrea.righi@canonical.com>
 <20190308172219.clcu6ehjav6y2hxi@MacBook-Pro-91.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190308172219.clcu6ehjav6y2hxi@MacBook-Pro-91.local>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 08, 2019 at 12:22:20PM -0500, Josef Bacik wrote:
> On Thu, Mar 07, 2019 at 07:08:31PM +0100, Andrea Righi wrote:
> > = Problem =
> > 
> > When sync() is executed from a high-priority cgroup, the process is forced to
> > wait the completion of the entire outstanding writeback I/O, even the I/O that
> > was originally generated by low-priority cgroups potentially.
> > 
> > This may cause massive latencies to random processes (even those running in the
> > root cgroup) that shouldn't be I/O-throttled at all, similarly to a classic
> > priority inversion problem.
> > 
> > This topic has been previously discussed here:
> > https://patchwork.kernel.org/patch/10804489/
> > 
> 
> Sorry to move the goal posts on you again Andrea, but Tejun and I talked about
> this some more offline.
> 
> We don't want cgroup to become the arbiter of correctness/behavior here.  We
> just want it to be isolating things.
> 
> For you that means you can drop the per-cgroup flag stuff, and only do the
> priority boosting for multiple sync(2) waiters.  That is a real priority
> inversion that needs to be fixed.  io.latency and io.max are capable of noticing
> that a low priority group is going above their configured limits and putting
> pressure elsewhere accordingly.

Alright, so IIUC that means we just need patch 1/3 for now (with the
per-bdi lock instead of the global lock). If that's the case I'll focus
at that patch then.

> 
> Tejun said he'd rather see the sync(2) isolation be done at the namespace level.
> That way if you have fs namespacing you are already isolated to your namespace.
> If you feel like tackling that then hooray, but that's a separate dragon to slay
> so don't feel like you have to right now.

Makes sense. I can take a look and see what I can do after posting the
new patch with the priority inversion fix only.

> 
> This way we keep cgroup doing its job, controlling resources.  Then we allow
> namespacing to do its thing, isolating resources.  Thanks,
> 
> Josef

Looks like a good plan to me. Thanks for the update.

-Andrea

