Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFF16C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 11:58:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F7BD20684
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 11:58:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F7BD20684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E4108E0003; Fri,  8 Mar 2019 06:58:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 196438E0002; Fri,  8 Mar 2019 06:58:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 085448E0003; Fri,  8 Mar 2019 06:58:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A49CC8E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 06:58:05 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id u25so9668879edd.15
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 03:58:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ff98EBAYYireNvqAi03UBURE2/pTc5yPGS5Q1xsxTmE=;
        b=Y6YlOg28etT0EZ2tR99iiMdmlWXMrtx69FtwsB0oFGHxaMhRvjAwDq7tUfDn80+faS
         x1EzvxJvqGjAFlwfwYQqxwnZf+M1ZSNriXGihq4mmQC5Op8sOQqzGKZnzwFUuYZNsNh8
         i5XnzK/9Eag2hkixH5JIMLiYiUa8PMRmJg7FMCmByAUmuPG4kgCEzbN9o83x1cnvrmt4
         ZHtaj2KrM0jL8WqOiXuZ4Zonz1rRuymMrDVbM6f1o5xbsY0PROSKXfFzsO7AHjKGH5Vv
         hty6w1WjlZzA/GxR905TUJaXW2L+yYDdF42Qes7ddbp8Zs7SxMUZgJnuUtKhz+EodDza
         6qRw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUQLJqVuhM2O7+j1DMQX1tQuDr8f6EspNcZxBWnPD0Xaqf4Kd6s
	JPVFp7zxSM2htQS4RrA2VGo9hvbmLo3DV4Mgahiz7fnAV28pRbp84cxCBuphZQHsf1WOa1IR634
	lsssQ8Lj8539wK6m/YZjG3QCsvLMG0yYRHGQvG0E+7Deu06loI8QRxOrew9r6dX4=
X-Received: by 2002:a50:b3bc:: with SMTP id s57mr31737170edd.206.1552046285168;
        Fri, 08 Mar 2019 03:58:05 -0800 (PST)
X-Google-Smtp-Source: APXvYqzmumr4tDaNrlLk5lJ4n1kftDmBd3CpyOqgk8QUKlr4jx8fzDPpOHbFVgYuAlAh04qATzy0
X-Received: by 2002:a50:b3bc:: with SMTP id s57mr31737118edd.206.1552046284328;
        Fri, 08 Mar 2019 03:58:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552046284; cv=none;
        d=google.com; s=arc-20160816;
        b=Cdezk1WXCEqVVCFhJD4hnDj9MBK/V3LhB8lj1zw8rEeJQ5oEgJ7Mqk6M5S/YHl7Syt
         9oC9/dUUIDmW+v4eBtFPFwonB2R5fpG/lba05yVklM0q7LuIFh46NMStL4s7Z1kPupZX
         mmkNpwR50FVC9H9Wq/pEGlzMp+S0Kc2mD6JSvffy0GeRKEtdXlP9Zf/bZq+EYT3gkliU
         8FIY9Nd0gWBkau30Bvs0Z/qqcDqYCLaLdUlS1ig/e0OcYHiPtIjrky9F/KUOr9C98geV
         I6rBtTIqPnq2JJDpWrS0F6q551r/ZYJyGJYg4iAoPX7jdZcTpIqRKgbwuXja630yGkzk
         eUTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ff98EBAYYireNvqAi03UBURE2/pTc5yPGS5Q1xsxTmE=;
        b=HoAN9rzBUUdHGMcQyqSiFBcvjQs27MvdNhO0RziEjwhL3f11No9g1R1hswyMf7aU/0
         eOoA79B20YTctWpxClNn/0D+JBEkslGWZiY97+oYON1z+D7bTYBGLSX7t11OtMBuxFmG
         PaoSLPQQhXiQzdipwbxDZ7KHi2ilL6w7V9lUdR+yq9CrtSIVfx6M+fDBNPvDe6SURoY/
         8MHR80OqWZk01wOWm2SyoNLQeSn/KrjNmNB8uAiHJwG7FvGeWuOs0pRricA5HoecHaI9
         OkSoNt2Ech3OGCCRxPiw2VIDCATtDyjjMWDQMJzsSZhwrwX/egmaRbAoIH22NQFqRXZz
         sO7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j8si1495174edh.122.2019.03.08.03.58.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 03:58:04 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7AFE3ADFB;
	Fri,  8 Mar 2019 11:58:03 +0000 (UTC)
Date: Fri, 8 Mar 2019 12:58:02 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm,oom: Teach lockdep about oom_lock.
Message-ID: <20190308115802.GJ5232@dhcp22.suse.cz>
References: <1552040522-9085-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190308110325.GF5232@dhcp22.suse.cz>
 <0ada8109-19a7-6d9c-8420-45f32811c6aa@i-love.sakura.ne.jp>
 <20190308115413.GI5232@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190308115413.GI5232@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 08-03-19 12:54:13, Michal Hocko wrote:
> [Cc Petr for the lockdep part - the patch is
> http://lkml.kernel.org/r/1552040522-9085-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp]

now for real.

> On Fri 08-03-19 20:29:46, Tetsuo Handa wrote:
> > On 2019/03/08 20:03, Michal Hocko wrote:
> > > On Fri 08-03-19 19:22:02, Tetsuo Handa wrote:
> > >> Since we are not allowed to depend on blocking memory allocations when
> > >> oom_lock is already held, teach lockdep to consider that blocking memory
> > >> allocations might wait for oom_lock at as early location as possible, and
> > >> teach lockdep to consider that oom_lock is held by mutex_lock() than by
> > >> mutex_trylock().
> > > 
> > > I do not understand this. It is quite likely that we will have multiple
> > > allocations hitting this path while somebody else might hold the oom
> > > lock.
> > 
> > The thread who succeeded to hold oom_lock must not involve blocking memory
> > allocations. It is explained in the comment before get_page_from_freelist().
> 
> Yes this is correct.
> 
> > > What kind of problem does this actually want to prevent? Could you be
> > > more specific please?
> > 
> > e.g.
> > 
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3688,6 +3688,7 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
> >          * attempt shall not depend on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
> >          * allocation which will never fail due to oom_lock already held.
> >          */
> > +       kfree(kmalloc(PAGE_SIZE, GFP_NOIO));
> >         page = get_page_from_freelist((gfp_mask | __GFP_HARDWALL) &
> >                                       ~__GFP_DIRECT_RECLAIM, order,
> >                                       ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);
> > 
> > 
> > Since https://lore.kernel.org/lkml/20190308013134.GB4063@jagdpanzerIV/T/#u made me
> > worry that we might by error introduce such dependency in near future, I propose
> > this change as a proactive protection.
> 
> OK, that makes sense to me. I cannot judge the implementation because I
> am not really familiar with lockdep machinery. Could you explain how it
> doesn't trigger for all other allocations?
> 
> Also why it is not sufficient to add the lockdep annotation prior to the
> trylock in __alloc_pages_may_oom?
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

