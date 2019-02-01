Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5695C282DA
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 16:34:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 557DA207E0
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 16:34:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="r6Qj7QJJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 557DA207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E4C9C8E0002; Fri,  1 Feb 2019 11:34:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD6008E0001; Fri,  1 Feb 2019 11:34:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C76E48E0002; Fri,  1 Feb 2019 11:34:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 979718E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 11:34:37 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id a199so7530553qkb.23
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 08:34:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=T1cUxsK+PmWr/6FQQmkTEVDMRHPhfnqUxG9J3UF7DW4=;
        b=Ij/KqFGFWi8Rvr2HnJ1UWBwe7Ph16tlZNWyE/biymykmb24+uzvt4c/ASmZsYf1R3a
         D8Q8LspgIYwipqTCdtzQDgl4sj/L4JwLrrsaqGOXJv1wXm/wqltgkr2nqvtw3Mz5/TM5
         NSIT34YBb0DVmGYL0yn89oOBpnw1QNjAhIoKtZxk6kQ3tbAsikZ+jGPYIN25NVujX8eG
         83yJi48f3uWbM6wTNbLFGJSse5rBUUw32GTanmmDqzEgDeuDxg76U416NiLUqZKw0DLH
         9v6C6J/LZuhTizaqLnwPLc7vU7S0ykjAOFZCeJ+epymm4L+wayXUrWko4KMewB4+H6mV
         TGQQ==
X-Gm-Message-State: AJcUukfkNIbROVsJSW1V+cKfDqjHkrHwJUjOYuwSWysPHDjh+MqWXJTQ
	inp/4/tjZIRXI5EchpcpFvoGj/QdRgmizuw+cP5EhzgkzdrNmFLomQw73eDH6D+UDK5QsyzOiBN
	IbUltreha7pvj6JsekAJMZz8+BObJBeUtLPbmWLfkyAhlu8tALgxRwE5hH8Iyig3CR5wjgSmAu7
	07BWgokXSaIIup3Fih7QjbrTAirHmT6TjT1cBA4dpAWiB6J4nDfXXrYM2e91jGL2HR52Rg6OgES
	WgYeImNVgxY/Out+24GInobiaqWkKrbj7PLIl+sD9Jy8z9Zy7a2UMimdHobDrOPYdJTlN2U6Xgw
	i7vERpZD/RLQ96pBMEYMrHxaonOIiiCmJq5yBlQRq/9R5P5qK9c23wq2Cy7iZFLk4qzIrp3NKBU
	p
X-Received: by 2002:ac8:3a64:: with SMTP id w91mr39443209qte.70.1549038877159;
        Fri, 01 Feb 2019 08:34:37 -0800 (PST)
X-Received: by 2002:ac8:3a64:: with SMTP id w91mr39443156qte.70.1549038876130;
        Fri, 01 Feb 2019 08:34:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549038876; cv=none;
        d=google.com; s=arc-20160816;
        b=oJpT3CDmh8Qj6JqSSXdD4FWR+R7WXERuJq9AZ+zfgs5Yy1a7YY33lxn7mn6pFz9+Zw
         t0yk7HDalxt+60jgbGj2j/ZgY5xi2DaIp+06Kfnr8xH75Y+3BKkIsPAAYKy4NGus5vAR
         KdO3S66wuZLAW86KkGNrRGi8SoW/e2ku4JO7AmcAsQm5l67GydMGQ5lP0KA+bB18DH5N
         aeWs/0zyR16SkUntwvMaxNt/ERuRTAzB1kkIK5g7NMYtl5tCwYGs/9bb5rZ+8C0rU7Oi
         A3t6TSpDu7ILWF2+78DTEQdRLTnEnF7jQzTCefFjuqBds9B2jRqitsqTFMYyyVhfJMen
         d1qw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=T1cUxsK+PmWr/6FQQmkTEVDMRHPhfnqUxG9J3UF7DW4=;
        b=HeiIyz2cy/1yrowTSiZRpEC2h5A9FG2y/VeE+5DTw04w9iLdp3HvfHId05YeC7S5Fl
         Dxvgwt7kgobz7wPkT92+77rwae/g9FR9TdC8y1DeH6jzbT2brj49PAqhu4GnPnv6rkOS
         Jx5vDu63dEUWQvfFdW201+WvzyqiyeX07pGEdde/TsTAxqwPSTagZTNb7AWfgS+yaLpG
         MNBSnUtEPkffAf3iyukQbXo02d7d0DIBQog8Ft1OYvR/CRhSQQT3l+xo5Fri/Gtb6/Jh
         NsOz//q4imELu/MdODJs6+48rWPnKwXmy2AgLyU9hboEU/KNIx7V2uAV9iCbSv5dMPrs
         5xFw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=r6Qj7QJJ;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p16sor10675766qtn.60.2019.02.01.08.34.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Feb 2019 08:34:31 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=r6Qj7QJJ;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=T1cUxsK+PmWr/6FQQmkTEVDMRHPhfnqUxG9J3UF7DW4=;
        b=r6Qj7QJJ3YyM9MRfJeTcHEOpOwP//vRf13ph5+KtFAc1l13fvgDu0hbOPZ6PIVF9A3
         LqYpm5oUt+FzoBxrzLtz+kmTEiZUeehPQMGSpemDZYjX74B/dnoThhEaj85GacE6TxFE
         2qq4h5/Jy1an/3SNORZa/Clen213kUuxivjt1+LoclBTqsa1Me5GDJ1UsSHKaB/9tppQ
         EJWX2mGbJa70+jC46iqN4In9EFN9xZ/WLLO8F+LqxIb+Qi6NEwPZ5fw3meUedGZ74cZ6
         cxKp1PsF5WeV9eJ5GGOFvZQzE34cOCSNsXATrSqwTDPeQzopyA8sACj8nzaZW+TDyBgn
         Z80Q==
X-Google-Smtp-Source: ALg8bN7TVlrz/CHixswU4O1qCf9VXbx24FAV89YCOCwDT8AaYQq71zBEpbeCKlerX6J8jIVwx7woKg==
X-Received: by 2002:ac8:2fdc:: with SMTP id m28mr40808988qta.202.1549038871422;
        Fri, 01 Feb 2019 08:34:31 -0800 (PST)
Received: from localhost (pool-108-27-252-85.nycmny.fios.verizon.net. [108.27.252.85])
        by smtp.gmail.com with ESMTPSA id q2sm4777742qkc.68.2019.02.01.08.34.30
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Feb 2019 08:34:30 -0800 (PST)
Date: Fri, 1 Feb 2019 11:34:29 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Chris Down <chris@chrisdown.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190201163429.GB11231@cmpxchg.org>
References: <20190125165152.GK50184@devbig004.ftw2.facebook.com>
 <20190125173713.GD20411@dhcp22.suse.cz>
 <20190125182808.GL50184@devbig004.ftw2.facebook.com>
 <20190128125151.GI18811@dhcp22.suse.cz>
 <20190130192345.GA20957@cmpxchg.org>
 <20190130200559.GI18811@dhcp22.suse.cz>
 <20190130213131.GA13142@cmpxchg.org>
 <20190131085808.GO18811@dhcp22.suse.cz>
 <20190131162248.GA17354@cmpxchg.org>
 <20190201102515.GK11599@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190201102515.GK11599@dhcp22.suse.cz>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 01, 2019 at 11:27:41AM +0100, Michal Hocko wrote:
> On Thu 31-01-19 11:22:48, Johannes Weiner wrote:
> > On Thu, Jan 31, 2019 at 09:58:08AM +0100, Michal Hocko wrote:
> > > On Wed 30-01-19 16:31:31, Johannes Weiner wrote:
> > > > On Wed, Jan 30, 2019 at 09:05:59PM +0100, Michal Hocko wrote:
> > > [...]
> > > > > I thought I have already mentioned an example. Say you have an observer
> > > > > on the top of a delegated cgroup hierarchy and you setup limits (e.g. hard
> > > > > limit) on the root of it. If you get an OOM event then you know that the
> > > > > whole hierarchy might be underprovisioned and perform some rebalancing.
> > > > > Now you really do not care that somewhere down the delegated tree there
> > > > > was an oom. Such a spurious event would just confuse the monitoring and
> > > > > lead to wrong decisions.
> > > > 
> > > > You can construct a usecase like this, as per above with OOM, but it's
> > > > incredibly unlikely for something like this to exist. There is plenty
> > > > of evidence on adoption rate that supports this: we know where the big
> > > > names in containerization are; we see the things we run into that have
> > > > not been reported yet etc.
> > > > 
> > > > Compare this to real problems this has already caused for
> > > > us. Multi-level control and monitoring is a fundamental concept of the
> > > > cgroup design, so naturally our infrastructure doesn't monitor and log
> > > > at the individual job level (too much data, and also kind of pointless
> > > > when the jobs are identical) but at aggregate parental levels.
> > > > 
> > > > Because of this wart, we have missed problematic configurations when
> > > > the low, high, max events were not propagated as expected (we log oom
> > > > separately, so we still noticed those). Even once we knew about it, we
> > > > had trouble tracking these configurations down for the same reason -
> > > > the data isn't logged, and won't be logged, at this level.
> > > 
> > > Yes, I do understand that you might be interested in the hierarchical
> > > accounting.
> > > 
> > > > Adding a separate, hierarchical file would solve this one particular
> > > > problem for us, but it wouldn't fix this pitfall for all future users
> > > > of cgroup2 (which by all available evidence is still most of them) and
> > > > would be a wart on the interface that we'd carry forever.
> > > 
> > > I understand even this reasoning but if I have to chose between a risk
> > > of user breakage that would require to reimplement the monitoring or an
> > > API incosistency I vote for the first option. It is unfortunate but this
> > > is the way we deal with APIs and compatibility.
> > 
> > I don't know why you keep repeating this, it's simply not how Linux
> > API is maintained in practice.
> > 
> > In cgroup2, we fixed io.stat to not conflate discard IO and write IO:
> > 636620b66d5d4012c4a9c86206013964d3986c4f
> > 
> > Linus changed the Vmalloc field semantics in /proc/meminfo after over
> > a decade, without a knob to restore it in production:
> > 
> >     If this breaks anything, we'll obviously have to re-introduce the code
> >     to compute this all and add the caching patches on top.  But if given
> >     the option, I'd really prefer to just remove this bad idea entirely
> >     rather than add even more code to work around our historical mistake
> >     that likely nobody really cares about.
> >     a5ad88ce8c7fae7ddc72ee49a11a75aa837788e0
> > 
> > Mel changed the zone_reclaim_mode default behavior after over a
> > decade:
> > 
> >     Those that require zone_reclaim_mode are likely to be able to
> >     detect when it needs to be enabled and tune appropriately so lets
> >     have a sensible default for the bulk of users.
> >     4f9b16a64753d0bb607454347036dc997fd03b82
> >     Acked-by: Michal Hocko <mhocko@suse.cz>
> > 
> > And then Mel changed the default zonelist ordering to pick saner
> > behavior for most users, followed by a complete removal of the zone
> > list ordering, after again, decades of existence of these things:
> > 
> >     commit c9bff3eebc09be23fbc868f5e6731666d23cbea3
> >     Author: Michal Hocko <mhocko@suse.com>
> >     Date:   Wed Sep 6 16:20:13 2017 -0700
> > 
> >         mm, page_alloc: rip out ZONELIST_ORDER_ZONE
> > 
> > And why did we do any of those things and risk user disruption every
> > single time? Because the existing behavior was not a good default, a
> > burden on people, and the risk of breakage was sufficiently low.
> > 
> > I don't see how this case is different, and you haven't provided any
> > arguments that would explain that.
> 
> Because there is no simple way to revert in _this_ particular case. Once
> you change the semantic of the file you cannot simply make it
> non-hierarchical after somebody complains. You do not want to break both
> worlds. See the difference?

Yes and no. We cannot revert if both cases are in use, but we can
support both cases; add the .local file, or - for binary compatibility
- add the compat mount flag to switch to the old behavior.

In the vmalloc and the zonelist_order_zone cases above, any users that
would rely on those features would have to blacklist certain kernel
versions in which they are not available.

In this case, any users that rely on the old behavior would have to
mount cgroup2 with the compat knob.

Arguably, it's easier to pass a mount option than it is to change the
entire kernel.

> > > Those users requiring the hierarchical beahvior can use the new file
> > > without any risk of breakages so I really do not see why we should
> > > undertake the risk and do it the other way around.
> > 
> > Okay, so let's find a way forward here.
> > 
> > 1. A new memory.events_tree file or similar. This would give us a way
> > to get the desired hierarchical behavior. The downside is that it's
> > suggesting that ${x} and ${x}_tree are the local and hierarchical
> > versions of a cgroup file, and that's false everywhere else. Saying we
> > would document it is a cop-out and doesn't actually make the interface
> > less confusing (most people don't look at errata documentation until
> > they've been burned by unexpected behavior).
> > 
> > 2. A runtime switch (cgroup mount option, sysctl, what have you) that
> > lets you switch between the local and the tree behavior. This would be
> > able to provide the desired semantics in a clean interface, while
> > still having the ability to support legacy users.
> 
> With an obvious downside that one or the other usecase has to learn that
> the current semantic is different than expected which is again something
> that has to be documented so we are in the same "people don't look at
> errata documentation...".

Of course, but that's where the "which situation is more likely" comes
in. That was the basis for all the historic changes I quoted above.

> > 2a. A runtime switch that defaults to the local behavior.
> > 
> > 2b. A runtime switch that defaults to the tree behavior.
> > 
> > The choice between 2a and 2b comes down to how big we evaluate the
> > risk that somebody has an existing dependency on the local behavior.
> > 
> > Given what we know about cgroup2 usage, and considering our previous
> > behavior in such matters, I'd say 2b is reasonable and in line with
> > how we tend to handle these things. On the tiny chance that somebody
> > is using the current behavior, they can flick the switch (until we add
> > the .local files, or simply use the switch forever).
> 
> My preference is 1 but if there is a _larger_ consensus of different
> cgroup v2  users that 2 is more preferred then I can live with that.

Thanks.

