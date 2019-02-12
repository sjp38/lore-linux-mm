Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F74DC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 06:36:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35CA0217FA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 06:36:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35CA0217FA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9792F8E0014; Tue, 12 Feb 2019 01:36:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9289E8E0013; Tue, 12 Feb 2019 01:36:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 817C48E0014; Tue, 12 Feb 2019 01:36:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2C7488E0013
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 01:36:50 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id z10so1493031edz.15
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 22:36:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=2luFFSDHFsJbDwl821dl7kMAmz12dh1A0o8rlWHEfHs=;
        b=aW2q4qHpy0BKRKPIxTBAdPax0eLFD9M2x4fjeQIRQNYHECzcOb0gzRVPCieQPqlGb8
         nufun5riJ8Yls5h//m2EgOzCBNeZoL10myF2F0i+vYg1Vn1tXPc8ESOcVpwk873zJEFX
         xDxh4g+6DjSEaXrML7+1yEa6DZwrT8VK2lxB2ks6zRXaJfn0KyLK5Am5px4Gomtmo7JP
         /nVgOP6dK6x+vyrw+aJNRfxps8zwCJkNtd9N5bkw4QMAa/TFn1p5t80XIGoesyL/Eaa9
         sk8HcxgXzzzVWHcGdPes7ARmBfFRhsu2Vk5IsCCvp4TvJdRXT5ZUSvYUzOuYYw4nxAXf
         yvdw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZ4Ib4V6OQyFawFAqc/7acw/AnagjXbjneqfRvbgTTY+IgnVCJ6
	/behTVcHw3Z3bB2z2LrTsK4nR8BdQsUhDHRFn9edJBNPlb4KSDqxJbnikbS1JacVy9SffPIzcpH
	3gSfViBraeu0nOv+lIXmrCUrhO1HMRzXJ5OAEvMF6X/kca8cenqkBqMATlSTKYos=
X-Received: by 2002:a50:a246:: with SMTP id 64mr1732420edl.43.1549953409663;
        Mon, 11 Feb 2019 22:36:49 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYNeRfCKXfD2kY3wgvUxXlxH77qGmYt0v7LP9EEn6RLnyOGyWQRWdR1HpCNzToYmnzjRQi6
X-Received: by 2002:a50:a246:: with SMTP id 64mr1732369edl.43.1549953408671;
        Mon, 11 Feb 2019 22:36:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549953408; cv=none;
        d=google.com; s=arc-20160816;
        b=0br9xlh/zDdpNRY9cGnqU8FUKfSI7BkkpJ3uwfVM2xaK0ukY2VSe5nM01YOzMgiYvK
         pa+7+LxSwctbvroBI9iH7vONbRhNtj6K5Eyk76yUDntVEqIA/zZDW8wFq17t9T50m53R
         6GsEdAqG0/iyfcv7MgG+kLNNq2V44Omz0di6S4Ey8yvVE+ji6oSmdVGa2Ao+808aP2dc
         46T3AsQMqrReXhnMKbg3zXHPIyHcoDFFgnALbaHpH/SfQTWNVbPxtBXtJ7BAuejzUuen
         wxstK6h4ffzROmdLvVCXGmCh+EcnBF1RiSfr/03SQO+Aa+V2lIB743VBXRCnSNufVlBf
         v1Cg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=2luFFSDHFsJbDwl821dl7kMAmz12dh1A0o8rlWHEfHs=;
        b=VMOLyl+8cmbEYoLlGk3hWqEZr2DhIhTKOiqg121MB7S6QX6mgju00369/dtrKpmQ8F
         3NlygGVCBvFX3fp0Wj4H0GqWIz/d533FBF3aMSADYdsrRoPtQnt6ochkyT5/f3nxfqiU
         yOP2i26DOeFfd5AnO1KwV/jHn3riemb4zJ8WrQIZxs4OhwOE/c3T5NPOKaYlhmciRHc4
         4j6xefXyxTIGtA8LcpqCe3XSt6/0Cd613hgwYiXcPRV/1dUironLMIYTBXg1JIXm0NLF
         e8+ZGj41BrnW3xoezM+Mv8Z8nBE8o6FlPsRvsGP5lPykr1hhMS2ttcSosJrKcTXdvJlC
         d9WA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b2si5917838edy.279.2019.02.11.22.36.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 22:36:48 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5F9C3AC4C;
	Tue, 12 Feb 2019 06:36:47 +0000 (UTC)
Date: Tue, 12 Feb 2019 07:36:43 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-api@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
	Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Dave Chinner <david@fromorbit.com>,
	Kevin Easton <kevin@guarana.org>,
	Matthew Wilcox <willy@infradead.org>,
	Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Daniel Gruss <daniel@gruss.cc>, Josh Snyder <joshs@netflix.com>
Subject: Re: [PATCH 3/3] mm/mincore: provide mapped status when cached status
 is not allowed
Message-ID: <20190212063643.GL15609@dhcp22.suse.cz>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <20190130124420.1834-1-vbabka@suse.cz>
 <20190130124420.1834-4-vbabka@suse.cz>
 <20190131100907.GS18811@dhcp22.suse.cz>
 <99ee4d3e-aeb2-0104-22be-b028938e7f88@suse.cz>
 <nycvar.YFH.7.76.1902120440430.11598@cbobk.fhfr.pm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YFH.7.76.1902120440430.11598@cbobk.fhfr.pm>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 12-02-19 04:44:30, Jiri Kosina wrote:
> On Fri, 1 Feb 2019, Vlastimil Babka wrote:
> 
> > >> After "mm/mincore: make mincore() more conservative" we sometimes restrict the
> > >> information about page cache residency, which we have to do without breaking
> > >> existing userspace, if possible. We thus fake the resulting values as 1, which
> > >> should be safer than faking them as 0, as there might theoretically exist code
> > >> that would try to fault in the page(s) until mincore() returns 1.
> > >>
> > >> Faking 1 however means that such code would not fault in a page even if it was
> > >> not in page cache, with unwanted performance implications. We can improve the
> > >> situation by revisting the approach of 574823bfab82 ("Change mincore() to count
> > >> "mapped" pages rather than "cached" pages") but only applying it to cases where
> > >> page cache residency check is restricted. Thus mincore() will return 0 for an
> > >> unmapped page (which may or may not be resident in a pagecache), and 1 after
> > >> the process faults it in.
> > >>
> > >> One potential downside is that mincore() will be again able to recognize when a
> > >> previously mapped page was reclaimed. While that might be useful for some
> > >> attack scenarios, it's not as crucial as recognizing that somebody else faulted
> > >> the page in, and there are also other ways to recognize reclaimed pages anyway.
> > > 
> > > Is this really worth it? Do we know about any specific usecase that
> > > would benefit from this change? TBH I would rather wait for the report
> > > than add a hard to evaluate side channel.
> > 
> > Well it's not that complicated IMHO. Linus said it's worth trying, so
> > let's see how he likes the result. The side channel exists anyway as
> > long as process can e.g. check if its rss shrinked, and I doubt we are
> > going to remove that possibility.
> 
> So, where do we go from here?
> 
> Either Linus and Andrew like the mincore() return value tweak, or this 
> could be further discussed (*). But in either of the cases, I think 
> patches 1 and 2 should be at least queued for 5.1.

I would go with patch 1 for 5.1. Patches 2 still sounds controversial or
incomplete to me. And patch 3, well I will leave the decision to
Andrew/Linus.

> (*) I'd personally include it as well, as I don't see how it would break 
>     anything, it's pretty straightforward, and brings back some sanity to
>     mincore() return value.

-- 
Michal Hocko
SUSE Labs

