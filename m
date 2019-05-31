Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C70F7C28CC3
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 14:34:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8243326ABE
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 14:34:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lCqxT1nQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8243326ABE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B8306B026F; Fri, 31 May 2019 10:34:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 042646B0278; Fri, 31 May 2019 10:34:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E25666B027A; Fri, 31 May 2019 10:34:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id AA5BA6B026F
	for <linux-mm@kvack.org>; Fri, 31 May 2019 10:34:18 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id c4so4813496pgm.21
        for <linux-mm@kvack.org>; Fri, 31 May 2019 07:34:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=fnQfpcEhfSu6CHorowQTdVmGhlubjd1jGBr2l9heqP4=;
        b=GB9jkoYeVG75zdhv+CqzAx/BIVCkU1MVRhZ+2aiF9Eb5FocNITkPN0+HCgZYX7Nv38
         /5Paorf+S+W0ufb7XGPKdDeFahPg8d+lKiN/u4/9u/bg7pA8eRDjexKBU5EV7r4/xzmP
         5PNhXQNZwgXfIdvb0Xb6r3dAdmUmLWEcXr39huyjhD80qXjwSCfKojZRZp4Ln5vPeYS0
         csV8timiXmR1mqtAzBTW5kw7xa47Pzd6l/6AAcijasfjJX9VHGbR971fpj18ttz7UUCD
         imw2o5dmt7sBnXMb+mr2n/ChXI2sHgUmIpFq+0Kke6LDsNa5JEudHNPJTYtih+moneUz
         EDxw==
X-Gm-Message-State: APjAAAXSs0SZ4i+UzHN78U8K5tIof7gtBq2/F3Az9Q2D1eAUb0+9/2+v
	/tvNRxOpXq1VyrqN3fz+FOGxxNntFefftGNRAg7zIIogMIOPHuLmbTLfHlMdfqg6iki70nPz7QK
	qt8OQYneqSME9rG6A5nVA/s/lNwKKoY3V9inh0Tki4jvYLX26e+kPVpywTQB+QSY=
X-Received: by 2002:a17:90a:dd42:: with SMTP id u2mr9801954pjv.118.1559313258297;
        Fri, 31 May 2019 07:34:18 -0700 (PDT)
X-Received: by 2002:a17:90a:dd42:: with SMTP id u2mr9801851pjv.118.1559313257297;
        Fri, 31 May 2019 07:34:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559313257; cv=none;
        d=google.com; s=arc-20160816;
        b=NhQ7zLRTEVBfw1lXScc+bOWDKF/IAODekjVauHtH8pabpTD18rlKqHhmP+6jzNndra
         eOMqv2CjpqU/wW0qpzG1eqEFu8ouevlRMOr2qftgboKZ61cK44N3Y+HSWK1B9m6TA0NJ
         DdR5X6E/ODogiyN/uyGOGZmMYNcuwm2GoHn3e2aaudCAH4VjzfRPdTCrr8h9yLdgqDq7
         AySZq/yNs/jFPXC/Uc6f1Wpn94J/s72CAsqeTklNdyc1UQ7MK5Yq86pYppB42+xA9y/T
         lnDZ7CE3nHvozuYTV3hNbJfHmgLFYPWE1srV308Rzh0fs3PtxaT/5ioCXV1IBQknNRT4
         a9Zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=fnQfpcEhfSu6CHorowQTdVmGhlubjd1jGBr2l9heqP4=;
        b=mhUwyZlIO/a+Ptrc0tMdp1tsQo3v1y/sKvMJ1i3bfn5EJDorFBTmOYjUy90svW48sj
         jyzVAPHlKFKdJkWr7dMS9V7e374XEK4RW09BOfxNmQ6XX3QlgyWsv/63fbR6e01+VeDS
         U5oxloLeGQCGCrs/V4rJDwDJd83JIXAGkuDzvikmZvICc9o95uUIcsnS0Bc7Usqnmi6n
         lgrPmmQv9SBupVfU/+lU+nZrhHTn95n/lrD+F1YokmjLks5SCrJ79GjRxOvnIBQLymEj
         yQJWLCWdRY62bhXIq0BNGNQ9tTk6bmr3ECsIeSmzJ8PoDRgDXhm2xdwTkLBXX2Jg26dZ
         4JDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lCqxT1nQ;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v22sor4963228pfm.18.2019.05.31.07.34.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 07:34:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lCqxT1nQ;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=fnQfpcEhfSu6CHorowQTdVmGhlubjd1jGBr2l9heqP4=;
        b=lCqxT1nQv45YhWQ9KXKemph5c4rCv/ebDZpjkcx6xxcIlgEtfDMFylJdCSQkmFke7b
         uvwf7RFjH+S3DgvKn4eGTafMQDGTc5Qh+gUejQNKWPTnYSfqpbgwGh4kv56H50rgU5m0
         qx1lieKFngqRumYZ7hYMC8t/r7sSLpgDaLNtXc/av3+VD+nUauAlrnx2prk5/hgWZVcB
         P82RT453NjDQ2l11e1R0z8XJdFNJcRyemYzclTjSBXx7KsiUaXbYkEMDHvNdqBs5nmHS
         J3J7GUy3KSA0IQLZ6eEE93RrkIEIuGNWOUb6TzrHlWmVUgqfnePWEFpPinRwUB6qPMoY
         DwHw==
X-Google-Smtp-Source: APXvYqwGdiXZSvss9JzvQ5dpbsxeEWxevql+5o1ejuQAC7HEJARkX5+94Biv/e2q0kxkXzSgk+J1Og==
X-Received: by 2002:aa7:8296:: with SMTP id s22mr10426129pfm.52.1559313256809;
        Fri, 31 May 2019 07:34:16 -0700 (PDT)
Received: from google.com ([122.38.223.241])
        by smtp.gmail.com with ESMTPSA id c6sm10458746pfm.163.2019.05.31.07.34.10
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 31 May 2019 07:34:15 -0700 (PDT)
Date: Fri, 31 May 2019 23:34:07 +0900
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
	hdanton@sina.com
Subject: Re: [RFCv2 1/6] mm: introduce MADV_COLD
Message-ID: <20190531143407.GB216592@google.com>
References: <20190531064313.193437-1-minchan@kernel.org>
 <20190531064313.193437-2-minchan@kernel.org>
 <20190531084752.GI6896@dhcp22.suse.cz>
 <20190531133904.GC195463@google.com>
 <20190531140332.GT6896@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190531140332.GT6896@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 31, 2019 at 04:03:32PM +0200, Michal Hocko wrote:
> On Fri 31-05-19 22:39:04, Minchan Kim wrote:
> > On Fri, May 31, 2019 at 10:47:52AM +0200, Michal Hocko wrote:
> > > On Fri 31-05-19 15:43:08, Minchan Kim wrote:
> > > > When a process expects no accesses to a certain memory range, it could
> > > > give a hint to kernel that the pages can be reclaimed when memory pressure
> > > > happens but data should be preserved for future use.  This could reduce
> > > > workingset eviction so it ends up increasing performance.
> > > > 
> > > > This patch introduces the new MADV_COLD hint to madvise(2) syscall.
> > > > MADV_COLD can be used by a process to mark a memory range as not expected
> > > > to be used in the near future. The hint can help kernel in deciding which
> > > > pages to evict early during memory pressure.
> > > > 
> > > > Internally, it works via deactivating pages from active list to inactive's
> > > > head if the page is private because inactive list could be full of
> > > > used-once pages which are first candidate for the reclaiming and that's a
> > > > reason why MADV_FREE move pages to head of inactive LRU list. Therefore,
> > > > if the memory pressure happens, they will be reclaimed earlier than other
> > > > active pages unless there is no access until the time.
> > > 
> > > [I am intentionally not looking at the implementation because below
> > > points should be clear from the changelog - sorry about nagging ;)]
> > > 
> > > What kind of pages can be deactivated? Anonymous/File backed.
> > > Private/shared? If shared, are there any restrictions?
> > 
> > Both file and private pages could be deactived from each active LRU
> > to each inactive LRU if the page has one map_count. In other words,
> > 
> >     if (page_mapcount(page) <= 1)
> >         deactivate_page(page);
> 
> Why do we restrict to pages that are single mapped?

Because page table in one of process shared the page would have access bit
so finally we couldn't reclaim the page. The more process it is shared,
the more fail to reclaim.

> 
> > > Are there any restrictions on mappings? E.g. what would be an effect of
> > > this operation on hugetlbfs mapping?
> > 
> > VM_LOCKED|VM_HUGETLB|VM_PFNMAP vma will be skipped like MADV_FREE|DONTNEED
> 
> OK documenting that this is restricted to the same vmas as MADV_FREE|DONTNEED
> is really useful to mention.

Sure.

> 
> > 
> > > 
> > > Also you are talking about inactive LRU but what kind of LRU is that? Is
> > > it the anonymous LRU? If yes, don't we have the same problem as with the
> > 
> > active file page -> inactive file LRU
> > active anon page -> inacdtive anon LRU
> > 
> > > early MADV_FREE implementation when enough page cache causes that
> > > deactivated anonymous memory doesn't get reclaimed anytime soon. Or
> > > worse never when there is no swap available?
> > 
> > I think MADV_COLD is a little bit different symantic with MAVD_FREE.
> > MADV_FREE means it's okay to discard when the memory pressure because
> > the content of the page is *garbage*. Furthemore, freeing such pages is
> > almost zero overhead since we don't need to swap out and access
> > afterward causes minor fault. Thus, it would make sense to put those
> > freeable pages in inactive file LRU to compete other used-once pages.
> > 
> > However, MADV_COLD doesn't means it's a garbage and freeing requires
> > swap out/swap in afterward. So, it would be better to move inactive
> > anon's LRU list, not file LRU. Furthermore, it would avoid unnecessary
> > scanning of those cold anonymous if system doesn't have a swap device.
> 
> Please document this, if this is really a desirable semantic because
> then you have the same set of problems as we've had with the early
> MADV_FREE implementation mentioned above.

IIRC, the problem of MADV_FREE was that we couldn't discard freeable
pages because VM never scan anonymous LRU with swapless system.
However, it's not the our case because we should reclaim them, not
discarding.

I will include it in the description.

Thanks.

