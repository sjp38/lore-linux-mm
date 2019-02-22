Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1E50C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 19:15:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B21A206B6
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 19:15:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="p7QyebLN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B21A206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD6D08E0105; Fri, 22 Feb 2019 14:15:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A5E5D8E00B1; Fri, 22 Feb 2019 14:15:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8FFFC8E0105; Fri, 22 Feb 2019 14:15:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5A2A48E00B1
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 14:15:58 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id i129so1931668ywf.18
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 11:15:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Ch+IrhOotwsiBbkZp+IeYBbpstxbpSb81CB7W4c9iKw=;
        b=Kk9ErCVTL5KXLW5HHxK8LQ3polKvWs5WS1F1ggw9KsF2rqpGDC0bgsvZFPi6EhF4+5
         8g3QyfznHXPTWIfK/cQaxePRgOgLG/hxg1B15Hcn3UN0lUEdIsYeroMLJhUDPzukAdWg
         Jm7xK50vNj9z6ZPhUjk8zPDPZfF83USXIheD0KlIkpB1acXvwKivnd1XtCHbGlYH59Zc
         KiWNJ3jd6fqfj8JwCYkKVXfuH1grq2tfQEATyxlIvfenkTc9bs7OIZT6fTmynFcM8TVM
         dnLv6iuc/TBdqICuY6WuKmaDUWZaRjRn16VdWDAjDRPwudsiJw3XR8eKZb6RkO6hofGW
         lmGg==
X-Gm-Message-State: AHQUAuZPeRPNLxqgZ0T8J3a/y7tWZMuQDtMPj1iwWoNkRkIG5sXygQa6
	ze10LbpF0XaX3rzBsMsnhze/G+UA4qko6umYhNGn+D/6gnZxJL8cyFqJqknUFIOcAmf2wANAqlK
	cNhe8Vez0g5Lj+/ftjR2G5Vses3FZbSk0ufOoBIKdqc+5ae3LLxzxYTwI61jJBEofXpgQItGyNh
	1Kd56whcNYm8c1LFXY00pYhs9uRuUShFSB3i+ufAuAiWmC7/3c9u/U+N663A95AGkmXwMCsfUfd
	79wapQknhQUUvezGIOj9fds2zwvoUpd3geAUFPfHqTrW277KE7T5Hkg0TB8XD6EApH1OrUkX3Az
	0wAtiPCpea6RvNw0rPd99HCFpDyTGzC1E0e/5/DqBd46Rs8cQEs0SWJm31YieYmbh6hiNyTy5H1
	w
X-Received: by 2002:a0d:c4c2:: with SMTP id g185mr4529553ywd.31.1550862958043;
        Fri, 22 Feb 2019 11:15:58 -0800 (PST)
X-Received: by 2002:a0d:c4c2:: with SMTP id g185mr4529505ywd.31.1550862957275;
        Fri, 22 Feb 2019 11:15:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550862957; cv=none;
        d=google.com; s=arc-20160816;
        b=E1u4U8l4frFQPrMRohyVDOkvbL3z4fTGKw5pwY1OD9BB5T3Nlr3jfM7Itn8Gj8/8z7
         mCoVKOYSLGffAtR67yuWJIqioG7Y9/1T7IQHLbBBpBGwtPVlKB070HqHg1vT71h12Obp
         ztsnBVQdWSnonii/jgaAJmXbk1TlUgihw3yZhqkFBi12mr4hJGb7IWCqDHPaMvbRq0vZ
         mF+8rDfw3eTNpikpjzyEeSm60jMlSgLEqgeJoZeuD8DxRrxTEv2hioLItSUrqrY079rG
         E1A9ro/akdXupMa8IMYOpYKzosNn/UUD4UelHxQMsiqvHLfKmwwNejsbuLM0+8LotTLK
         QnhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Ch+IrhOotwsiBbkZp+IeYBbpstxbpSb81CB7W4c9iKw=;
        b=rvOzIrcsMcWxIlYeRcaDHubuc6+1/p5Jh6TWXt4o+aXVWNDXSEKNwOS0KUykaQwnq2
         5Ze7qbc9h+2caLONJvEqht1LjL05qEgP3Vw/1dcIjy2VxXJOIt0kpIOz+FdcJzjHPVsO
         eWlYMPpV/LVXMhmLg1V9sxdJ/RrPTgk+r9DZCUOHqScUKEyDRYuJhtXTo3Ci82+avL3U
         lg9zpJWoz1/IN1bdaW7pX5gEBEwh92Ox3Ew+hKL0QvUrzWPPR4bxaGb09neVhh3lIcxZ
         0xKNMUlou3s8XDW8T8zME2ROgGIQIWZEMCZpitYkDJTtELcixPEK9AAMW/KHa/bwh41b
         6TUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=p7QyebLN;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x7sor1155224yba.107.2019.02.22.11.15.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Feb 2019 11:15:54 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=p7QyebLN;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Ch+IrhOotwsiBbkZp+IeYBbpstxbpSb81CB7W4c9iKw=;
        b=p7QyebLN0ZHPV0mrxHDSsUYEsSDKPDgLdF4AyXo6JBnQAik8BXsgDOy+9d4faBnikI
         cHnJZVGgKBWKMsG17Q+d81RfHqEgsCjE34KxnrOQEK327UAQeIjZ1EvW3xPI3nzcJp/e
         694TAxOO7mMk7bcGrnNDoN05RVUpexxagF1qHhsd0iSxKrHLiAC7CC3KB7Ir1DeM0gi6
         8glHmHZ3url2TFp1UdXof5Q/VgTw88tWa5yhhiXY8BC8zgMvulNZopN+gYQMpuoYYGrc
         gywoZqGNRv8zba6mxApM85gvFzaHaZTMKeNbY6WGtLpP8xy8qIKGK9UD3AlkSr5Pzyc4
         qE9Q==
X-Google-Smtp-Source: AHgI3IbFsJR9WqArxrjJB/G5LtHREJOHEINy/tUTd8v/9gUMk5Doxdnh2Fz8JfuJOvPZQIUwue7bZw==
X-Received: by 2002:a25:9ac7:: with SMTP id t7mr4715071ybo.469.1550862954392;
        Fri, 22 Feb 2019 11:15:54 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::1:cd3d])
        by smtp.gmail.com with ESMTPSA id a190sm730703ywg.76.2019.02.22.11.15.53
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 22 Feb 2019 11:15:53 -0800 (PST)
Date: Fri, 22 Feb 2019 14:15:52 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@surriel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Roman Gushchin <guro@fb.com>, Shakeel Butt <shakeelb@google.com>
Subject: Re: [PATCH RFC] mm/vmscan: try to protect active working set of
 cgroup from reclaim.
Message-ID: <20190222191552.GA15922@cmpxchg.org>
References: <20190222175825.18657-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190222175825.18657-1-aryabinin@virtuozzo.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 22, 2019 at 08:58:25PM +0300, Andrey Ryabinin wrote:
> In a presence of more than 1 memory cgroup in the system our reclaim
> logic is just suck. When we hit memory limit (global or a limit on
> cgroup with subgroups) we reclaim some memory from all cgroups.
> This is sucks because, the cgroup that allocates more often always wins.
> E.g. job that allocates a lot of clean rarely used page cache will push
> out of memory other jobs with active relatively small all in memory
> working set.
> 
> To prevent such situations we have memcg controls like low/max, etc which
> are supposed to protect jobs or limit them so they to not hurt others.
> But memory cgroups are very hard to configure right because it requires
> precise knowledge of the workload which may vary during the execution.
> E.g. setting memory limit means that job won't be able to use all memory
> in the system for page cache even if the rest the system is idle.
> Basically our current scheme requires to configure every single cgroup
> in the system.
> 
> I think we can do better. The idea proposed by this patch is to reclaim
> only inactive pages and only from cgroups that have big
> (!inactive_is_low()) inactive list. And go back to shrinking active lists
> only if all inactive lists are low.

Yes, you are absolutely right.

We shouldn't go after active pages as long as there are plenty of
inactive pages around. That's the global reclaim policy, and we
currently fail to translate that well to cgrouped systems.

Setting group protections or limits would work around this problem,
but they're kind of a red herring. We shouldn't ever allow use-once
streams to push out hot workingsets, that's a bug.

> @@ -2489,6 +2491,10 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>  
>  		scan >>= sc->priority;
>  
> +		if (!sc->may_shrink_active && inactive_list_is_low(lruvec,
> +						file, memcg, sc, false))
> +			scan = 0;
> +
>  		/*
>  		 * If the cgroup's already been deleted, make sure to
>  		 * scrape out the remaining cache.
> @@ -2733,6 +2739,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>  	struct reclaim_state *reclaim_state = current->reclaim_state;
>  	unsigned long nr_reclaimed, nr_scanned;
>  	bool reclaimable = false;
> +	bool retry;
>  
>  	do {
>  		struct mem_cgroup *root = sc->target_mem_cgroup;
> @@ -2742,6 +2749,8 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>  		};
>  		struct mem_cgroup *memcg;
>  
> +		retry = false;
> +
>  		memset(&sc->nr, 0, sizeof(sc->nr));
>  
>  		nr_reclaimed = sc->nr_reclaimed;
> @@ -2813,6 +2822,13 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>  			}
>  		} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
>  
> +		if ((sc->nr_scanned - nr_scanned) == 0 &&
> +		     !sc->may_shrink_active) {
> +			sc->may_shrink_active = 1;
> +			retry = true;
> +			continue;
> +		}

Using !scanned as the gate could be a problem. There might be a cgroup
that has inactive pages on the local level, but when viewed from the
system level the total inactive pages in the system might still be low
compared to active ones. In that case we should go after active pages.

Basically, during global reclaim, the answer for whether active pages
should be scanned or not should be the same regardless of whether the
memory is all global or whether it's spread out between cgroups.

The reason this isn't the case is because we're checking the ratio at
the lruvec level - which is the highest level (and identical to the
node counters) when memory is global, but it's at the lowest level
when memory is cgrouped.

So IMO what we should do is:

- At the beginning of global reclaim, use node_page_state() to compare
  the INACTIVE_FILE:ACTIVE_FILE ratio and then decide whether reclaim
  can go after active pages or not. Regardless of what the ratio is in
  individual lruvecs.

- And likewise at the beginning of cgroup limit reclaim, walk the
  subtree starting at sc->target_mem_cgroup, sum up the INACTIVE_FILE
  and ACTIVE_FILE counters, and make inactive_is_low() decision on
  those sums.

