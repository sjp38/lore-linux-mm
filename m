Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA242C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 19:23:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87BB3218C3
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 19:23:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="ccNxnvT2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87BB3218C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 21C228E0012; Wed, 30 Jan 2019 14:23:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C9FF8E0001; Wed, 30 Jan 2019 14:23:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 094388E0012; Wed, 30 Jan 2019 14:23:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id D3A8B8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 14:23:48 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id u17so313915ybk.20
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 11:23:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=6+s3m/wCiQicI56EM9O8sUfe7ZO8/YgchrGdD+iAv9I=;
        b=Ftste3RhxcVW7xN26d8J+7Z17tqFQwLD4CjBMssPQ5G8LibiDCH8XA+ATf/Ny6dnzV
         14URKcJEe6hbNesslVXvYn8wJ5voQPEk9+74mkcsZ+MAypeJVxkAoP/bIZEUg3FpiUu3
         lN0KFPWnbjg1DVfIQE1LZ4SgxvFNHr3mIBatMtTi78WcYgvMeC1jWTo1mu5DF7qfS/B1
         00yc5w2fc/GfHFZ/wpKrgdiGJ4ZLC7qZw5aEzVbRWEzMWEFRsJoCk2pDhDQVuxLaVK1g
         LpzdD8tV04fFKNPbHSMaQKqsbWOWYKHzrH33nxnYgoxuF6/VGLjQBuUG54phzF62sBG2
         AJLQ==
X-Gm-Message-State: AJcUukfxVEWOgwAxb4YochOhZj5TMw5PFSITyqOzq2yT0zei9sOkfpNZ
	JGg5/RRdKpR1jvtUdKIhjseI98ZA86G4DAPJFDILWzf93qAc3wyXak7qfXyYkCk9MJsRKrNepSH
	/VLCSg726GNufw2rCCn+Tnqzu8wNMUqWW3rhea4L/S9wGKJA2rBjwTgNynfxuWqlMF26VvsOzyt
	O7kmOpwiKVMK4Kvp9cyGmT3K402YGTcrTkUee+Clmgox5CJOLRlPB5SATPjUNjXYlsLpeGY1Qhb
	E59L4H7+iTrnHX67pGf92Q2zjjJwA20HFEJwJH3MNoIRL0q9zRdrKU3td0fkyF+54y1UmJvHCfM
	Vg5lCPxJARE3ZjzW00GDH5nXekwp4GrTTdnvnG7XLtz/LGztcOqmuHJvfKPhknKTR37JNtl+fqh
	J
X-Received: by 2002:a25:da8f:: with SMTP id n137mr29590579ybf.522.1548876228534;
        Wed, 30 Jan 2019 11:23:48 -0800 (PST)
X-Received: by 2002:a25:da8f:: with SMTP id n137mr29590552ybf.522.1548876227958;
        Wed, 30 Jan 2019 11:23:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548876227; cv=none;
        d=google.com; s=arc-20160816;
        b=XuNx16o4LKv+yGK+uRtirjqhBgRQSvs0aVeMxVYHeupANXTeGYam5PzOot43YKtJYF
         RrufPcBrUV1eZzPFtheGIa5TM67Ayijqiq2mDj6SA991vVv61tuHovaFDTgvFa4gpxe7
         8PySp0kOso5O7fUiKv3rxgSK13bNGxsuthcYxUHJJDwrkiLh3ebNUY4NaCOT12ryuElR
         49aljKJJdpWUqs3mSsAvNzS3LFSBmBV8Cdjay+J0Mg1NFYZGq/BX9C1RfxiDqDyyuyfK
         ICxwTw62mizGfVvJirWbBzoPJ/hM2bBbifUArsXsasfSrfPM3RIdqlUHcGgIPtYRvQmh
         6XXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=6+s3m/wCiQicI56EM9O8sUfe7ZO8/YgchrGdD+iAv9I=;
        b=H4iR7S/7RThrGGxE7OLM4AqKVy0KlVLZTPH9DUpbN8vCfHQ/00gPRmNz/4m4QWq9lT
         fnIU50op6Wulwtl6jhBpTwjX0kKGyFx2cBQ3kp6VnUFq0fZtZJFpxdLksjFJ5dGeWL7a
         xzuPvcffeLma4SDjWKxOc6rf87NKQuHRacdKom+bHZJ1XtXBlxiSHrtnNDhT9MEqLGqq
         DynTRV63yTFU5UcCHlVfFx7VVZm0eiorpAAKL3RT7A+ey0Cy7nusp8Qk9kRsec++CeJk
         oX6C6FYeeTt0GvKl5fEC/lkb++LdCLOikZ/aA5aaDP06fhV2NQ0lnEVn8160JMQ9JT/e
         3KGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=ccNxnvT2;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e127sor1094905yba.179.2019.01.30.11.23.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 11:23:47 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=ccNxnvT2;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=6+s3m/wCiQicI56EM9O8sUfe7ZO8/YgchrGdD+iAv9I=;
        b=ccNxnvT224O+7fChZ7Efge3FO8zKw7BrWhwJ7vtYCw2pMhdgeAnuGSy0ooAgXBO//i
         RZodYsnJPpMtZAmiD6BTOM2ZmYll6e8Tx/HpFylbwTK5qpdK3HKp6c8tm3vGNFD5i3eG
         8JiePIfFf14/NPKu2oWsFcTO4Wmr0VywSvdt7lcrunvnDALgrasx6zXTVrEFmG2x+muA
         aIOTrYjcVAI1Zqden7mXBJepzBhvBMPxAagdov+uqKm15pG4iFf8eEdJtEwm3GOlHOKT
         pgPErx42/P7qtYmr8UalnjLRF0Ek8ydI72C2ok/il/IB0bsnSgpJg/sO8ZnlzCxjp1kE
         11Ow==
X-Google-Smtp-Source: ALg8bN6f8V7xxI/17rpnmUspeB/aPgmPl/5RN0lt8KISw0wDBoHhd0PgtkFxbAPEvOFgOboGaYeTeg==
X-Received: by 2002:a25:3b82:: with SMTP id i124mr30282584yba.183.1548876227334;
        Wed, 30 Jan 2019 11:23:47 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::5:6c95])
        by smtp.gmail.com with ESMTPSA id a15sm937081ywh.64.2019.01.30.11.23.46
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Jan 2019 11:23:46 -0800 (PST)
Date: Wed, 30 Jan 2019 14:23:45 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Chris Down <chris@chrisdown.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190130192345.GA20957@cmpxchg.org>
References: <20190123223144.GA10798@chrisdown.name>
 <20190124082252.GD4087@dhcp22.suse.cz>
 <20190124160009.GA12436@cmpxchg.org>
 <20190124170117.GS4087@dhcp22.suse.cz>
 <20190124182328.GA10820@cmpxchg.org>
 <20190125074824.GD3560@dhcp22.suse.cz>
 <20190125165152.GK50184@devbig004.ftw2.facebook.com>
 <20190125173713.GD20411@dhcp22.suse.cz>
 <20190125182808.GL50184@devbig004.ftw2.facebook.com>
 <20190128125151.GI18811@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190128125151.GI18811@dhcp22.suse.cz>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2019 at 01:51:51PM +0100, Michal Hocko wrote:
> On Fri 25-01-19 10:28:08, Tejun Heo wrote:
> > On Fri, Jan 25, 2019 at 06:37:13PM +0100, Michal Hocko wrote:
> > > Please note that I understand that this might be confusing with the rest
> > > of the cgroup APIs but considering that this is the first time somebody
> > > is actually complaining and the interface is "production ready" for more
> > > than three years I am not really sure the situation is all that bad.
> > 
> > cgroup2 uptake hasn't progressed that fast.  None of the major distros
> > or container frameworks are currently shipping with it although many
> > are evaluating switching.  I don't think I'm too mistaken in that we
> > (FB) are at the bleeding edge in terms of adopting cgroup2 and its
> > various new features and are hitting these corner cases and oversights
> > in the process.  If there are noticeable breakages arising from this
> > change, we sure can backpaddle but I think the better course of action
> > is fixing them up while we can.
> 
> I do not really think you can go back. You cannot simply change semantic
> back and forth because you just break new users.
> 
> Really, I do not see the semantic changing after more than 3 years of
> production ready interface. If you really believe we need a hierarchical
> notification mechanism for the reclaim activity then add a new one.

This discussion needs to be more nuanced.

We change interfaces and user-visible behavior all the time when we
think nobody is likely to rely on it. Sometimes we change them after
decades of established behavior - for example the recent OOM killer
change to not kill children over parents.

The argument was made that it's very unlikely that we break any
existing user setups relying specifically on this behavior we are
trying to fix. I don't see a real dispute to this, other than a
repetition of "we can't change it after three years".

I also don't see a concrete description of a plausible scenario that
this change might break.

I would like to see a solid case for why this change is a notable risk
to actual users (interface age is not a criterium for other changes)
before discussing errata solutions.

