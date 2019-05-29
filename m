Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 183BCC04AB3
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 08:52:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3CC520B7C
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 08:52:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3CC520B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A8DF6B0005; Wed, 29 May 2019 04:52:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6598E6B000C; Wed, 29 May 2019 04:52:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56F4B6B0010; Wed, 29 May 2019 04:52:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 393A56B0005
	for <linux-mm@kvack.org>; Wed, 29 May 2019 04:52:41 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id i195so3157513ite.1
        for <linux-mm@kvack.org>; Wed, 29 May 2019 01:52:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:thread-topic
         :content-transfer-encoding;
        bh=5iRzk9rRTnly/r/bXGzi+DAVdl8EXoOOvD3iN72g930=;
        b=ncevDiHoSOMIgdKECMjHdVhHIZjPluMq1hQ8rNKG4TD+AiffDOX6hv+kdPCya04Ho+
         2WjP13JqcwPscM1nEyrWHAuoVBJvBCoAReOKcwjAWGTWCI8ztMoxitJR3ikulHffCOPv
         dfq4W5t28+dYGJ/RtyzAQtlA1ixizbZSHRZuN8OI8W8v7NxfPcPQuvA3g0xAZagjfelS
         zAoDOZdujTtZn6C3d9ntIAqpHdARa1NAsHYCL+letVSG9i2z91kDNnbGkwzGJozZayxj
         tjkFYO2zD2Ns8feS7Ck3v/SdDEZeTKKGchLKYkpjEjvPMNCmAM2yweB7C6VoE60WAajb
         mweQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.167 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAW4yKupEmR01UdecCVaQshllpH9OIVBaBAm2R73yJiuWPbGXCze
	GjgWiqHmk6d/rZ6qb+UpYjevePd+M5iT72+yLYVusdemq/9BjvXrUfg+fnPtNzYU2Tf0X2pu0dT
	NN48wNXADLf0F7AXAz85qNcmgI8HHnOg65Lm5q9OGTM/cy2hXErFANnlbfOdjnqHmhw==
X-Received: by 2002:a24:fa42:: with SMTP id v63mr6169774ith.20.1559119960979;
        Wed, 29 May 2019 01:52:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBK210OI4+agBPFz8uqjSVoR8vg1SrDqaCUjVXcu662OfrT5lLnChDqPOjEZLZ8PHHayJf
X-Received: by 2002:a24:fa42:: with SMTP id v63mr6169580ith.20.1559119955107;
        Wed, 29 May 2019 01:52:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559119955; cv=none;
        d=google.com; s=arc-20160816;
        b=KFMJJhW07IafVMTXUXvDdxHkgtlKHH2UlCkskr9IExdgFpcmTUCvDNCaFQ8PhHK2dv
         p7ln+3I5QqdNwGyd2FfEvEJAqa8qEge7bhqXN3WUrRkhyImBLL0lszTGHBLTuPMidN4x
         qN9er4dnB1Ka/5hOaf6/3P6VclDmms2t5QiIyLgiMjkIz9RYOCg3WCHnuKg/ofUSFcOI
         g91D1DOuWVCO+wYUq0KoB0hlSoQ5b2jMlYTEEHI2MwIox7bxLE5+91pjX2EPuWUdLFXz
         B7x+pLAwr9lNrsJEDHqmSax9dMDZV9vz+7E/5M+rHXGpzY3KpLZib7TmBJgf7GvjqCRu
         SSsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:thread-topic:mime-version:message-id:date
         :subject:cc:to:from;
        bh=5iRzk9rRTnly/r/bXGzi+DAVdl8EXoOOvD3iN72g930=;
        b=cccVvo++T5UqaF5Io/H8gxEJ1VeZXJGkQxEigwkHvQU57ginJYCyWAT/ak+4ZXlHwX
         Zqj0R3GChlU8JmQAbrhHWbUh7BspxWy/abMG1sRzH89N9b+TRK+wYZpUOOZ5vM5nZQWW
         +OjnIMsCL9NBhMTCny2ty4O8mhllWk/JEvzQ/1katLzk7XYLOq9NqPQtIVtRIk/0hIpy
         6GAEBKziDNOqzWPClAheXbpjZntHixHHzWhiHWg+XhYRPqmjG8JC9wKZusnt9EdJRA5D
         QpPj+gSTP4lr5SUfOJKroDRUf8+OLnTgQk+OBqg2uO7Qs4hkbVsLzP2EHG1wS7Qmonth
         e/SA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.167 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail3-167.sinamail.sina.com.cn (mail3-167.sinamail.sina.com.cn. [202.108.3.167])
        by mx.google.com with SMTP id b12si1125259itb.77.2019.05.29.01.52.34
        for <linux-mm@kvack.org>;
        Wed, 29 May 2019 01:52:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.167 as permitted sender) client-ip=202.108.3.167;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.167 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([123.112.52.157])
	by sina.com with ESMTP
	id 5CEE48390000211A; Wed, 29 May 2019 16:52:25 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 983089405364
From: Hillf Danton <hdanton@sina.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>,
	Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 1/7] mm: introduce MADV_COOL
Date: Wed, 29 May 2019 16:52:00 +0800
Message-Id: <20190529085200.13444-1-hdanton@sina.com>
MIME-Version: 1.0
Thread-Topic: Re: [RFC 1/7] mm: introduce MADV_COOL
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 29 May 2019 13:05:52 +0800 Michal Hocko wrote:
> On Wed 29-05-19 10:40:33, Hillf Danton wrote:
> > On Wed, 29 May 2019 00:11:15 +0800 Michal Hocko wrote:
> > > On Tue 28-05-19 23:38:11, Hillf Danton wrote:
> > > > 
> > > > In short, I prefer to skip IO mapping since any kind of address range
> > > > can be expected from userspace, and it may probably cover an IO mapping.
> > > > And things can get out of control, if we reclaim some IO pages while
> > > > underlying device is trying to fill data into any of them, for instance.
> > > 
> > > What do you mean by IO pages why what is the actual problem?
> > > 
> > Io pages are the backing-store pages of a mapping whose vm_flags has
> > VM_IO set, and the comment in mm/memory.c says:
> >         /*
> >          * Physically remapped pages are special. Tell the
> >          * rest of the world about it:
> >          *   VM_IO tells people not to look at these pages
> >          *      (accesses can have side effects).
> > 
> 
> OK, thanks for the clarification of the first part of the question. Now
> to the second and the more important one. What is the actual concern?
> AFAIK those pages shouldn't be on LRU list.

The backing pages for GEM object are lru pages, see the function
drm_gem_get_pages() in drivers/gpu/drm/drm_gem.c, please.

> If they are then they should
> be safe to get reclaimed otherwise we would have a problem when
> reclaiming them on the normal memory pressure.

Yes, Sir, they could be swapped out.

> Why is this madvise any different?

Now, it is not, thanks to the light you are casting.

BR
Hillf

