Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0FE7C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 08:05:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7AFE4214AE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 08:05:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7AFE4214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 13EFA8E0003; Tue, 12 Mar 2019 04:05:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F0CC8E0002; Tue, 12 Mar 2019 04:05:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F1FC58E0003; Tue, 12 Mar 2019 04:05:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 98DF38E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 04:05:35 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x47so724584eda.8
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 01:05:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=PnZH9gEna2A0B89ORaNc6cIrFvLDGY87+yg2rusnRGE=;
        b=rDdbO9zysc86bN+wERvG0GZAX0nRA8mq2g76rDA1Fkl/+ZY00QH6n/KpomEQbIvG+B
         mb20JWSyR/kOQxaoiuORIQU6BwyVTXd4DmFNV798vkTYi3y2DvMni87r9FsBxLWPQZWg
         tqjvCEr+TElG2KvnZRH2sPmqjvcV7kNi3KhQJmskq2vMXLO/0qX8VWKQvXRBbqQcTl5K
         Nn8wQPjh1/SHRo1InfsL5ZYFskMWVYB+d+76szwwXeVRLvcQ51bpyudXAeR7Beiycqbe
         0TaUPviS3v21Lo4hqI/6nbLUOl0pTEzTzzauVEuOkC/XMgPpkWoqhEXuoR31ZwR63NBa
         Nqvg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXjHMvx9rIcOIQ3JlRRCKe1VFnD1dL5ezbolglOobLlz3az0E54
	4ZvYboutTS96D5P84lGhe+MOp5y54iOMzq8o4o+VvVatiEueXv0sAjjdyB/hsW2jxAYP4C3JSX2
	oZK8JIG5l9X2xG9UbydKpdbCW9XNNhjsLP+ClcZI8CIC+Cvyafj7KQJewP84N6i8=
X-Received: by 2002:a50:b4e6:: with SMTP id x35mr2308242edd.123.1552377935123;
        Tue, 12 Mar 2019 01:05:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlrzNkYaopZvi0Jk75DLu4WJ9zxlvWB6GGslhmbBDPoGyYs4AGghq86AoH+wZ8OfNcCSyA
X-Received: by 2002:a50:b4e6:: with SMTP id x35mr2308187edd.123.1552377934207;
        Tue, 12 Mar 2019 01:05:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552377934; cv=none;
        d=google.com; s=arc-20160816;
        b=TYa/3ew9wWOAouGOOt7lvQVJ5v+NvTxbAzTLwcvEIMbPwz5VxdPTvSPYsn/gJluM64
         HqThebqg1OYRrgRmgSRTI6YrCUBkmXQ93otUnMila8tc9844XrxYSI/s2+Bhy6uXOIn+
         TGuvnMTABMNNfV8Qsl1IrvhXHpZ/2XNIJAOZmveO0nQNTC2kAyEoygjHDNkEMhQNq+nc
         6QtbN6aA3OpKU/0N5t5Z8Z5kXKEjpnq0Dn0a7Zhz7QW1GIXxlVAUtn0OyjgSFa7U/xr0
         50hLv2knybCLcuoYJCNtEKirlqNXzoxaH/JmPSwBFJTSJMNpXzx9E4zlrm4IerR1X/KK
         Ehzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=PnZH9gEna2A0B89ORaNc6cIrFvLDGY87+yg2rusnRGE=;
        b=UJXWfGSwlfm5KIdfxUMItpzSCg04IhzzBitCitGuDw1vepTk4cU8lElrB26GRONI4B
         wqAqlpFZnkCOMrLxzbH370e+Izw5QU5XmE8sE1Wa1IgVAJPfizbncAqiIzNN1KPHGCTh
         QyZJSNgJEA0r2XpflejpG9YmbgqZjjYmb0fk8fsm4PjEYlWKD+21WFI5Es3bPF+haAvj
         9TyaIKyHoVWuzk2s/ztKxSVUV8zkLbrU+spRR4QhzujGN80Kpo3fcYSv2ycVHY7bKTXP
         LNh72PD5s2uUaAs4Gjnq9mzjwZPWkDzBZYdY+5+bh0Y7MV8Wq5gQ56/OcHrNvnAiwIK3
         34Hg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n48si5105893edd.114.2019.03.12.01.05.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 01:05:34 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 64782B608;
	Tue, 12 Mar 2019 08:05:33 +0000 (UTC)
Date: Tue, 12 Mar 2019 09:05:32 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: Sultan Alsawaf <sultan@kerneltoast.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Christian Brauner <christian@brauner.io>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, devel@driverdev.osuosl.org,
	linux-mm <linux-mm@kvack.org>, Tim Murray <timmurray@google.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190312080532.GE5721@dhcp22.suse.cz>
References: <20190310203403.27915-1-sultan@kerneltoast.com>
 <20190311174320.GC5721@dhcp22.suse.cz>
 <20190311175800.GA5522@sultan-box.localdomain>
 <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
 <20190311204626.GA3119@sultan-box.localdomain>
 <CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 11-03-19 15:15:35, Suren Baghdasaryan wrote:
> On Mon, Mar 11, 2019 at 1:46 PM Sultan Alsawaf <sultan@kerneltoast.com> wrote:
> >
> > On Mon, Mar 11, 2019 at 01:10:36PM -0700, Suren Baghdasaryan wrote:
> > > The idea seems interesting although I need to think about this a bit
> > > more. Killing processes based on failed page allocation might backfire
> > > during transient spikes in memory usage.
> >
> > This issue could be alleviated if tasks could be killed and have their pages
> > reaped faster. Currently, Linux takes a _very_ long time to free a task's memory
> > after an initial privileged SIGKILL is sent to a task, even with the task's
> > priority being set to the highest possible (so unwanted scheduler preemption
> > starving dying tasks of CPU time is not the issue at play here). I've
> > frequently measured the difference in time between when a SIGKILL is sent for a
> > task and when free_task() is called for that task to be hundreds of
> > milliseconds, which is incredibly long. AFAIK, this is a problem that LMKD
> > suffers from as well, and perhaps any OOM killer implementation in Linux, since
> > you cannot evaluate effect you've had on memory pressure by killing a process
> > for at least several tens of milliseconds.
> 
> Yeah, killing speed is a well-known problem which we are considering
> in LMKD. For example the recent LMKD change to assign process being
> killed to a cpuset cgroup containing big cores cuts the kill time
> considerably. This is not ideal and we are thinking about better ways
> to expedite the cleanup process.

If you design is relies on the speed of killing then it is fundamentally
flawed AFAICT. You cannot assume anything about how quickly a task dies.
It might be blocked in an uninterruptible sleep or performin an
operation which takes some time. Sure, oom_reaper might help here but
still.

The only way to control the OOM behavior pro-actively is to throttle
allocation speed. We have memcg high limit for that purpose. Along with
PSI, I can imagine a reasonably working user space early oom
notifications and reasonable acting upon that.
-- 
Michal Hocko
SUSE Labs

