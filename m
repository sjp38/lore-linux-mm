Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.5 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B3A3C48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 14:05:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5DAB21670
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 14:05:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5DAB21670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36E128E000D; Wed, 26 Jun 2019 10:05:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31EC28E0002; Wed, 26 Jun 2019 10:05:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1BF6F8E000D; Wed, 26 Jun 2019 10:05:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D4E118E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 10:05:00 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id q2so1490775plr.19
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 07:05:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:thread-topic
         :content-transfer-encoding;
        bh=050VPoQf/jnyD/7/B0/hvCoujaULA3kE+AVv/WSJj74=;
        b=F0f7qKWuoGerfFy7cLJ9gBTa6IpHb60uY3hLs9E9qu1knC5KfrFDXOc5n492vrn3ED
         mtEuY0FVizqix9z5P7W3bCyR08imD4eI2N+meYEpG+d4WQdwWKGF702s+Fz3+4k2bk39
         6NqMUwIAA9kqYy1UHtYdV3xIzxMyJQ/suo8/z4YDLZFNZsGttDwl7NRV5nSxqrSRtwYN
         uM60e+TaRYS5mIJSq5gJ2vEJfNf2hI/kpB6Ov49UUKCAD5w83lXyvem1CCALxteEts/q
         kSZHx1/D6QfRhAyQ1dgulWutk060kxaSJARaN93qxC5k8NMf0oV6D5BJBhCJtkBFQxKX
         6eYQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.213 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAXSBqtVnCb81Jk77TotAqXz+IZLtyo2nv4xxuPL0rLEmDWJYXfs
	Jb0GVKzOcTdB7IolBWfJpssm8BEHAR/5FYUjQXbrKP0qc9xH6G4cS/JAqLIUnPLtdrOSsCMcAI7
	NKfTG4P33HHowm905HknB2DhxA39RYk9xgIqtdBDFGlui0okTtRkabJLEUV2Jxm3ePg==
X-Received: by 2002:a17:902:f64:: with SMTP id 91mr5513082ply.247.1561557900525;
        Wed, 26 Jun 2019 07:05:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxUa426c41xbrZujzuBgD2n8I/8lqXgcdFCfYIkVO0aaSfrP61MwMAyh91Kdcmu9ZlqXB3e
X-Received: by 2002:a17:902:f64:: with SMTP id 91mr5513013ply.247.1561557899745;
        Wed, 26 Jun 2019 07:04:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561557899; cv=none;
        d=google.com; s=arc-20160816;
        b=xHv4+5dEPoGjVgaKsLJvzcY8nHUTOt4/OXcGP1EYw6+ovoQrln69RUMrYSEkxFlpOY
         Oo4hqSVELI7KLSvPM9t9VCpJmehYDIcvObvzFoDO9DVuTwPxtYnitR6NO+kffoQvo390
         VElbjMqvNDiasrr8tkLiXCjXdG6nm158sVgAPUOaIUw8jJWxv/6NRLdh5s/pzJag436n
         xj6xe/BKf89/3QrYpEaWPcH1c5befzD32WCPpEGNbcqFM8VDEaJHETPq9xPE6AZDZj84
         mCyLvKw+HnBaOWAXbtumxD95oZoarOOWcwEJgGGNhbPEfZD7F40EbDjhmm8vC486Q4EO
         eJrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:thread-topic:mime-version:message-id:date
         :subject:cc:to:from;
        bh=050VPoQf/jnyD/7/B0/hvCoujaULA3kE+AVv/WSJj74=;
        b=q54YGeuRZRYeAn8MIGNA16C8DZ3b4oTALrOzUFWhoMF7C0fdIBGSj0ia24sdxNgUbn
         8PQ1CW9sR1NYTj4CehTMzKKSz4v1b/g6I/SxtdMh0Q89RbvX0V25EVUkArpuhqcVkHCX
         c9ylWNOCi5z+2jafSP4D+DZCEoCXlY30q/W4W/FUwS5HvYO8kohnOuzNECheta3qSMQx
         476QZZ4asobV/rIrFLP1Vq7Ayk1L2DOozoh398l/CB7poEHHmxhFBXiXYpLkS2+ULJ7l
         vR6aJ1e5N1PGXgifiGAps+6ySHlnC17TWOuWdhxoJtWCB+T9Rt22xmEOhqdxp0g25VaR
         S2Pg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.213 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail7-213.sinamail.sina.com.cn (mail7-213.sinamail.sina.com.cn. [202.108.7.213])
        by mx.google.com with SMTP id d37si3438866plb.351.2019.06.26.07.04.59
        for <linux-mm@kvack.org>;
        Wed, 26 Jun 2019 07:04:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.7.213 as permitted sender) client-ip=202.108.7.213;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.213 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([114.246.226.133])
	by sina.com with ESMTP
	id 5D137B8300006796; Wed, 26 Jun 2019 22:04:56 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 513555394772
From: Hillf Danton <hdanton@sina.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Shakeel Butt <shakeelb@google.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>,
	David Rientjes <rientjes@google.com>,
	KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Paul Jackson <pj@sgi.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com" <syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com>
Subject: Re: [PATCH v3 3/3] oom: decouple mems_allowed from oom_unkillable_task
Date: Wed, 26 Jun 2019 22:04:44 +0800
Message-Id: <20190626140444.2880-1-hdanton@sina.com>
MIME-Version: 1.0
Thread-Topic: Re: [PATCH v3 3/3] oom: decouple mems_allowed from oom_unkillable_task
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 26 Jun 2019 17:18:26 +0800 Michal Hocko wrote:
> On Wed 26-06-19 17:12:10, Hillf Danton wrote:
> >
> > On Mon, 24 Jun 2019 14:27:11 -0700 (PDT) Shakeel Butt wrote:
> > >
> > > @@ -1085,7 +1091,8 @@ bool out_of_memory(struct oom_control *oc)
> > >  	check_panic_on_oom(oc, constraint);
> > > 
> > >  	if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
> > > -	    current->mm && !oom_unkillable_task(current, oc->nodemask) &&
> > > +	    current->mm && !oom_unkillable_task(current) &&
> > > +	    has_intersects_mems_allowed(current, oc) &&
> > For what?
> 
> This is explained in the changelog I believe - see the initial section

Correct, Sir.

> about the history and motivation for the check. This patch removes it

I'd read that again.

> from oom_unkillable_task so we have to check it explicitly here.
> 
Thank you very much for the light you are casting, Sir.

--
Hillf
> > >  	    current->signal->oom_score_adj !=3D OOM_SCORE_ADJ_MIN) {
> > >  		get_task_struct(current);
> > >  		oc->chosen =3D current;
> > > --
> > > 2.22.0.410.gd8fdbe21b5-goog
> 
> --
> Michal Hocko
> SUSE Labs

