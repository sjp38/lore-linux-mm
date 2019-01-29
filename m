Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D28C6C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 14:43:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9906420989
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 14:43:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9906420989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 352778E0002; Tue, 29 Jan 2019 09:43:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 30BB48E0001; Tue, 29 Jan 2019 09:43:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F09E8E0002; Tue, 29 Jan 2019 09:43:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id D2EF78E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 09:43:11 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id f125so14031455pgc.20
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 06:43:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Lf+lYekVrX5peqJ1BYuI15TXxt8cAjECIxDDnxjSpnY=;
        b=AuFo+Orf69VsGI/IvMmNExaGHV8bGyAr1/jd0QrgHj9jxsC1XH5E7Nyk8+UNezhH0w
         8yEbOZQlHpEdvVDB9okkdyUjQ4KjG4kMplYvQ8rXFt0tegEEBzIBkopDAN09/tbXj2dx
         A/GGOR26DaykQ5p31tZ1iAkVs8dHnk7reI92zlpphOnfoQMMUwHElmKVWYj3691OOQI/
         W7LuDq0XQFi99trauEifV2dMSp8S0i45Xwl1kVFKJWAb+yAsRrfLoQXKN0tXb4Dz6ryc
         ZOVnWL1ZaiEZ1DmDC9WhOWwKgTOt0yGIrrIZ1nLF+6eYxZYj5hGtNtruqhfFvJQhWRBs
         kv2g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukeoPSzs38AqysfaMw8EURtlgnWayPlS6PYQULIYOKjDsK6IQwyM
	kvCYRxAcK0dvyeSfpahUJLqwlNgtphV3Gt8TOvUwx5iWdKzcFu7dtMkqDV2tRbZpNY5xGvoIfTy
	PnUpum6ubLl7IPuKsWlcBuumil7PktI1Q4zYqrkCREO3zsYt0e3U7uk5IRDbl8+g=
X-Received: by 2002:a63:e40c:: with SMTP id a12mr24075661pgi.28.1548772991526;
        Tue, 29 Jan 2019 06:43:11 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7vGiKKtuS6sdEET1+ePRjmh/XHf83ggTjpFucOmPltSobSPy27Frj+ZkqExvmHAjg/jp2c
X-Received: by 2002:a63:e40c:: with SMTP id a12mr24075623pgi.28.1548772990691;
        Tue, 29 Jan 2019 06:43:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548772990; cv=none;
        d=google.com; s=arc-20160816;
        b=IOSeGFVnM4s0JK3RbKm6GWG8AIQ9zFKO/mZZG4yD7lKXX6raeu/SF/HI0Nh0dXNqz/
         BrMjItwUysEf4risJ44iyYSb/8dRsw3I2dCoruQLatp3vzXnnUrX/merBqe+A298/Z7i
         tXAMwR1Ae5w1iy9tT8cATBoOJqAXvKnYLiXMO+oR6L2emV6TqWxS3t9lTuGAQDTghTrt
         eSlAcZ2aMhCgENOj6vDnIlA4IhjdSBUY3HF0ug2thQw+5/WyzB9gxYs6XLy755zLe2WG
         B8mEl+paucoAcn7CiHjfp1LB2BzUbIZXk0JisH/qRtVn+HBSf4jr0DxulOlFsnX3Cz4y
         IgXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Lf+lYekVrX5peqJ1BYuI15TXxt8cAjECIxDDnxjSpnY=;
        b=Uy1gAEzGb4tJpFlHXyd/M10hD29AW2Xbpq4LiVW8gf8aIsgcmfY34rz0eNXR2BN7qy
         j7D81zwhVDgmoiWeqxxVTLmcaqTcY4ElxLd5fRRYMfHWiQJQpfzAfDPyiA4hvYyEd6m6
         2qP75lU5vHNi/1kmHSADTtC8CaGYVAtX9BcnAymAn4X5VBbSyTLRo8ooMxhD3UKwyq9h
         d5VoRWULgBqX4PlULnE++etYSvGDOa1X8GLA1dRVVpkEnGWHKvZPhj34QOAP3BstxNW/
         /hkZ41u9Cnp6z3tjjFf3cclN5OMp+phUHqWwSXKaZGETVpZZfHJaLZdCkp11ozV2CvwW
         nyWA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 12si4391418pfx.102.2019.01.29.06.43.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 06:43:10 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2BBAFB049;
	Tue, 29 Jan 2019 14:43:08 +0000 (UTC)
Date: Tue, 29 Jan 2019 15:43:06 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190129144306.GO18811@dhcp22.suse.cz>
References: <20190125173713.GD20411@dhcp22.suse.cz>
 <20190125182808.GL50184@devbig004.ftw2.facebook.com>
 <20190128125151.GI18811@dhcp22.suse.cz>
 <20190128142816.GM50184@devbig004.ftw2.facebook.com>
 <20190128145210.GM18811@dhcp22.suse.cz>
 <20190128145407.GP50184@devbig004.ftw2.facebook.com>
 <20190128151859.GO18811@dhcp22.suse.cz>
 <20190128154150.GQ50184@devbig004.ftw2.facebook.com>
 <20190128170526.GQ18811@dhcp22.suse.cz>
 <20190128174905.GU50184@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190128174905.GU50184@devbig004.ftw2.facebook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 28-01-19 09:49:05, Tejun Heo wrote:
> Hello, Michal.
> 
> On Mon, Jan 28, 2019 at 06:05:26PM +0100, Michal Hocko wrote:
> > Yeah, that is quite clear. But it also assumes that the hierarchy is
> > pretty stable but cgroups might go away at any time. I am not saying
> > that the aggregated events are not useful I am just saying that it is
> > quite non-trivial to use and catch all potential corner cases. Maybe I
> 
> It really isn't complicated and doesn't require stable subtree.
> 
> > am overcomplicating it but one thing is quite clear to me. The existing
> > semantic is really useful to watch for the reclaim behavior at the
> > current level of the tree. You really do not have to care what is
> > happening in the subtree when it is clear that the workload itself
> > is underprovisioned etc. Considering that such a semantic already
> > existis, somebody might depend on it and we likely want also aggregated
> > semantic then I really do not see why to risk regressions rather than
> > add a new memory.hierarchy_events and have both.
> 
> The problem then is that most other things are hierarchical including
> some fields in .events files, so if we try to add local stats and
> events, there's no good way to add them.

All memcg events are represented non-hierarchical AFAICS
memcg_memory_event() simply accounts at the level when it happens. Or do
I miss something? Or are you talking about .events files for other
controllers?
-- 
Michal Hocko
SUSE Labs

