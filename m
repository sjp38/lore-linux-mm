Return-Path: <SRS0=IlG+=PR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43FF9C43612
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 02:31:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07A1A217F9
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 02:31:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07A1A217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9BDAC8E009F; Tue,  8 Jan 2019 21:31:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 943DC8E0038; Tue,  8 Jan 2019 21:31:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 80AD38E009F; Tue,  8 Jan 2019 21:31:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 229F48E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 21:31:38 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e29so2363427ede.19
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 18:31:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=TZE1yZrtEyR+lBk0N8kxSweADarJQTGJbRD12vzgFwE=;
        b=mwnrxlkmUyRvCWLFFZWjtQdw0H06HuPvuQcmwk9OQlzCcfXuio5u2DNmYaWYHxt+X7
         VZIQEhtyovVYE+d4xXOjEL3GBsqQyfRcO5FFE5UIBxufj/f9E0k4opsXesoOi32vCZf+
         IB7vzn4tbedG8JmJlBz8XbWR9i9OuMztqocf1gsvtQTl4OyE/1edRqmI1tA51xQ9tonz
         iSyOvfR3IzSXOIk4r6xIjSamE+f1gHW0FYi5kZDWMg3ME5Jed/fo8clr9EQNle6UxHBB
         ORI/x7edJsPmrcpUPGKQRgMVkMSBfMgbOewYqXT9ogy99hr3QIMoR1nbqA+gX5xRGK4S
         fmWg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukf3uKrnTXW0Db8g1a9yxFzsTho25WPnFYdD9SapMf3GL1JioZlM
	UxZq992vGXL8ooLOcXrj3ufExJ/aAzhAHfwiiQ2jUP3AVWXkwi5HzzzHeYoQANEIskGiM5Spj0N
	q8M0TPwLZAqJQevaWn0V/TNX/aS2yE6tJMbyGKqxv9UttY9s6Nveo0SpxSKJqQrU=
X-Received: by 2002:a50:bdc8:: with SMTP id z8mr4183137edh.46.1547001097673;
        Tue, 08 Jan 2019 18:31:37 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6gFVpiUhUAdp05cDDqdeOzwdDx1o82CL8dCMLAXh8qp170j70G1SF4m+Zu5JLrRP4SBwfY
X-Received: by 2002:a50:bdc8:: with SMTP id z8mr4183109edh.46.1547001096820;
        Tue, 08 Jan 2019 18:31:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547001096; cv=none;
        d=google.com; s=arc-20160816;
        b=fnkt1K5SNRRbKQImQtWogpZOcIuS1VWAmcFw7xNLgwz5BWzL4SRFeuEkBsbSXhuFiz
         IunIuApnm1WjrlwftujtQNW69hB/W5DHRDAq9M1fBNHBFPJYuFmRb+/8t1nD7XkeAh07
         71IbPncHchenc2oW81jCekbUirE74YJ+C1xVaRmtneqvwD1UF2JqZMa8Kj8v5ilvEg3S
         +yJItbAEIsk4r9qmqYLMZpqdGZmQk/0lZt0DDtI0CQ+3vlRuXQezhwMnUB7twZjTm7JV
         PX9giWr3I20Z0bLdYGWMJPvps3XScHn908TbChLzphZYOgmddNKLTzNcmpmcy01KhOCW
         m5ng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=TZE1yZrtEyR+lBk0N8kxSweADarJQTGJbRD12vzgFwE=;
        b=nPH5HT3HOaH42iC2+W0aqeNvHsMd4Q4BQumw/8FoZS2doCFxIYLrKNVsg4lS1AlAFc
         yrHj1I64SJhL3/hRSLaYGQyWE/Q3G6MeX/gl1t896oMOWQspjfHORGAdvC1Ycqk+lZtz
         moSgL8bhSfI7B47kf17yuq8U7a31QeUuFWMdph/mz2dxx6I5OEij3WbAXc+GDyv4Vbp6
         /nR+QeiRRh6Ksn0eRDqKeMApgA4fjDEOX1OrWsqmEuBuitJ2ahgINm0SyZ8iZsRWMF89
         ZuK6GwRpxaU/923V+Vy2EqCjbCizQHPztEADce6BI0tvPor+Dcir43A5jXMt5QVmx+Am
         27Pw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g25si300508edr.258.2019.01.08.18.31.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 18:31:36 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay1.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3C8A2AEAD;
	Wed,  9 Jan 2019 02:31:36 +0000 (UTC)
Date: Wed, 9 Jan 2019 03:31:35 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Dave Chinner <david@fromorbit.com>
cc: Linus Torvalds <torvalds@linux-foundation.org>, 
    Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Greg KH <gregkh@linuxfoundation.org>, 
    Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, 
    Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, 
    Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
In-Reply-To: <20190109022430.GE27534@dastard>
Message-ID: <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
References: <CAG48ez2jAp9xkPXQmVXm0PqNrFGscg9BufQRem2UD8FGX-YzPw@mail.gmail.com> <CAHk-=whL4sZiM=JcdQAYQvHm7h7xEtVUh+gYGYhoSk4vi38tXg@mail.gmail.com> <CAHk-=wg5Kk+r36=jcGBaLUj+gjopjgiW5eyvkdMqvn0jFkD_iQ@mail.gmail.com> <CAHk-=wiMQeCEKESWTmm15x79NjEjNwFvjZ=9XenxY7yH8zqa7A@mail.gmail.com>
 <20190106001138.GW6310@bombadil.infradead.org> <CAHk-=wiT=ov+6zYcnw_64ihYf74Amzqs67iVGtJMQq65PxiVYw@mail.gmail.com> <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com> <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com>
 <20190108044336.GB27534@dastard> <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com> <20190109022430.GE27534@dastard>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190109023135.EOYH649q25pC7VBrG5DU_L8qgRjlPzAka0aeSm8mCZ0@z>

On Wed, 9 Jan 2019, Dave Chinner wrote:

> > But mincore is certainly the easiest interface, and the one that
> > doesn't require much effort or setup.
> 
> Off the top of my head, here's a few vectors for reading the page
> cache residency state without perturbing the page cache residency
> pattern:
> 	- mincore
> 	- preadv2(RWF_NOWAIT)
> 	- fadvise(POSIX_FADV_RANDOM); timed read(2) syscalls
> 	- madvise(MADV_RANDOM); timed read of first byte in each page

While I obviously agree that all those are creating pagecache sidechannel 
in principle, I think we really should mostly focus on the first two (with 
mincore() already having been covered).

Rationale has been provided by Daniel Gruss in this thread -- if the 
attacker is left with cache timing as the only available vector, he's 
going to be much more successful with mounting hardware cache timing 
attack anyway.

Thanks,

-- 
Jiri Kosina
SUSE Labs

