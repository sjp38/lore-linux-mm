Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 720CDC10F00
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 21:32:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34FCF2084B
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 21:32:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34FCF2084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C36E06B0269; Tue,  2 Apr 2019 17:32:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE3EE6B026D; Tue,  2 Apr 2019 17:32:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD3B26B026F; Tue,  2 Apr 2019 17:32:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 77B0B6B0269
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 17:32:34 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id l74so3859928pfb.23
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 14:32:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=r1TqTzAnofVWov8Ckjl4rpwMXRjJzcR/zbtqSMMZ1V0=;
        b=HoUleqaRhJF1RlOm9WlPGez6eUSUWiZeW9eJ+ATZO3PGus1I92kQAqYDUkZyhTi+TT
         yNCobGWmQQs7+Z2pc0LFWVXto26KxUYD62wGC9hWEIYYba6Mj514Gd6/36S4OY13Ttm5
         SdC6eyq+F3+69oglMXun9QmwXJo0HczWDVoR6fFKK0AyMjiBhNWkjtzryAM+pH8yluW2
         tR7sqweaqt/ZBdCSsWPLS6M9f1VImKmffzeUM6fp+8YyXZ1IHAyq/LnAXf/gady9qRT3
         z+qU6XQ6iERgqsmBLBdkZ+ztZAj2fn8QSmqxHBiJ8at+/J4tOhpS+SsSvcuXWSduRX6H
         Fm/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAUW+UwgPwhZQIM5LvUgx3X82v3P9nTITyV4YX4CvZOGO59TyUxc
	/KTRrA3+Y2Ghtb4KClTK1hOH6UAXiby9IvTQiFECUR0VaY74gh37cOr0E7kc0v0eRHDqBciRZh6
	U9UPmGGOkOVIz1pkbdw9gzZ0gTDyitvkaiQAqLnr9QDiPo1vL1hz8T074kKCX2ALANA==
X-Received: by 2002:a63:ac12:: with SMTP id v18mr67427892pge.111.1554240753925;
        Tue, 02 Apr 2019 14:32:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwRZNEvrSSdxJhrwxL8Yxp1M0QKQA9Va+YHPgfoVx2a8u3SfM62tltsrCH6tH9Qg3oaRPy6
X-Received: by 2002:a63:ac12:: with SMTP id v18mr67427811pge.111.1554240752849;
        Tue, 02 Apr 2019 14:32:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554240752; cv=none;
        d=google.com; s=arc-20160816;
        b=j16YIMsAVJB1HItG2/dTA+eGqHemwmozKituUphLmwnHMXlHezzjSzFjfwgVP9KWRP
         24mcdPsalat5aPsMaKRe8+ccVTi3tgyzTvkPIGmOvou7jhSH2NDzHd9CspChM2rPe6Nk
         RvtUmyScWQlEkBtvmlwdpKCect7xYFYTOtZoOB6E/OB4NSjZhK5C7Rulu7dbY7paT51C
         N604Xs8a3m8jW0GEERWZYPn04YFHiggBYTlgz1vth3WK1+qCKBMHglwKWGQBarXFgKgt
         GKSv4TKi8vCHP8iA7b5htkdq6kGUF1NdRL5YBTN5qtnJxx8lvkc6n79h1qMei7/dl7eK
         8H7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=r1TqTzAnofVWov8Ckjl4rpwMXRjJzcR/zbtqSMMZ1V0=;
        b=eZAznLjWLjEAKAdnXhdnhcPSMDaIGPSj51B5ygNub1HCfGBQWt7nmCAUG6/mQd90Na
         +Y0QL6mx9Ln9YsGW1iSJeGxDsSVwt+Gmr4uZDXMr7OFbrs5OXRSFyUrwoyH7/wt1iN17
         XsgTUYFnjuNvFqP8jnK20QbVB64+szju5VXFhTAHmjVoIkryWtoBw/cRVLf56I6Nxer0
         orSPnXKi2qWEPk2R+GRro5Yp0TDy+dlfGYSG3T0MZJGPaK525VFAVudqLKJZadnO1rL9
         9zpOssdPFcQZ7E8NtccBEkeSKGgHTJe+dhN8Ok5+WWp53jzBasZ8TjsA7t/If7QwpLL7
         59fg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b23si12145994pfd.182.2019.04.02.14.32.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 14:32:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id E45E3D88;
	Tue,  2 Apr 2019 21:32:31 +0000 (UTC)
Date: Tue, 2 Apr 2019 14:32:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Greg Thelen <gthelen@google.com>, Roman Gushchin <guro@fb.com>, Michal
 Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun
 Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 stable@vger.kernel.org
Subject: Re: [PATCH v2] writeback: use exact memcg dirty counts
Message-Id: <20190402143230.3ea53a7d599b2d78c39b77b0@linux-foundation.org>
In-Reply-To: <20190401182044.GA3694@cmpxchg.org>
References: <20190329174609.164344-1-gthelen@google.com>
	<20190401182044.GA3694@cmpxchg.org>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Apr 2019 14:20:44 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Fri, Mar 29, 2019 at 10:46:09AM -0700, Greg Thelen wrote:
> > @@ -3907,10 +3923,10 @@ void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
> >  	struct mem_cgroup *memcg = mem_cgroup_from_css(wb->memcg_css);
> >  	struct mem_cgroup *parent;
> >  
> > -	*pdirty = memcg_page_state(memcg, NR_FILE_DIRTY);
> > +	*pdirty = memcg_exact_page_state(memcg, NR_FILE_DIRTY);
> >  
> >  	/* this should eventually include NR_UNSTABLE_NFS */
> > -	*pwriteback = memcg_page_state(memcg, NR_WRITEBACK);
> > +	*pwriteback = memcg_exact_page_state(memcg, NR_WRITEBACK);
> >  	*pfilepages = mem_cgroup_nr_lru_pages(memcg, (1 << LRU_INACTIVE_FILE) |
> >  						     (1 << LRU_ACTIVE_FILE));
> 
> Andrew,
> 
> just a head-up: -mm has that LRU stat cleanup series queued ("mm:
> memcontrol: clean up the LRU counts tracking") that changes the
> mem_cgroup_nr_lru_pages() call here to two memcg_page_state().
> 
> I'm assuming Greg's fix here will get merged before the cleanup. When
> it gets picked up, it'll conflict with "mm: memcontrol: push down
> mem_cgroup_nr_lru_pages()".
> 
> "mm: memcontrol: push down mem_cgroup_nr_lru_pages()" will need to be
> changed to use memcg_exact_page_state() calls instead of the plain
> memcg_page_state() for *pfilepages.
> 

Thanks.  Like this?

void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
			 unsigned long *pheadroom, unsigned long *pdirty,
			 unsigned long *pwriteback)
{
	struct mem_cgroup *memcg = mem_cgroup_from_css(wb->memcg_css);
	struct mem_cgroup *parent;

	*pdirty = memcg_exact_page_state(memcg, NR_FILE_DIRTY);

	/* this should eventually include NR_UNSTABLE_NFS */
	*pwriteback = memcg_exact_page_state(memcg, NR_WRITEBACK);
	*pfilepages = memcg_exact_page_state(memcg, NR_INACTIVE_FILE) +
			memcg_exact_page_state(memcg, NR_ACTIVE_FILE);
	*pheadroom = PAGE_COUNTER_MAX;

	while ((parent = parent_mem_cgroup(memcg))) {
		unsigned long ceiling = min(memcg->memory.max, memcg->high);
		unsigned long used = page_counter_read(&memcg->memory);

		*pheadroom = min(*pheadroom, ceiling - min(ceiling, used));
		memcg = parent;
	}
}

