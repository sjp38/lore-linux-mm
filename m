Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE95DC282CF
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 17:05:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9537321741
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 17:05:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9537321741
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D88B8E0004; Mon, 28 Jan 2019 12:05:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 286CA8E0001; Mon, 28 Jan 2019 12:05:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 150938E0004; Mon, 28 Jan 2019 12:05:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A81E98E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 12:05:29 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id x15so6896798edd.2
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 09:05:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Zx+Y/aRKp4CmUhZaZYeRQinQx2Q0AeBydieP60CheHs=;
        b=cGCmbpbKeWT/XdBdmrThyJN5lc9UbL0mzlr3l5nKpR6I7s7YwnI4b6iA4PJwJQhgwK
         4lwJKkMgRUdbEzendGRtcWdmizCBv4BsESKPPUuw66uYK9N8GDW5ktT+cdvBhs/3H0/8
         thFM1+QJXU/csnKa30N6Pj+8yk4+5YO7+L7+lnxgnBA6ehtcwmzbvLbLDJxNZAcfF/Rt
         I/ynzxHRQjU3eVCsiPJl3GlAfmSKavH/1W0KHaAOv3zs8Ew4YQYBHgZM8NRSAki6IK2x
         FiNAqLvzcadII7OIlhhBLFmOyfL99koyZvKSCHn7BtNX+G0w+wUl2NWE3zwy8csUFzBy
         a+Zg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukfbL3JC1/FQCbFSLbnJYcIv6QGtgnxWP/8h1tlsQGDYIjQLAwle
	7dCDWXmNnNVKoyzng5cuZtZVUpWHC/iLFYQxojpp7eCMc1fbvo45PXLGZlAvKB9HuoH6FQrMR2v
	QCnVDJUY91UGElaAmAYfrWFlmad4amux2xlvMkIjO00sJ+Oks47Xoke9xGGmr4Vo=
X-Received: by 2002:a50:ac81:: with SMTP id x1mr22832095edc.71.1548695129211;
        Mon, 28 Jan 2019 09:05:29 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7X+8KXrTUgiloG+whYCXQ8H699G3esYHHCQTpukTXwrxXvyoICOnJBg1BvWpJdlSUK1jhE
X-Received: by 2002:a50:ac81:: with SMTP id x1mr22832040edc.71.1548695128183;
        Mon, 28 Jan 2019 09:05:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548695128; cv=none;
        d=google.com; s=arc-20160816;
        b=mWncfylMPyWEtu/DSQYo8LIMQMX+b+gWqkFTLDQidVNI6ap3Zar9AR729uf1O4ElRV
         CB1xBbie4or1UJUC2i75QyqqmPPJ+bBzrCewdiQ3sswnwqz7g2eaB23DIvmZnZxCNPit
         8fEDJ9HkUwRtGjtJzgAPtkQXuKOcxoQwW6atMVTTQvYvf942lKKeEH9clF8Omvh7/C6R
         6UcULDEDOgMsnERADUgnPQ+iDgLJXJVarnG7YJq7pu28sCdJ8n+GEn2Plf91K8N+mRJn
         SwM+ffjX1gdMyxGQBKpM5SL1+9PZa3wSy9Bh05yOW4M0LUzMRG0li9JixI15pZAkKxnt
         woSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Zx+Y/aRKp4CmUhZaZYeRQinQx2Q0AeBydieP60CheHs=;
        b=0wjrDjznng/o5FhCR5GCbIel0G1638rggsM9r1sSd+ZaUpuETHVZIAvv/9EBJUptGQ
         PEJnvOHT/vcZww71++oeXbsI2nl6Ryv53gOyPLgAV1mh1hPENpmzdymdOV135UfqEjdU
         8BiQdTRjgw/UxcWU2RFl53tH9SID86eRZ5m/PUXoFJwCpkgbqVaO9x+XLIUfSrjq7ub6
         utxIEo2BflgI01fE4gH62mLjz9Fn8WCT5NoW9fPncRKZ/3MPst/L/A9uB/NRaIgtPchp
         tbFnk0oZeewMEFSURZoVnXg+KO5/VYOKiEliey3Vo0nyqEbv7bhL9LNmC8lNZNqvI2kb
         iNqg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f3si198805edd.313.2019.01.28.09.05.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 09:05:28 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 95488AFCC;
	Mon, 28 Jan 2019 17:05:27 +0000 (UTC)
Date: Mon, 28 Jan 2019 18:05:26 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190128170526.GQ18811@dhcp22.suse.cz>
References: <20190125074824.GD3560@dhcp22.suse.cz>
 <20190125165152.GK50184@devbig004.ftw2.facebook.com>
 <20190125173713.GD20411@dhcp22.suse.cz>
 <20190125182808.GL50184@devbig004.ftw2.facebook.com>
 <20190128125151.GI18811@dhcp22.suse.cz>
 <20190128142816.GM50184@devbig004.ftw2.facebook.com>
 <20190128145210.GM18811@dhcp22.suse.cz>
 <20190128145407.GP50184@devbig004.ftw2.facebook.com>
 <20190128151859.GO18811@dhcp22.suse.cz>
 <20190128154150.GQ50184@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
In-Reply-To: <20190128154150.GQ50184@devbig004.ftw2.facebook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190128170526.r3ksiIR8KGLSH59t6jWktUizsWkyIvAqSq51cUtXxpE@z>

On Mon 28-01-19 07:41:50, Tejun Heo wrote:
> Hello, Michal.
> 
> On Mon, Jan 28, 2019 at 04:18:59PM +0100, Michal Hocko wrote:
> > How do you make an atomic snapshot of the hierarchy state? Or you do
> > not need it because event counters are monotonic and you are willing to
> > sacrifice some lost or misinterpreted events? For example, you receive
> > an oom event while the two children increase the oom event counter. How
> > do you tell which one was the source of the event and which one is still
> > pending? Or is the ordering unimportant in general?
> 
> Hmm... This is straightforward stateful notification.  Imagine the
> following hierarchy.  The numbers are the notification counters.
> 
>      A:0
>    /   \
>   B:0  C:0
> 
> Let's say B generates an event, soon followed by C.  If A's counter is
> read after both B and C's events, nothing is missed.
> 
> Let's say it ends up generating two notifications and we end up
> walking down inbetween B and C's events.  It would look like the
> following.
> 
>      A:1
>    /   \
>   B:1  C:0
> 
> We first see A's 0 -> 1 and then start scanning the subtrees to find
> out the origin.  We will notice B but let's say we visit C before C's
> event gets registered (otherwise, nothing is missed).

Yeah, that is quite clear. But it also assumes that the hierarchy is
pretty stable but cgroups might go away at any time. I am not saying
that the aggregated events are not useful I am just saying that it is
quite non-trivial to use and catch all potential corner cases. Maybe I
am overcomplicating it but one thing is quite clear to me. The existing
semantic is really useful to watch for the reclaim behavior at the
current level of the tree. You really do not have to care what is
happening in the subtree when it is clear that the workload itself
is underprovisioned etc. Considering that such a semantic already
existis, somebody might depend on it and we likely want also aggregated
semantic then I really do not see why to risk regressions rather than
add a new memory.hierarchy_events and have both.

-- 
Michal Hocko
SUSE Labs

