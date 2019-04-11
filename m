Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C76BDC10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 20:17:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76CCA20850
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 20:17:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76CCA20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12E566B0269; Thu, 11 Apr 2019 16:17:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B5D86B026A; Thu, 11 Apr 2019 16:17:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBF336B026B; Thu, 11 Apr 2019 16:17:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 99BB06B0269
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 16:17:30 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r6so3615983edp.18
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 13:17:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=t4ln4pbYHnRv4LXcHnqySlfcCKPATkrpZDdunm/Rrjs=;
        b=uZFgDV0WphesZ4c4wnqHcbSWoEiLJIpV3VXI22snzWvR2kCY2c8SGjbG/7lB16VEQ0
         a0NnHxDZ5w+sBncmAYSfwp/EAV20myVUUQ+fx8wuYE3HkQrb7xIRAXvOzpPZr7NKvnBT
         iMl7ZAcjBDq5yDKugltfJlJe71W1QU5H8CAlvbFYPMmBMq3ghAVEhymU1Agp6Dbhnwb2
         2ZcnA7oCqPBQZhc0ZEu1S8NFqoq4MuOZjDJ7yoTrTRL2DSvRhqakwzWWTxt2ciHWJ4+/
         0psZPcFVAL5r/FthdHA9RCFJEe10PUFKWuiJcr5clnhr+ZMPiY7mQtD2YhuZF5F0Wo55
         ZzGg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVszmie0ZcQLcupu7k/9Kg7IaJHMaXic+SeB/vHD0+P5hnzdq1b
	TANAnDP8bbKou0aMxoKXFMduNOeeO9TqhJ35QybQxb5sE692jBzpDo+QTRo9cqQx2h1Iu6/AJTv
	7yAsb6RJpaHs3SLDS1jV+0rSF7lUBPvZSCc3plhKkuBTQ2jN7ds2vdv/BbHsO5u4=
X-Received: by 2002:a17:906:828f:: with SMTP id h15mr28531713ejx.170.1555013850158;
        Thu, 11 Apr 2019 13:17:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwV9I+Ga/0jb61G31UtVTFqAVIYoUgqtbzj+n6FzREB1unLw7bdxAt6lACxVUdeuyz1dJUu
X-Received: by 2002:a17:906:828f:: with SMTP id h15mr28531685ejx.170.1555013849355;
        Thu, 11 Apr 2019 13:17:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555013849; cv=none;
        d=google.com; s=arc-20160816;
        b=GP5WlQmY8XJdqWG5L7wT7BgysUrRWqvMUdH94d4xrFrS97f4op55QFD6xGYOJseKh3
         viec58IR2NKam14xwWGulntqyyhJL1XVBgZp9XBcy1240zejWZhBISxb+rxjWrRc0ArS
         Uyi0JWgpFS/qEF6aO6EOg4hxoTweDsmfqyQmFCSe/ggZNFoS1GdT+zL0cO6cn7jo76+f
         uqtQerQXVXFyX9LHlj8fnZKNd9C37/20enLG5jt745MOVI+605V0re1vC5r12N1yuiRd
         EQ+J6yrmf+ugzu3/6XwQI65q00QWaWR6+wMmZ+4eSDLjeORHRx9A/U+NrgoUaqpkqCnv
         ZxnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=t4ln4pbYHnRv4LXcHnqySlfcCKPATkrpZDdunm/Rrjs=;
        b=ygVfDAyT+3mDtx+J8q8S9BULIuCxNmQuOEtqj61ssPLTec4Dc+1jVlJ0IdKIJalz64
         WdmNembM8KotOF/Ohq+HCWUMM3MZ2SbOEq0Osu2lDID9xcGlMnd+BScdKFeY5Xf7X/3F
         N4742w682yxcNO95WpMRh3RJTR9G61QIZ12yRobBNMnf26qU6vnBSQfLLG0lZ7t+kdqb
         nQ5ASgTtACzEg/YMb7HraRe3OPFLrRZ8sQ1MCZ1RQa+MiU9DD7xialZzm8eiJbTa21zz
         WpWT34rMKrTBbVmrXSW9kmOKwEq0khN275EaL9SO6ZjUkFzUpnZlsCt5WhtcrNhVUd+8
         dM7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cd19si3101903ejb.207.2019.04.11.13.17.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 13:17:29 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 782F4ADD8;
	Thu, 11 Apr 2019 20:17:28 +0000 (UTC)
Date: Thu, 11 Apr 2019 22:17:27 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	Matthew Wilcox <willy@infradead.org>, yuzhoujian@didichuxing.com,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Shakeel Butt <shakeelb@google.com>,
	Christian Brauner <christian@brauner.io>,
	Minchan Kim <minchan@kernel.org>, Tim Murray <timmurray@google.com>,
	Daniel Colascione <dancol@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Jann Horn <jannh@google.com>, linux-mm <linux-mm@kvack.org>,
	lsf-pc@lists.linux-foundation.org,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-team <kernel-team@android.com>
Subject: Re: [RFC 0/2] opportunistic memory reclaim of a killed process
Message-ID: <20190411201727.GB4743@dhcp22.suse.cz>
References: <20190411014353.113252-1-surenb@google.com>
 <20190411105111.GR10383@dhcp22.suse.cz>
 <CAJuCfpEqCKSHwAmR_TR3FaQzb=jkPH1nvzvkhAG57=Pb09GVrA@mail.gmail.com>
 <20190411181946.GC10383@dhcp22.suse.cz>
 <CAJuCfpERmBzCpRTj5W1929OOiVEjcdBoSAsYXiYKoq0gsgRyhg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJuCfpERmBzCpRTj5W1929OOiVEjcdBoSAsYXiYKoq0gsgRyhg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 11-04-19 12:56:32, Suren Baghdasaryan wrote:
> On Thu, Apr 11, 2019 at 11:19 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Thu 11-04-19 09:47:31, Suren Baghdasaryan wrote:
> > [...]
> > > > I would question whether we really need this at all? Relying on the exit
> > > > speed sounds like a fundamental design problem of anything that relies
> > > > on it.
> > >
> > > Relying on it is wrong, I agree. There are protections like allocation
> > > throttling that we can fall back to stop memory depletion. However
> > > having a way to free up resources that are not needed by a dying
> > > process quickly would help to avoid throttling which hurts user
> > > experience.
> >
> > I am not opposing speeding up the exit time in general. That is a good
> > thing. Especially for a very large processes (e.g. a DB). But I do not
> > really think we want to expose an API to control this specific aspect.
> 
> Great! Thanks for confirming that the intent is not worthless.
> There were a number of ideas floating both internally and in the 2/2
> of this patchset. I would like to get some input on which
> implementation would be preferable. From your answer sounds like you
> think it should be a generic feature, should not require any new APIs
> or hints from the userspace and should be conducted for all kills
> unconditionally (irrespective of memory pressure, who is waiting for
> victim's death, etc.). Do I understand correctly that this would be
> the preferred solution?

Yes, I think the general tear down solution is much more preferable than
a questionable API. How that solution should look like is an open
question. I am not sure myself to be honest.
-- 
Michal Hocko
SUSE Labs

