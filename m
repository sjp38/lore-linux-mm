Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9986C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 03:44:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D56F21855
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 03:44:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="vKc7uY29"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D56F21855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 280988E0125; Mon, 11 Feb 2019 22:44:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2090A8E0111; Mon, 11 Feb 2019 22:44:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D0D08E0125; Mon, 11 Feb 2019 22:44:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id BAF808E0111
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 22:44:37 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id ay11so1061815plb.20
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 19:44:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=ez/yVB/ScYQizrOD6qMzEd6HliNl/fzYIsPTwB36C9w=;
        b=qELkiFeJOvKoo32x1sxolsOJ64a6iAS1G1ZAt7n+PZ1HB/n1/uZKm/WdFgKNMOkAGQ
         I+7MAT8qLA+Zzygs2zfrNJV59ag1GJZBRvOUUDnd+vnB1i5Vh4HlsoA93vQc3LNDb2fc
         NPU0CNaYbfNknfGtb+6tt2Mbf6j/m8wRlZCzQoAiwsKLNxdm3wv9S8dAHbyu9v6yqdUU
         /E9210oCD5U7b1gwD9WQRmsOHtq2YqxkzjvO1f7wKDMvF0Ek9OqPNs+o7PwdNxVWN8dD
         DkOBvQcadYRGg10iTBnUlAzIX7zntjXRMGrsrjyGen0PANC4jWEykcmbqNT1R95TgqZB
         rmBw==
X-Gm-Message-State: AHQUAub5Jaw7NNknP/ZMlqIGp5oKEOBnL0FQE6nVYGW/Dc5tVX+CHNB7
	Qa5KQBlNaeMDzca8dwyf16ES+6pNxd/su1ZR8d5MRFy2ZkO3xIuCr3gsUt0+5yBu8Ui66Hw9J9/
	Jjh6jvsRSSOR6DVw2VBilledDQhtjan16Sjkr+JEtLz3cESVvagiSvn4O1N3LnCyuDA==
X-Received: by 2002:a65:60c5:: with SMTP id r5mr1682360pgv.427.1549943077324;
        Mon, 11 Feb 2019 19:44:37 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYFieYxaIL+kI8rYXn2XIM0eWlJxXqzz9IG3PFX7YOsqNxGixOciHz9KdBAPPLD0qv1hDKd
X-Received: by 2002:a65:60c5:: with SMTP id r5mr1682324pgv.427.1549943076465;
        Mon, 11 Feb 2019 19:44:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549943076; cv=none;
        d=google.com; s=arc-20160816;
        b=TsO4upXfroTOHXcMusHe5TXCBdnMH4wBkRCYMbJQ05z6a1T/gHoxQNOk6OHeJS60Vl
         vy61WB+z/4oN+luNhTwg6hfj3cZKIizcgXGItTwvyGX1jJ2N4w6b0AImA6ZNSuBOCHzG
         nnztwrYvM4/ai5BTEBQTU6txzIUBocZdPTrwsi6uuU7DZuOB8Af3olaUXNK/NGns+emc
         e+lcWsS/rdwQheaah+9WDMzWhUdrKoSbVfv5ashVp4nWQGXm369+MXI+gp5KPkJJfwpF
         ZWlMZctW23U2y5aNGBjQ7jvt6qMuX5/PXn9GNdCRCs9FMxURioKzElHP9SnEZRon1wxQ
         4YXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=ez/yVB/ScYQizrOD6qMzEd6HliNl/fzYIsPTwB36C9w=;
        b=LMuqlHbqQC9JTUkYVnXmrUUPajkU0/pXYtVJdTzr+dWU5UBX5mSDd1YK1kUHc33yPB
         HqpgYfGXM9wlX6UvmCIHHIRbJsoxqpfT8+HS5swOQQWjbwIFDSiA8HReynCFkQ9D9dGL
         gPxksDQKLwZ+suKc1wGboIEn/hXWNxRilmx8tf1Jg3Pcybbv+8tamRCxlKF/GbvBCIxk
         Dy4eYucgsbzNqBoJh7vbYMF5mesdsJiNJqrzM7U7b6D06GcucliOWWTI9koJ8xpbdPI0
         4hOzBosyyc2jzKlcSSl29nDirluf/DEHJyIHwFr4DBu7GMEwSo6zP+1W/rHvAtjGGdYB
         q12g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=vKc7uY29;
       spf=pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n32si11245900pgm.439.2019.02.11.19.44.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 19:44:36 -0800 (PST)
Received-SPF: pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=vKc7uY29;
       spf=pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from pobox.suse.cz (prg-ext-pat.suse.com [213.151.95.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7A24F21773;
	Tue, 12 Feb 2019 03:44:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1549943076;
	bh=V+4sz6GuJCGGE8jPyQE9VqmVQ6GL9QhF5Xh07eR5KFE=;
	h=Date:From:To:cc:Subject:In-Reply-To:References:From;
	b=vKc7uY29NkDNfw5V+B7Gqas26TB+Nf3GWR62SCx9T6h+fBSNhkhryeK7eBVOE1K7K
	 5S11y+gpvdt8EZQhYHehrr+tYctkCpe7sumRXbltQ9/N9eFnwn3VBe5qcEayPhFi9l
	 YssmPPJzSynButtCx2xLmRImkE6xMgI3xgHPbTQk=
Date: Tue, 12 Feb 2019 04:44:30 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Vlastimil Babka <vbabka@suse.cz>
cc: Michal Hocko <mhocko@kernel.org>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Linus Torvalds <torvalds@linux-foundation.org>, 
    linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
    linux-api@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, 
    Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>, 
    Dominique Martinet <asmadeus@codewreck.org>, 
    Andy Lutomirski <luto@amacapital.net>, Dave Chinner <david@fromorbit.com>, 
    Kevin Easton <kevin@guarana.org>, Matthew Wilcox <willy@infradead.org>, 
    Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>, 
    "Kirill A . Shutemov" <kirill@shutemov.name>, 
    Daniel Gruss <daniel@gruss.cc>, Josh Snyder <joshs@netflix.com>
Subject: Re: [PATCH 3/3] mm/mincore: provide mapped status when cached status
 is not allowed
In-Reply-To: <99ee4d3e-aeb2-0104-22be-b028938e7f88@suse.cz>
Message-ID: <nycvar.YFH.7.76.1902120440430.11598@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm> <20190130124420.1834-1-vbabka@suse.cz> <20190130124420.1834-4-vbabka@suse.cz> <20190131100907.GS18811@dhcp22.suse.cz> <99ee4d3e-aeb2-0104-22be-b028938e7f88@suse.cz>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 1 Feb 2019, Vlastimil Babka wrote:

> >> After "mm/mincore: make mincore() more conservative" we sometimes restrict the
> >> information about page cache residency, which we have to do without breaking
> >> existing userspace, if possible. We thus fake the resulting values as 1, which
> >> should be safer than faking them as 0, as there might theoretically exist code
> >> that would try to fault in the page(s) until mincore() returns 1.
> >>
> >> Faking 1 however means that such code would not fault in a page even if it was
> >> not in page cache, with unwanted performance implications. We can improve the
> >> situation by revisting the approach of 574823bfab82 ("Change mincore() to count
> >> "mapped" pages rather than "cached" pages") but only applying it to cases where
> >> page cache residency check is restricted. Thus mincore() will return 0 for an
> >> unmapped page (which may or may not be resident in a pagecache), and 1 after
> >> the process faults it in.
> >>
> >> One potential downside is that mincore() will be again able to recognize when a
> >> previously mapped page was reclaimed. While that might be useful for some
> >> attack scenarios, it's not as crucial as recognizing that somebody else faulted
> >> the page in, and there are also other ways to recognize reclaimed pages anyway.
> > 
> > Is this really worth it? Do we know about any specific usecase that
> > would benefit from this change? TBH I would rather wait for the report
> > than add a hard to evaluate side channel.
> 
> Well it's not that complicated IMHO. Linus said it's worth trying, so
> let's see how he likes the result. The side channel exists anyway as
> long as process can e.g. check if its rss shrinked, and I doubt we are
> going to remove that possibility.

So, where do we go from here?

Either Linus and Andrew like the mincore() return value tweak, or this 
could be further discussed (*). But in either of the cases, I think 
patches 1 and 2 should be at least queued for 5.1.

(*) I'd personally include it as well, as I don't see how it would break 
    anything, it's pretty straightforward, and brings back some sanity to
    mincore() return value.

Thanks,

-- 
Jiri Kosina
SUSE Labs

