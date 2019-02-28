Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05B4EC10F00
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 21:30:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD29320857
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 21:30:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD29320857
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E6B38E0003; Thu, 28 Feb 2019 16:30:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 395878E0001; Thu, 28 Feb 2019 16:30:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2ACD88E0003; Thu, 28 Feb 2019 16:30:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id DD5088E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 16:30:38 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id t1so15983976plo.20
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 13:30:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=35wETTogbcOjrWlVJrnoIrStrH/W/SpoQEfI66MbR58=;
        b=QQXp980l/zsxLV7CUmQHpqaO4yUpEpS45FNxkhrlKkMnK09YbNaV8WE03YLvwQ2yG4
         RircwvO+t7coUVpjdzCw07pcikM9Milhkk0tWAigEG8kW4uBojjVq2zs3gRODzS43dz+
         Rqbedmy6uXZ2Eue6fxMkKFXIC2YAIeFgFtV9/TXFd60mvJA4H5kfBAIaodCpiLFK6MxM
         ur/J7LYC+rw7+tr/sjq3BWvp2Lj8I1JdI4L0I4d2i57kjPE6NwkAR44DElPItrBxlpft
         6y66bBVsvemyhUavMH0AmHHs1yymfRKI6QLheWtU6SuJmm+tpp5/edXy9bhH9Hsa99Z9
         Hv4w==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.141 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAV6ECJIu1IFKJScXU6eiZ2SHB8/xdUZa8+FcihGrSjFD+5pvCmG
	GlRTJSKE565fGOdO5cBuKzyT537R3QYF+8stQjtccxENsJ4eiyeWBiEh4oYF7YYtYkYA4LWyX01
	zNZKXt58zPe519K7Xbl+Sf92MHAO4T/bU5Dejl0rY5azpINTBCVX1Bact/DNKlAM=
X-Received: by 2002:a63:4e57:: with SMTP id o23mr1177699pgl.368.1551389438485;
        Thu, 28 Feb 2019 13:30:38 -0800 (PST)
X-Google-Smtp-Source: APXvYqzVOa5R9w+BairvGgB8OPn4yGaggoIlSN+m6JUolmYODT+Q09eYT4R/PamDrmNJBPTG5a97
X-Received: by 2002:a63:4e57:: with SMTP id o23mr1177618pgl.368.1551389437512;
        Thu, 28 Feb 2019 13:30:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551389437; cv=none;
        d=google.com; s=arc-20160816;
        b=huJcAS0JJjmUtCPKcazguaYcXnfACds7JKSxIAlHnvWn6ajGUeNiK1N+kj0aIdnoeQ
         b5JmAG7bRHqJTPLZwTYzSAi6wTz9MCZZyLdqQdmtPqjZZH6QLS4+1fmvdJDg6DzRwn1l
         +oFwYq2EjIKjD3GJlYH2qWR28xEZ0FZyq+2nB45cqHLTzQKTk0+oX3tHn92+Tpu1L3tR
         tqdZp3Dir24EQkc2o5BhqoRd3FZlPpag+Wf0GG0rmQYxevIdS1Lq+1HMGZ+I3rxW69fn
         klnjYr/x4Ykzf1br6jYwih+VwQtpw6s7C5aE52l8HhdhLjEcI16CYKN36jwDkPSbsVRG
         kWOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=35wETTogbcOjrWlVJrnoIrStrH/W/SpoQEfI66MbR58=;
        b=Djk2mYlmrJ+QrxWE1NAt0O1DgmMqa91lOn0a57eucyWnF7LU4dqW5BaEsrPaHLEEo1
         jZKuL4d90ApFXtioKiKhkrr2N9pEIk8g84BRuFtgK2FOyTAJgcStvCYDmAGie5+XjILf
         EQ4xUBhYUiS0emFTlBg8no9EDn3oYr44PSEALrzS+sdiNtYwB6lSD14YtdSU5s1j5fy2
         JTe0DWypcJnsNkw4uHKjcSEm+pncTj3sRk/ASzIbIhlcpZr7Vyv7wNY1n6igToyaI5O3
         IPy3Ag9zXesY3esxNXth+Hn2LQGaZNSOWkL/fKMK88afqitiVF6OzXRo1/6WeBdRj2ta
         4ONw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.141 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail03.adl2.internode.on.net (ipmail03.adl2.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id v3si18670252pff.158.2019.02.28.13.30.35
        for <linux-mm@kvack.org>;
        Thu, 28 Feb 2019 13:30:36 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.141 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.141;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.141 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail03.adl2.internode.on.net with ESMTP; 01 Mar 2019 08:00:34 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1gzTGC-0001Nt-MC; Fri, 01 Mar 2019 08:30:32 +1100
Date: Fri, 1 Mar 2019 08:30:32 +1100
From: Dave Chinner <david@fromorbit.com>
To: Roman Gushchin <guro@fb.com>
Cc: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"riel@surriel.com" <riel@surriel.com>,
	"dchinner@redhat.com" <dchinner@redhat.com>,
	"guroan@gmail.com" <guroan@gmail.com>,
	Kernel Team <Kernel-team@fb.com>,
	"hannes@cmpxchg.org" <hannes@cmpxchg.org>
Subject: Re: [LSF/MM TOPIC] dying memory cgroups and slab reclaim issues
Message-ID: <20190228213032.GN23020@dastard>
References: <20190219071329.GA7827@castle.DHCP.thefacebook.com>
 <20190220024723.GA20682@dastard>
 <20190220055031.GA23020@dastard>
 <20190220072707.GB23020@dastard>
 <20190221224616.GB24252@tower.DHCP.thefacebook.com>
 <20190228203044.GA7160@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190228203044.GA7160@tower.DHCP.thefacebook.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 08:30:49PM +0000, Roman Gushchin wrote:
> On Thu, Feb 21, 2019 at 02:46:17PM -0800, Roman Gushchin wrote:
> > On Wed, Feb 20, 2019 at 06:27:07PM +1100, Dave Chinner wrote:
> > > On Wed, Feb 20, 2019 at 04:50:31PM +1100, Dave Chinner wrote:
> > > > I'm just going to fix the original regression in the shrinker
> > > > algorithm by restoring the gradual accumulation behaviour, and this
> > > > whole series of problems can be put to bed.
> > > 
> > > Something like this lightly smoke tested patch below. It may be
> > > slightly more agressive than the original code for really small
> > > freeable values (i.e. < 100) but otherwise should be roughly
> > > equivalent to historic accumulation behaviour.
> > > 
> > > Cheers,
> > > 
> > > Dave.
> > > -- 
> > > Dave Chinner
> > > david@fromorbit.com
> > > 
> > > mm: fix shrinker scan accumulation regression
> > > 
> > > From: Dave Chinner <dchinner@redhat.com>
> > 
> > JFYI: I'm testing this patch in our environment for fixing
> > the memcg memory leak.
> > 
> > It will take a couple of days to get reliable results.
> > 
> 
> So unfortunately the proposed patch is not solving the dying memcg reclaim
> issue. I've tested it as is, with s/ilog2()/fls(), suggested by Johannes,
> and also with more a aggressive zero-seek slabs reclaim (always scanning
> at least SHRINK_BATCH for zero-seeks shrinkers).

Which makes sense if it's inodes and/or dentries shared across
multiple memcgs and actively referenced by non-owner memcgs that
prevent dying memcg reclaim. i.e. the shrinkers will not reclaim
frequently referenced objects unless there is extreme memory
pressure put on them.

> In all cases the number
> of outstanding memory cgroups grew almost linearly with time and didn't show
> any signs of plateauing.

What happend to the amount of memory pinned by those dying memcgs?
Did that change in any way? Did the rate of reclaim of objects
referencing dying memcgs improve? What type of objects are still
pinning those dying memcgs? did you run any traces to see how big
those pinned caches were and how much deferal and scanning work was
actually being done on them?

i.e. if all you measured is the number of memcgs over time, then we
don't have any information that tells us whether this patch has had
any effect on the reclaimable memory footprint of those dying memcgs
or what is actually pinning them in memory.

IOWs, we need to know if this patch reduces the dying memcg
references down to just the objects that non-owner memcgs are
keeping active in cache and hence preventing the dying memcgs from
being freed. If this patch does that, then the shrinkers are doing
exactly what they should be doing, and the remaining problem to
solve is reparenting actively referenced objects pinning the dying
memcgs...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

