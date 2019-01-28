Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CB6CC282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 18:26:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 302B421783
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 18:26:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 302B421783
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C89788E0007; Mon, 28 Jan 2019 13:26:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3A258E0001; Mon, 28 Jan 2019 13:26:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B504C8E0007; Mon, 28 Jan 2019 13:26:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75EA38E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 13:26:19 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id o23so12392435pll.0
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 10:26:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2SwcxLvTj2XjgGRHJsDSZKkK0f/9HJEExqbOcln5oV4=;
        b=c2+a5p/IYpLOVI30POVpKZerytBf9SYs7SKJhXY0ID9avTNQEpczyDK9ddJzSDDUGg
         x5TJxeuXpIf/BHmbFhP5dpc/fFZ6YDPEfHusGYdB7oZiccUXJpAMMuN2xa+RFXYCvxd7
         uq1JA2JDCdVXKcOuzJ+AmP3cZxy6rY6oKH7CwcZ0+Gs990TBtvlLL6iMNwEgZeAE9SBi
         5ZeU4r5kk5Aqe/IoZ3RqyEUlaEeFSOn8bnmfgmT0FuKx32EBI4X2LItBNi99AtM3i4O1
         6LYeudSwktCOYs2Gh835Ohf+wMocHYzzpaenZux8l8Ftdh/RmvG83B7xaT2/q44DGIV1
         7Xgw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUukdS4EBqgOe7i0adF+Ssg8zR+TM3oWJiuzghOs6yNH4NxjvLPvkz
	z4rt+/IyCzgElFMIJ78BSKQN1aKRdIAcMgxBazI4Fqv99Xk4OPH/T7vFazBCf1zMZX0A80Y54Ty
	78kYE9WUSd16Oi2vKkXNMmJ3qnCdHi/uP/TcdU5CALEVQgZemBOgGEldgjuRggxxU7Q==
X-Received: by 2002:a63:af52:: with SMTP id s18mr20909867pgo.385.1548699979135;
        Mon, 28 Jan 2019 10:26:19 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6xTQRLL4nqVpl1/ljFTwqneXi8tsqMRvRbBPEosFHIE6gYVsOef6WWJ7QsuU+5DbVkBOgy
X-Received: by 2002:a63:af52:: with SMTP id s18mr20909826pgo.385.1548699978401;
        Mon, 28 Jan 2019 10:26:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548699978; cv=none;
        d=google.com; s=arc-20160816;
        b=nRIdA54zLqVMOGhcnO20xb6jIiSxDXLehgUz0QozZRGJh4k+xDlDN4I2+2xgD2Din7
         /C3TiC4HbZCn1zV+FrcgYUiISGrxg6NBsleY1nm/nL0PENgEgwXrlliQz5zVKfSKgomu
         yiGD+Ud4yGRm72hNksxA6WFdgJNAWtc7mjoFTjMXRtA1YYcgj08kqdwvKsGrdB/ViOqt
         dXopyaxcK3EAFIIVP2orpR1Zgci4OV0aZRjZ7H1WcZxDB4VjQVOmUT4K1ypDZdE1qFqn
         pkxm95vS+mm9mWi8jsZPVIFTFw2FGIn8Eh0KRemojwdwn42OvFoC0+488Sn2IZWJyFR3
         0XAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=2SwcxLvTj2XjgGRHJsDSZKkK0f/9HJEExqbOcln5oV4=;
        b=d5J5oGLhDaRr9+gzQPm1YTMOx7fc1778Y1EUU4ZAxrietQ6Pg5csHNSOS9pOEmZOda
         Xls3jxvDeiOii9yBnfG2o/OlWwJXPYZnYpmhd7F29x2v2MoQqQ6P2v+qY40kRUUO7d6h
         hIiX+FDdJjXquttRBflExi8qz7Dw3oe0OjMDpVOLmoWQxCgh0urOfFfAITNtRcBtKiko
         CWyhXgNMyx52uk/ORdAxngwTIlAQimkmE9qXURtUawfVE2S+lxaQGcJK8b55RtSu721B
         /izzpDG6cEufhybghKeYfsfSoAOI5BdVCVHaixmNVBL0QnefSMYf2mxV1Qn6O718AFQS
         enZg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y7si30415007pga.296.2019.01.28.10.26.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 10:26:18 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id D854120E9;
	Mon, 28 Jan 2019 18:26:17 +0000 (UTC)
Date: Mon, 28 Jan 2019 10:26:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, mm-commits@vger.kernel.org,
 penguin-kernel@i-love.sakura.ne.jp, cgroups@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: + memcg-do-not-report-racy-no-eligible-oom-tasks.patch added to
 -mm tree
Message-Id: <20190128102616.d7d63f8e1ecdf176bc313f8a@linux-foundation.org>
In-Reply-To: <20190125172416.GB20411@dhcp22.suse.cz>
References: <20190109190306.rATpT%akpm@linux-foundation.org>
	<20190125165624.GA17719@cmpxchg.org>
	<20190125172416.GB20411@dhcp22.suse.cz>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 25 Jan 2019 18:24:16 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> > >     out_of_memory
> > >       select_bad_process # no task
> > > 
> > > If Thread1 didn't race it would bail out from try_charge and force the
> > > charge.  We can achieve the same by checking tsk_is_oom_victim inside the
> > > oom_lock and therefore close the race.
> > > 
> > > [1] http://lkml.kernel.org/r/bb2074c0-34fe-8c2c-1c7d-db71338f1e7f@i-love.sakura.ne.jp
> > > Link: http://lkml.kernel.org/r/20190107143802.16847-3-mhocko@kernel.org
> > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > > Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > 
> > It looks like this problem is happening in production systems:
> > 
> > https://www.spinics.net/lists/cgroups/msg21268.html
> > 
> > where the threads don't exit because they are trapped writing out the
> > oom messages to a slow console (running the reproducer from this email
> > thread triggers the oom flooding).
> > 
> > So IMO we should put this into 5.0 and add:
> 
> Please note that Tetsuo has found out that this will not work with the
> CLONE_VM without CLONE_SIGHAND cases and his http://lkml.kernel.org/r/01370f70-e1f6-ebe4-b95e-0df21a0bc15e@i-love.sakura.ne.jp
> should handle this case as well. I've only had objections to the
> changelog but other than that the patch looked sensible to me.

So I think you're saying that 

mm-oom-marks-all-killed-tasks-as-oom-victims.patch
and
memcg-do-not-report-racy-no-eligible-oom-tasks.patch

should be dropped and that "[PATCH v2] memcg: killed threads should not
invoke memcg OOM killer" should be redone with some changelog
alterations and should be merged instead?

