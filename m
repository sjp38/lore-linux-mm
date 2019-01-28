Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5458C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 18:43:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A9582171F
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 18:43:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A9582171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CCE68E0004; Mon, 28 Jan 2019 13:43:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A2988E0001; Mon, 28 Jan 2019 13:43:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B8D08E0004; Mon, 28 Jan 2019 13:43:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C43F08E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 13:43:29 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c53so7043869edc.9
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 10:43:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=eSCONVniLowfB1CBvBEoHaNs1FSH35uheXYvvr6XGr0=;
        b=WEjJw8344/yBogvJrtBfy5ga/n80hjJtcPXCe1olGozCiO2ewaTLgl0Khh1QvxL1C+
         ni+d8Nom6efxeVxzVGjrjhslsFNDP7GKMf5OosB+qyqt8IeCeS1AGcS4/GvwuzZv4rYY
         /FH9dbW2H+HvtZMW+d6or4LipM+Prv4PMg0RXeh5FeIO2BzLEXnDLDrCnUZSzyV90C0s
         Ym47I2VkXhISM7Z9o48FVzQSR2bN1ZOThudQ/6ELY1jv16UG40iUpsfpj6cQRLheYTFr
         WLJpOju7T0yGUhnr2krobG2p9z4H98Y6TxPexi+Jdmg+cfLZMfqUHcvU+nAh7he5aD+M
         KGMA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukdO/thv8+sZgrZ1zx8sZhGYDFRp7Cu7ZjxiTYvlNMdCY/DDhwPB
	FvVelDSxQSnyXnvMXenBwEAwbulcWgjTf05AKpYUtrpODImlVEoKfOKqZhtOD9ExbOKV794u2OG
	Sdb9L4aCVKC6GJzAFwDAW+XiHfEyS0EO677U7nO8D7EmsQh5Jh4F+dy4poYklFik=
X-Received: by 2002:a50:ee1a:: with SMTP id g26mr22217917eds.266.1548701009277;
        Mon, 28 Jan 2019 10:43:29 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6DGrgz1KTrE2YfWCn85mHHmu5Zhj/0klFgovjWpxUxIL+gFDKLensqzD2rPKwaIKNOLz/U
X-Received: by 2002:a50:ee1a:: with SMTP id g26mr22217879eds.266.1548701008457;
        Mon, 28 Jan 2019 10:43:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548701008; cv=none;
        d=google.com; s=arc-20160816;
        b=Gb5CHbugp+W6BxNmUGJqWKPt79DIqr1aOnV28l/+6O1sdYkFRn0XxBSxpAIv5XdLIR
         o6NgSk6E6Su+dEgBD2cUIEBbiN/IQWhAmAS5Hyza2nz739oXFFXAJU3Mns1vtEky01LW
         /RiNEg/E3uGzvLvd85KJcDpC3RU3herSLprB+fE7lSRgQcJEdnO+IQUSwE8lclXDC/30
         x3U/N+x4MA88PkxglkCgcD9ohL7pJxh7WoZx+ZRkN7JdiM+6ska9Ag9zmlgRXUZBN1fS
         s3EpJ3AN4D0a3NccTWvPvIRniXUbSEb97n7QkLLZ24h/uIsbxBlShA37sV5Na9wUlxUH
         bOEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=eSCONVniLowfB1CBvBEoHaNs1FSH35uheXYvvr6XGr0=;
        b=hEh6fWMQ2BgXMcI885ybcl/yDFC81whWk6j2HbVIIIn0O2Sz+nvTHkvYUSTbM7R9ON
         Ehzyhi6v7H20Hvn8xCbGNceQLdXQPuUh+OJBzUWuwMdmvpa1Knhi/gZLJMVVLsmJIP+E
         I3AVaxUzt7dKdnx2IJ88vcyAIYEDCejGsnT5HPWCmMqfN7Av8KgnW3yOwT1zUo+Wi+OY
         j6EzVcJpHqm7vnvGHsWTWGiYS7yhiNdZvedf97LGcY/sXiiDWklW36s2Tt8XDE0XuH7H
         a7lDG9vsaNHaV3WgoRcrzEJh2f6nrWYnx4SCU79Lgrt1eXhoQA0t3NXoX7XYqkDVEbgm
         8Egg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b7si1702913edy.138.2019.01.28.10.43.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 10:43:28 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E8810B018;
	Mon, 28 Jan 2019 18:43:27 +0000 (UTC)
Date: Mon, 28 Jan 2019 19:43:26 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, mm-commits@vger.kernel.org,
	penguin-kernel@i-love.sakura.ne.jp, cgroups@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: + memcg-do-not-report-racy-no-eligible-oom-tasks.patch added to
 -mm tree
Message-ID: <20190128184326.GT18811@dhcp22.suse.cz>
References: <20190109190306.rATpT%akpm@linux-foundation.org>
 <20190125165624.GA17719@cmpxchg.org>
 <20190125172416.GB20411@dhcp22.suse.cz>
 <20190128102616.d7d63f8e1ecdf176bc313f8a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190128102616.d7d63f8e1ecdf176bc313f8a@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 28-01-19 10:26:16, Andrew Morton wrote:
> On Fri, 25 Jan 2019 18:24:16 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > > >     out_of_memory
> > > >       select_bad_process # no task
> > > > 
> > > > If Thread1 didn't race it would bail out from try_charge and force the
> > > > charge.  We can achieve the same by checking tsk_is_oom_victim inside the
> > > > oom_lock and therefore close the race.
> > > > 
> > > > [1] http://lkml.kernel.org/r/bb2074c0-34fe-8c2c-1c7d-db71338f1e7f@i-love.sakura.ne.jp
> > > > Link: http://lkml.kernel.org/r/20190107143802.16847-3-mhocko@kernel.org
> > > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > > > Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > > > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > > 
> > > It looks like this problem is happening in production systems:
> > > 
> > > https://www.spinics.net/lists/cgroups/msg21268.html
> > > 
> > > where the threads don't exit because they are trapped writing out the
> > > oom messages to a slow console (running the reproducer from this email
> > > thread triggers the oom flooding).
> > > 
> > > So IMO we should put this into 5.0 and add:
> > 
> > Please note that Tetsuo has found out that this will not work with the
> > CLONE_VM without CLONE_SIGHAND cases and his http://lkml.kernel.org/r/01370f70-e1f6-ebe4-b95e-0df21a0bc15e@i-love.sakura.ne.jp
> > should handle this case as well. I've only had objections to the
> > changelog but other than that the patch looked sensible to me.
> 
> So I think you're saying that 
> 
> mm-oom-marks-all-killed-tasks-as-oom-victims.patch
> and
> memcg-do-not-report-racy-no-eligible-oom-tasks.patch
> 
> should be dropped and that "[PATCH v2] memcg: killed threads should not
> invoke memcg OOM killer" should be redone with some changelog
> alterations and should be merged instead?

Yup.

-- 
Michal Hocko
SUSE Labs

