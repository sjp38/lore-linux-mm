Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 800FBC282CE
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 23:02:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF93826B44
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 23:02:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EgfyT96f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF93826B44
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 691736B0274; Mon,  3 Jun 2019 19:02:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 641EA6B0276; Mon,  3 Jun 2019 19:02:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50AD46B0277; Mon,  3 Jun 2019 19:02:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 14BD56B0274
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 19:02:15 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id m12so12688860pls.10
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 16:02:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=yGWgisOzgWfpAsWuWpBW9wv4B2VfU1HINjYPzcFySSo=;
        b=YXWRFA4JyF2x5Qiaqyhru3PA4UFhwbdZkpDrX2hxdAEwoyiR/ugwxXD2GQeWHohTp9
         JIzSYwqIPEi77Z1+GN8+iMv4YEgP3NjCp5BBMg9LlIpXx8pFi8hrl20+iB6Dh96tP28B
         QQw6it8FItRcqiDzzvzeqqWv4Q0UsoV31KyLMls3Rn9oyGrC/YQ0A1V9cVovFxZfvtir
         G0KFKMa3Ks4+Yss8oB5ZCklpLSk36jJuZsZ//kkC6UE2piDMh4OL6rTO7dJUFlNKJ17u
         SVlHdk7ptzdehJYNzV+tu6+goz2tYq8obSvLHJOKk/GKTph5dKxP5wtO8ZtHv/zN7Xjb
         WWnA==
X-Gm-Message-State: APjAAAWtoQfg0z08vB1neDb6Nqh5lywrOQsl1yxcUqiy+XBNLI5I+wYW
	HdUpPraE0XaeJdiFUHd4DeZjRh0zgYJw0yaXBHLlNzN6jrL8Waym5mu+VVglw5mrgKxLMtN1TOE
	qBGdar8RGx8ZNm2WedaesTD/nwt/EDlV2lr62aBAsDWyvH+UZUT/YXaI70ZbDmcs=
X-Received: by 2002:a17:902:24d:: with SMTP id 71mr33833857plc.166.1559602934627;
        Mon, 03 Jun 2019 16:02:14 -0700 (PDT)
X-Received: by 2002:a17:902:24d:: with SMTP id 71mr33833795plc.166.1559602933684;
        Mon, 03 Jun 2019 16:02:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559602933; cv=none;
        d=google.com; s=arc-20160816;
        b=tAm/BW871T2I3gxU3Xg3tMI94PX6EE+U53BmlPtgkokZB37NrP+WuHaSRMgvGy3pA6
         wz8jJWaOrdwOydenkRYmANEBrEq4jmylnXvSOciztW6IfCVslt4BNruEgNQM/63LVryd
         9ekqALYF4fBKkEYgkVCDvq1xP30d/jRjjZawRlMBJfDvBDs6DQuIZ6zXA/crSoBzTwnM
         0gn80H5wEYFk24c9fXU5mt77e1KI3YZuBq0+mhwr4leFfJCi1t23sbRmRgegAucrjdZI
         qZaOltNZ/aQXKaxT5xlrmsouppWlFJeML+2ddEP1A1euEIj74qEYwYwSlwC3nDb4WHWY
         lqvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=yGWgisOzgWfpAsWuWpBW9wv4B2VfU1HINjYPzcFySSo=;
        b=bIiF8pMhBK7nyjtLLO3YJJs8bgvq0zNdSaUcWWLInvjvRtCvZ9h+mV52/agZsOUTBS
         Gm2av1Mtgk73MfzKFauSwYGTOmAANW+8OzgIbbw4zC7aB5kTa2qLujnS5ovsEsuSW+Zb
         eeHLbSisBMK9CdKbBZaPd4gxYNCFnxpTEWc5E5TkutE45JZ9TEdbYxDr3uoVxkYCBA1T
         X5sa0hDVBydDdsUvojko39y74dst6MAqCzrKpVjJY4CTkm5oV/BKasTa9gIafa+l3aeH
         2GdxruG6qm9krxr5iUWT4O66rT6ZDzsOc2001fma8AwKSoikvNKz/JuqUhlt/bQVs6NA
         eteQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EgfyT96f;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id ay3sor18491825plb.20.2019.06.03.16.02.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 16:02:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EgfyT96f;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=yGWgisOzgWfpAsWuWpBW9wv4B2VfU1HINjYPzcFySSo=;
        b=EgfyT96fk6vvQY5SFnesmZ6DIVFRx6yrNM5JKL31Zn5a0Pf0fQvmbHoY6+R3MGiEyp
         ocfeJcp7zAGOLX1qUteCkyVf9QkbVMfr5nY6fretb37D7LwJdW+FGtS7acGvamYPx7sn
         rwrRij92Ohr62F+vVRuJciAP5KP4eMBXEcKrPWawZlnldrd++mIsnoqXjQlbeUKK11xg
         RHM/QfwH4vYaI3wgmQpkWB/YxQMYFxRHjqj0Lv0XlR4Y56YQK3+Xwc0cvyksjCbAF2Dn
         RNbCrW/QSU5ONniWnxCAQx41j0YMGSeRi2PE4w/ELrpddUdmOZgzNAuyvXwUnbXB+BsX
         mMhQ==
X-Google-Smtp-Source: APXvYqxCkkmPXZHimkozMNVYP9gcbva1AMdrrcMfJLPuejBMXVOEhl4/p8tBtCCcCov7W2EolbjhXA==
X-Received: by 2002:a17:902:2983:: with SMTP id h3mr33061358plb.267.1559602933011;
        Mon, 03 Jun 2019 16:02:13 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id d19sm13502849pjs.22.2019.06.03.16.02.07
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 03 Jun 2019 16:02:11 -0700 (PDT)
Date: Tue, 4 Jun 2019 08:02:05 +0900
From: Minchan Kim <minchan@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com
Subject: Re: [RFCv2 1/6] mm: introduce MADV_COLD
Message-ID: <20190603230205.GA43390@google.com>
References: <20190531064313.193437-1-minchan@kernel.org>
 <20190531064313.193437-2-minchan@kernel.org>
 <20190531084752.GI6896@dhcp22.suse.cz>
 <20190531133904.GC195463@google.com>
 <20190531140332.GT6896@dhcp22.suse.cz>
 <20190531143407.GB216592@google.com>
 <20190603071607.GB4531@dhcp22.suse.cz>
 <20190603172717.GA30363@cmpxchg.org>
 <20190603203230.GB22799@dhcp22.suse.cz>
 <20190603215059.GA16824@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190603215059.GA16824@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Johannes,

On Mon, Jun 03, 2019 at 05:50:59PM -0400, Johannes Weiner wrote:
> On Mon, Jun 03, 2019 at 10:32:30PM +0200, Michal Hocko wrote:
> > On Mon 03-06-19 13:27:17, Johannes Weiner wrote:
> > > On Mon, Jun 03, 2019 at 09:16:07AM +0200, Michal Hocko wrote:
> > > > On Fri 31-05-19 23:34:07, Minchan Kim wrote:
> > > > > On Fri, May 31, 2019 at 04:03:32PM +0200, Michal Hocko wrote:
> > > > > > On Fri 31-05-19 22:39:04, Minchan Kim wrote:
> > > > > > > On Fri, May 31, 2019 at 10:47:52AM +0200, Michal Hocko wrote:
> > > > > > > > On Fri 31-05-19 15:43:08, Minchan Kim wrote:
> > > > > > > > > When a process expects no accesses to a certain memory range, it could
> > > > > > > > > give a hint to kernel that the pages can be reclaimed when memory pressure
> > > > > > > > > happens but data should be preserved for future use.  This could reduce
> > > > > > > > > workingset eviction so it ends up increasing performance.
> > > > > > > > > 
> > > > > > > > > This patch introduces the new MADV_COLD hint to madvise(2) syscall.
> > > > > > > > > MADV_COLD can be used by a process to mark a memory range as not expected
> > > > > > > > > to be used in the near future. The hint can help kernel in deciding which
> > > > > > > > > pages to evict early during memory pressure.
> > > > > > > > > 
> > > > > > > > > Internally, it works via deactivating pages from active list to inactive's
> > > > > > > > > head if the page is private because inactive list could be full of
> > > > > > > > > used-once pages which are first candidate for the reclaiming and that's a
> > > > > > > > > reason why MADV_FREE move pages to head of inactive LRU list. Therefore,
> > > > > > > > > if the memory pressure happens, they will be reclaimed earlier than other
> > > > > > > > > active pages unless there is no access until the time.
> > > > > > > > 
> > > > > > > > [I am intentionally not looking at the implementation because below
> > > > > > > > points should be clear from the changelog - sorry about nagging ;)]
> > > > > > > > 
> > > > > > > > What kind of pages can be deactivated? Anonymous/File backed.
> > > > > > > > Private/shared? If shared, are there any restrictions?
> > > > > > > 
> > > > > > > Both file and private pages could be deactived from each active LRU
> > > > > > > to each inactive LRU if the page has one map_count. In other words,
> > > > > > > 
> > > > > > >     if (page_mapcount(page) <= 1)
> > > > > > >         deactivate_page(page);
> > > > > > 
> > > > > > Why do we restrict to pages that are single mapped?
> > > > > 
> > > > > Because page table in one of process shared the page would have access bit
> > > > > so finally we couldn't reclaim the page. The more process it is shared,
> > > > > the more fail to reclaim.
> > > > 
> > > > So what? In other words why should it be restricted solely based on the
> > > > map count. I can see a reason to restrict based on the access
> > > > permissions because we do not want to simplify all sorts of side channel
> > > > attacks but memory reclaim is capable of reclaiming shared pages and so
> > > > far I haven't heard any sound argument why madvise should skip those.
> > > > Again if there are any reasons, then document them in the changelog.
> > > 
> > > I think it makes sense. It could be explained, but it also follows
> > > established madvise semantics, and I'm not sure it's necessarily
> > > Minchan's job to re-iterate those.
> > > 
> > > Sharing isn't exactly transparent to userspace. The kernel does COW,
> > > ksm etc. When you madvise, you can really only speak for your own
> > > reference to that memory - "*I* am not using this."
> > > 
> > > This is in line with other madvise calls: MADV_DONTNEED clears the
> > > local page table entries and drops the corresponding references, so
> > > shared pages won't get freed. MADV_FREE clears the pte dirty bit and
> > > also has explicit mapcount checks before clearing PG_dirty, so again
> > > shared pages don't get freed.
> > 
> > Right, being consistent with other madvise syscalls is certainly a way
> > to go. And I am not pushing one way or another, I just want this to be
> > documented with a reasoning behind. Consistency is certainly an argument
> > to use.
> > 
> > On the other hand these non-destructive madvise operations are quite
> > different and the shared policy might differ as a result as well. We are
> > aging objects rather than destroying them after all. Being able to age
> > a pagecache with a sufficient privileges sounds like a useful usecase to
> > me. In other words you are able to cause the same effect indirectly
> > without the madvise operation so it kinda makes sense to allow it in a
> > more sophisticated way.
> 
> Right, I don't think it's about permission - as you say, you can do
> this indirectly. Page reclaim is all about relative page order, so if
> we thwarted you from demoting some pages, you could instead promote
> other pages to cause a similar end result.
> 
> I think it's about intent. You're advising the kernel that *you're*
> not using this memory and would like to have it cleared out based on
> that knowledge. You could do the same by simply allocating the new
> pages and have the kernel sort it out. However, if the kernel sorts it
> out, it *will* look at other users of the page, and it might decide
> that other pages are actually colder when considering all users.
> 
> When you ignore shared state, on the other hand, the pages you advise
> out could refault right after. And then, not only did you not free up
> the memory, but you also caused IO that may interfere with bringing in
> the new data for which you tried to create room in the first place.
> 
> So I don't think it ever makes sense to override it.
> 
> But it might be better to drop the explicit mapcount check and instead
> make the local pte young and call shrink_page_list() without the
                     ^
                     old?

> TTU_IGNORE_ACCESS, ignore_references flags - leave it to reclaim code
> to handle references and shared pages exactly the same way it would if
> those pages came fresh off the LRU tail, excluding only the reference
> from the mapping that we're madvising.

You are confused from the name change. Here, MADV_COLD is deactivating
, not pageing out. Therefore, shrink_page_list doesn't matter.
And madvise_cold_pte_range already makes the local pte *old*(I guess
your saying was typo).
I guess that's exactly what Michal wanted: just removing page_mapcount
check and defers to decision on normal page reclaim policy:
If I didn't miss your intention, it seems you and Michal are on same page.
(Please correct me if you want to say something other)
I could drop the page_mapcount check at next revision.

Thanks for the review!

