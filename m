Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D68AC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 00:17:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDD202166E
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 00:17:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LGGsheo7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDD202166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33DEB6B0003; Wed, 19 Jun 2019 20:17:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EED08E0002; Wed, 19 Jun 2019 20:17:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B6F38E0001; Wed, 19 Jun 2019 20:17:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D104A6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 20:17:38 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id a5so479479pla.3
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 17:17:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=tLscf1pWbMquOzqm/J0PSG0c2NdqnQuLxzCnDb2eYKE=;
        b=PhNt/nbF0URyVF7hv9V42mA5+P7xmYSVodGsYHnwbH7rFFDTJGjVBThuKLGE3KtVQW
         ReV1lgBTHV2NSz/aI4w/HB/grhpgjK5jStS4z55TLVtSsJHyrF/y0udf6IYaYvf4nd5w
         xEGNF8NLub5DhB1ARpqFSo9JC3IKWUFBCk9N0yQDmwnu6GCx/wqCDapK0MP2mfrtChiS
         OEOKxAF0oC36EqC6qcLBvtVhg+KcmIfSxRVigiRflYqA+EA/9ticyZSWfLS+6F1k6LWR
         mQPgNLYsgWqa/FHrm+tkIlCGLVSDI7+DMJoLHnyRvfV5bcuvC5S5CwEO0VR7qqyOGsby
         ynnA==
X-Gm-Message-State: APjAAAURhr8l3jlHiAHx21EWJWk1JKw1ZDbIQe3CUfwBIEq4Akf7KIRD
	u+UezGfPl+v2a3crIEQgb3EcC3pqW3VwGilzVy9K3HXkB+izZ2RszTYQ4wqae2ldOWbsXvtkb+M
	nP5wJeK19wus566EZbar1+diSt4br1b8sC0wZB3fPIvOuZfUZjUOYkpXDjQeQMWs=
X-Received: by 2002:a17:902:f204:: with SMTP id gn4mr104393057plb.3.1560989222596;
        Wed, 19 Jun 2019 17:07:02 -0700 (PDT)
X-Received: by 2002:a17:902:f204:: with SMTP id gn4mr104393001plb.3.1560989221737;
        Wed, 19 Jun 2019 17:07:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560989221; cv=none;
        d=google.com; s=arc-20160816;
        b=GbXbUCiNKXpP7sGoFk9pI2j7j9sknTeEDszUFDFyzuORB0MUKnLclBs1meTrQbfcjL
         M0RUVPhHwfpf2Otrf7G0u+hFHq4dXCl/1Av8sLP3SbCnwxJg4aMPLfSGA+nqzQYLExxm
         G1WGkpncUIpKYJzbctMzSraH2vHXwUUfjHL1in7gkj0TOReUsaKgMxjoFPWSvZbZPqj+
         EaWYRRPQU8EdhWFv+nZ3e3v05wQMTWGj3kkiUFM5wOMZTFw27dvF9SVNCyMhSoFEYIBz
         ySFdf0P1chu8dBpFYYLW0icAmRfk1fsSP9287YSClV/UJZ9xunJV/0UjdMZOroe9Knki
         fT5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=tLscf1pWbMquOzqm/J0PSG0c2NdqnQuLxzCnDb2eYKE=;
        b=Z8lxSwl0EIpDCw3qiyzOfz6UCOsVvGKIZpOw8GEg28UCq3DsCHk/KEorXOw+xyPR+F
         asuCPMqEkuY4xgGnbDQHr5HxP2+dax1YNLgAC63sHQqc7IpbaGPHUpYZsl9V/N7mhIu2
         Od7mmcwuZwZSUy4m2rcrzJfTnIA7PzL4Ch63FKNcgOanyy5oFWiPafe8G7s+KbdSbBkg
         wy1hP8O4R5d2Co78QzUQlrMTeUIG/ylHYBnD0uvxbBbYyBh68VPuSIzO1e3KoWWw6uZ6
         AvTwE5CBHrvfcHjKH6TBhjmHtApeEvfUu/KqHXrjR9f1JSx9rNwiBGuy5T5EJOo3xoL2
         7DUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LGGsheo7;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g9sor4156949pjs.21.2019.06.19.17.07.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 17:07:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LGGsheo7;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=tLscf1pWbMquOzqm/J0PSG0c2NdqnQuLxzCnDb2eYKE=;
        b=LGGsheo7k/szhAcyit449LNmwFUNGBlCPBve+8d9w8NQmjKy8LZb3bEIyYp8zTx7GY
         y8bNrlvbOQsTKus6jOOFD8m0repNnpEsS1QMi9eCzx4ynWPJfXfvfHMGzGBK/zfWpnoE
         kkLp3/8Hb0HdwgWFrOj+eirfIt1ExGnWwjZBR8/lBHse87ltyZmSxs2letpM3wIWst/Y
         r3HRxg2CmuJCobJ2IXjwaS5HDKyYjnXktaiJ7hmFqAbRLDNj4/Um1EOV+/47d0H6KVoN
         jDWHMmc5uhQJhd2L6E1JCwJIgDFBWCKBwWEP3K2KI+7N3xQi12TaGiZOgnX346Z80Nvk
         lDkw==
X-Google-Smtp-Source: APXvYqz3yRevnnWG6vliI4MqUARyAvpZ1qqe+X6lRv1JTMqjQ+2wW1mbJbQSVZQhA+DtqpVDpXqeOw==
X-Received: by 2002:a17:90b:d82:: with SMTP id bg2mr14244364pjb.87.1560989221216;
        Wed, 19 Jun 2019 17:07:01 -0700 (PDT)
Received: from google.com ([122.38.223.241])
        by smtp.gmail.com with ESMTPSA id r4sm2574657pjd.28.2019.06.19.17.06.53
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 19 Jun 2019 17:06:59 -0700 (PDT)
Date: Thu, 20 Jun 2019 09:06:51 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com, lizeb@google.com
Subject: Re: [PATCH v2 1/5] mm: introduce MADV_COLD
Message-ID: <20190620000650.GB52978@google.com>
References: <20190610111252.239156-1-minchan@kernel.org>
 <20190610111252.239156-2-minchan@kernel.org>
 <20190619125611.GO2968@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190619125611.GO2968@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 02:56:12PM +0200, Michal Hocko wrote:
> On Mon 10-06-19 20:12:48, Minchan Kim wrote:
> > When a process expects no accesses to a certain memory range, it could
> > give a hint to kernel that the pages can be reclaimed when memory pressure
> > happens but data should be preserved for future use.  This could reduce
> > workingset eviction so it ends up increasing performance.
> > 
> > This patch introduces the new MADV_COLD hint to madvise(2) syscall.
> > MADV_COLD can be used by a process to mark a memory range as not expected
> > to be used in the near future. The hint can help kernel in deciding which
> > pages to evict early during memory pressure.
> > 
> > It works for every LRU pages like MADV_[DONTNEED|FREE]. IOW, It moves
> > 
> > 	active file page -> inactive file LRU
> > 	active anon page -> inacdtive anon LRU
> > 
> > Unlike MADV_FREE, it doesn't move active anonymous pages to inactive
> > file LRU's head because MADV_COLD is a little bit different symantic.
> > MADV_FREE means it's okay to discard when the memory pressure because
> > the content of the page is *garbage* so freeing such pages is almost zero
> > overhead since we don't need to swap out and access afterward causes just
> > minor fault. Thus, it would make sense to put those freeable pages in
> > inactive file LRU to compete other used-once pages. It makes sense for
> > implmentaion point of view, too because it's not swapbacked memory any
> > longer until it would be re-dirtied. Even, it could give a bonus to make
> > them be reclaimed on swapless system. However, MADV_COLD doesn't mean
> > garbage so reclaiming them requires swap-out/in in the end so it's bigger
> > cost. Since we have designed VM LRU aging based on cost-model, anonymous
> > cold pages would be better to position inactive anon's LRU list, not file
> > LRU. Furthermore, it would help to avoid unnecessary scanning if system
> > doesn't have a swap device. Let's start simpler way without adding
> > complexity at this moment.
> 
> I would only add that it is a caveat that workloads with a lot of page
> cache are likely to ignore MADV_COLD on anonymous memory because we
> rarely age anonymous LRU lists.

Okay, I will add some more.

> 
> [...]
> > +static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
> > +				unsigned long end, struct mm_walk *walk)
> > +{
> 
> This is duplicating a large part of madvise_free_pte_range with some
> subtle differences which are not explained anywhere (e.g. why does
> madvise_free_huge_pmd need try_lock on a page while not here? etc.).

madvise_free_huge_pmd handle dirty bit but this is not.

> 
> Why cannot we reuse a large part of that code and differ essentially on
> the reclaim target check and action? Have you considered to consolidate
> the code to share as much as possible? Maybe that is easier said than
> done because the devil is always in details...

Yub, it was not pretty when I tried. Please see last patch in this
patchset.

