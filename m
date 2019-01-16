Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55EECC43387
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 21:41:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1346320840
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 21:41:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1346320840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A16B18E0004; Wed, 16 Jan 2019 16:41:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C7438E0002; Wed, 16 Jan 2019 16:41:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DDC88E0004; Wed, 16 Jan 2019 16:41:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 380628E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 16:41:21 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id l45so2913643edb.1
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 13:41:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=CsaUJUZ7py1YUxDpHwnWU+LssfzRbRe96qxcmMMTvD8=;
        b=dQrKKgz41i6PYMzsXSv3e/vz08oVbMVBaahMJKkRz+5AFS2OQbGQh+VON5y3rKHiKi
         xI4sW7xTFESFAcrDmg8lcJwINz+648Daq5bSIpzSeZqGCzhM9szYKOHbHPnXzSDzR4H1
         +vFQeiDfmIWNvH7FKqrs/eX7JsSUWAipsV0ZpWv8FQ88Z2ELyFfKyh7DCfrRvryF5ZDM
         I6E61NPinJP1oeJA1dVrK6DQAnVmPdsswTC9jTO2Dt89bSyS2JBe2e4kQyGLUVR1VGIP
         xj4tSFDsEoV7MfYS8mYw3/X6R32OKgnQvOR6tmozpIMqAR5vUQpIgu4dLwxP+hYRUcnE
         /SJQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukeUjtWFkrdRp1pMe4SyWa9Rj5qrp+JuiTrxvlDVNdlnSn3BSScb
	ZJyRbVIpjIRMuMNsailTFa+KZwzc0nmWwcu2YCx7d6vkWRygvj3wGduIJ3sMRE8dDejMvBitjEK
	EobULUueaa9eqXJ7tl6dAphy1cHi4QpcqD77YFn8/8dkcE+R1AQjQb2Cxy+bXvHA=
X-Received: by 2002:a17:906:3f87:: with SMTP id b7-v6mr4064005ejj.158.1547674880694;
        Wed, 16 Jan 2019 13:41:20 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5id/pTAbumbUJudVcg4Q5d45Gjk/0JxIeq+xMGDACdcS5mjXkxj9irNDDKRfhI0G3I/5PY
X-Received: by 2002:a17:906:3f87:: with SMTP id b7-v6mr4063969ejj.158.1547674879763;
        Wed, 16 Jan 2019 13:41:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547674879; cv=none;
        d=google.com; s=arc-20160816;
        b=znUqGPGOcuqJt2asA0zdUp3GJMFZxt9yYJgG+obWhGXv4OTW3uOiwMz0rOjwe6SFR5
         bgPhBarg1llT9k/f92SiDIA3Ad/O0to0R9uShu9ykM6kYWt2q2JhOsmJK9kVIJwHg4ac
         BNgn6I0nvSkue7ucrazD5b4kRYREhJglm4WexfRHNP+xPqNBdjIH8hXjS7EYZlvVBtdH
         +v8qRsfcjtmuuR705yMq1Ihcn69Eku+v2ia9Cl07jezRVlmrAmGFtpfjFE7XCg4o3rKG
         2CgN5degD4AmO9gM7RTYdVZell7Wro1uC+LoTjFW4y2nI1c3j+bQAm6VvFVZ99ZXy5O4
         VPCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=CsaUJUZ7py1YUxDpHwnWU+LssfzRbRe96qxcmMMTvD8=;
        b=SWbsIz1IPODJ9M7Sdn7qotsxOM431SAt/Jo/Iowo7FpldJB7IpjdQjWZZA0CI4+GYM
         HpDkbF+Po8snpEbu6yxLi8Lv0zJYkQhRDXdDPB5sWP+kPNw/A50eE7ddIijQerhy7vfb
         tBKqnej831nfBcq/xK0nOfHLG6OPtdtsBrSGrHHVi8JeQ8eqUQrUA5HQhk2qC+P1UTV2
         SJ0njH276S/jnsGg/10l5XxTBmiTjitzmZrpRDCcxKFexIB7OHKcyQFWh9AKpVX2ZY20
         OXSzm5WF7uGnqz+Wv+lX9IR4Sv6kLuPcy53Xv+XaYA6AROjt2kz3tBT0UGMoP0uH46eD
         33MA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i46si171569eda.288.2019.01.16.13.41.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 13:41:19 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay1.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BA921AD86;
	Wed, 16 Jan 2019 21:41:18 +0000 (UTC)
Date: Wed, 16 Jan 2019 22:41:16 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Matthew Wilcox <willy@infradead.org>
cc: Linus Torvalds <torvalds@linux-foundation.org>, 
    Dominique Martinet <asmadeus@codewreck.org>, 
    Andy Lutomirski <luto@amacapital.net>, Josh Snyder <joshs@netflix.com>, 
    Dave Chinner <david@fromorbit.com>, Jann Horn <jannh@google.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Greg KH <gregkh@linuxfoundation.org>, 
    Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, 
    Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, 
    Cyril Hrubis <chrubis@suse.cz>, Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
In-Reply-To: <20190116213708.GN6310@bombadil.infradead.org>
Message-ID: <nycvar.YFH.7.76.1901162238310.6626@cbobk.fhfr.pm>
References: <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com> <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com> <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com> <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net>
 <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com> <20190116054613.GA11670@nautica> <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com> <nycvar.YFH.7.76.1901161710470.6626@cbobk.fhfr.pm>
 <CAHk-=wgsnWvSsMfoEYzOq6fpahkHWxF3aSJBbVqywLa34OXnLg@mail.gmail.com> <nycvar.YFH.7.76.1901162120000.6626@cbobk.fhfr.pm> <20190116213708.GN6310@bombadil.infradead.org>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190116214116.r9tHCIS1Z48nZ_h3IEPLiLcRAjuKwMzhBnWYDlwK4H8@z>

On Wed, 16 Jan 2019, Matthew Wilcox wrote:

> > On Thu, 17 Jan 2019, Linus Torvalds wrote:
> > > As I suggested earlier in the thread, the fix for RWF_NOWAIT might be
> > > to just move the test down to after readahead.
> 
> Your patch 3/3 just removes the test.  Am I right in thinking that it
> doesn't need to be *moved* because the existing test after !PageUptodate
> catches it?

Exactly. It just initiates read-ahead for IOCB_NOWAIT cases as well, and 
if it's actually set, it'll be handled by the !PageUpdtodate case.

> Of course, there aren't any tests for RWF_NOWAIT in xfstests.  Are there 
> any in LTP?

Not in the released version AFAIK. I've asked the LTP maintainer (in our 
internal bugzilla) to take care of this thread a few days ago, but not 
sure what came out of it. Adding him (Cyril) to CC.

> Some typos in the commit messages:
> 
> > Another aproach (checking file access permissions in order to decide
> "approach"
> 
> > Subject: [PATCH 2/3] mm/mincore: make mincore() more conservative
> > 
> > The semantics of what mincore() considers to be resident is not completely
> > clearar, but Linux has always (since 2.3.52, which is when mincore() was
> "clear"
> 
> > initially done) treated it as "page is available in page cache".
> > 
> > That's potentially a problem, as that [in]directly exposes meta-information
> > about pagecache / memory mapping state even about memory not strictly belonging
> > to the process executing the syscall, opening possibilities for sidechannel
> > attacks.
> > 
> > Change the semantics of mincore() so that it only reveals pagecache information
> > for non-anonymous mappings that belog to files that the calling process could
> "belong"

Thanks.

-- 
Jiri Kosina
SUSE Labs

