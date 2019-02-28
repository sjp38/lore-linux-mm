Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1673AC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 09:26:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D02432184A
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 09:26:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D02432184A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A3BB8E0003; Thu, 28 Feb 2019 04:26:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6529E8E0001; Thu, 28 Feb 2019 04:26:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 590C68E0003; Thu, 28 Feb 2019 04:26:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id F14D88E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 04:26:44 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o9so8226286edh.10
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 01:26:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=35jqpRd33/VtXYnnM9QecXKDD06sRe7+EDfuxxc863Y=;
        b=au4Sbl0go0Dduw+SqAgsFEH8Gni7n1DyK4kGUcecHk6qlVPA9A6e5r2ErK0TTkVDqV
         vkZWUJOEx1LvCvd37vmkS5DLPeA5r/sa6+Tj5uvkUuZWWO8b2l7XqsE8WtYwsK2jtZT7
         SavNBfarS1DQDg2aXALDWhKjjFoD+tzt3+vqUqGULRfatwQdr1ZZvqFR7zdg8uzooyci
         xg0Eo3vIQM06zuUB/KUK8md9dvUvum5fuKmFAxX7qVvaUKVskmna7/+INt80LT6Yb+kc
         YiiXuoSMpCijoO9LnaNPxbSa021iocPO2PmkAb4Ax1T7epBF/Lv+4lrOJOUsmr6XzAoR
         2jBw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZy6B7qIfsfp2aVkTQB1y+lieKrhFtY7J1WHjrmVh6UXCqpt2im
	xN+HpAVgRUULNON7KTFn9BohFr0CphKPol+cWoRgaCD3sepKrRdb2P116ww66jStUboT20KH4D0
	DUcYcjqYO4VbakBoP+ap8KjErGD8yejafz3aZhkB1b8GTpQDHkxlJ5DkJIckR9Jo=
X-Received: by 2002:a17:906:28c9:: with SMTP id p9mr4601952ejd.43.1551346004515;
        Thu, 28 Feb 2019 01:26:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ6nGxuSsqmv61JMg8qtsVvjKh75GYz9LHM+GpLaZLVW7RnoFfAGUuUko4zm3DvUDNcoT5s
X-Received: by 2002:a17:906:28c9:: with SMTP id p9mr4601920ejd.43.1551346003548;
        Thu, 28 Feb 2019 01:26:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551346003; cv=none;
        d=google.com; s=arc-20160816;
        b=RNaZZ6tuaQrb2DbFUR7vqLhVBcZPxZP/+XtERxIS/rWRdM1OYYCpO6YVgvIcq041LS
         4vTEcVMEh9Bjjny0L60ocvT6r0ZwAvFYrWFME6bmZZerolucgBUcDVdK2pdAIkT3xVVV
         /LSRIANczx6/F6AuckgckgM0n9vneIFhpXauj5TVhKVMU0yC9O6qwr+HYgh4tQ/DZd4e
         e9UoIhEdtt2pvaM2aApm9pvymu5TkekRYqqlGCB5s6ra0MT9m2YbLR/Mv9BvwD3z80D8
         X/wXprIFMGEXFB+7Xq9fciLgRmZo+Z74ex0gXfzMw3mVwTyH2nFj812GrVzajTP1Q+X4
         JVHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=35jqpRd33/VtXYnnM9QecXKDD06sRe7+EDfuxxc863Y=;
        b=XHwbEXc2EL/19UTHornwFd51B+J6Za4UoLOfZBA7I02ok0nb0ruH6bKk08FOFvDeOs
         G6O8kLOirFzckRa7UDBLCqBMd/+TJ02x7pkN9DV174sIENQuHvvLtuteXq7H7hYUNKs/
         gLnGsqXwfHt3ZPNQ2VXyUFHFWKhoEWN+YjTp9DZY2JmGkgzhpqaB52MOLQ7XRIzP+BRj
         9boEv5HBtDleu+uTSGZIALib1ODyBdIGIE44pSHmFJh8uO3YzDuHiBsoKtzLskCwZJSK
         w5MwRdAFf1zZwR9gcPYFYMnqsqBJmxvROm0qQBjFPIdl2vWrBO5UAOLmbElc/LYJlEed
         II8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i20si949585edg.279.2019.02.28.01.26.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 01:26:43 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B57FBACC0;
	Thu, 28 Feb 2019 09:26:42 +0000 (UTC)
Date: Thu, 28 Feb 2019 10:26:41 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org
Subject: Re: mm: Can we bail out p?d_alloc() loops upon SIGKILL?
Message-ID: <20190228092641.GW10588@dhcp22.suse.cz>
References: <201902270343.x1R3hpZl029621@www262.sakura.ne.jp>
 <20190227092136.GM10588@dhcp22.suse.cz>
 <ccd9e864-0e47-b0e3-8d0e-9431937b604c@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ccd9e864-0e47-b0e3-8d0e-9431937b604c@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 27-02-19 19:39:19, Tetsuo Handa wrote:
> On 2019/02/27 18:21, Michal Hocko wrote:
> > On Wed 27-02-19 12:43:51, Tetsuo Handa wrote:
> >> I noticed that when a kdump kernel triggers the OOM killer because a too
> >> small value was given to crashkernel= parameter, the OOM reaper tends to
> >> fail to reclaim memory from OOM victims because they are in dup_mm() from
> >> copy_mm() from copy_process() with mmap_sem held for write.
> > 
> > I would presume that a page table allocation would fail for the oom
> > victim as soon as the oom memory reserves get depleted and then
> > copy_page_range would bail out and release the lock. That being
> > said, the oom_reaper might bail out before then but does sprinkling
> > fatal_signal_pending checks into copy_*_range really help reliably?
> > 
> 
> Yes, I think so. The OOM victim was just sleeping at might_sleep_if()
> rather than continue allocations until ALLOC_OOM allocation fails.
> Maybe the kdump kernel enables only one CPU somehow contributed that
> the OOM reaper gave up before ALLOC_OOM allocation fails. But if the OOM
> victim in a normal kernel had huge memory mapping where p?d_alloc() is
> called for so many times, and kernel frequently prevented the OOM victim
>  from continuing ALLOC_OOM allocations, it might not be rare cases (I
> don't have a huge machine for testing intensive p?d_alloc() loop) to
> hit this problem.

We cannot do anything about the preemption so that is moot. ALLOC_OOM
reserve is limited so the failure should happen sooner or later. But
I would be OK to check for fatal_signal_pending once per pmd or so if
that helps and it doesn't add a noticeable overhead.

> Technically, it would be possible to use a per task_struct flag
> which allows __alloc_pages_nodemask() to check early and bail out:
> 
>   down_write(&current->mm->mmap_sem);
>   current->no_oom_alloc = 1;
>   while (...) {
>       p?d_alloc();
>   }
>   current->no_oom_alloc = 0;
>   up_write(&current->mm->mmap_sem);

Looks like a hack to me. We already do have __GFP_NOMEMALLOC,
__GFP_MEMALLOC and PF_MEMALLOC and you want yet another way to control
access to reserves. This is a mess. If anything then PF_NOMEMALLOC would
be a better fit but the flag space is quite tight already. Besides that
is this really worth doing when the caller can bail out?
-- 
Michal Hocko
SUSE Labs

