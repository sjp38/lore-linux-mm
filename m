Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 504F9C282CD
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 21:53:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 112312148E
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 21:53:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="vc03nv96"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 112312148E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A670B8E0004; Mon, 28 Jan 2019 16:53:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A14E98E0001; Mon, 28 Jan 2019 16:53:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DE5C8E0004; Mon, 28 Jan 2019 16:53:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 66E598E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:53:22 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id e188so9187618yba.19
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 13:53:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=6fUmvSDmEjz08XKF0ToKqbVBrxXVRyHjyqapg2MBg6Q=;
        b=mLeMn/MvXZDFW7F4Z9K9FNEeAyKhmMQb5h5dcBiH/wvzcyCivADk8z2ZgV8QCJI7Gu
         tGLLyLe+QY986zUHWCqQAUrhjBevKeH9TTnRofz7DhUnhJ9f4G9IOgPqN2ZTHYOKFWx8
         Oey2r4NvrT7DBaUyN4/RwVjGES4mFz6Pj0+8yJ3XdIv9uZdiRbGoAOdaEbbKZakTB76O
         /YKo1ykJelCoc8x19QGSi8vhTKhIPDqDXOaKg5oe4qiNqTCrMViWG1htRKiqVcQiCdWl
         ou+vUIkRyxP1J0KyBcx7zrXZ1hKcFsMRuM5kr0/JNODyZbrWTnmz2cpTC2LX0m70BICE
         O5Zg==
X-Gm-Message-State: AJcUukfdTkLjNgAcB8xRMVPWW735bvFldEtNSyOeh12LtpMIS0f5qqll
	y7vgNjm5jSugIy+BIKvkR9qs9ZO/V+dLz1ur6akJK/FoO8Pnc5WaRTgo9aeYUQ3/BiOqwjGTXc4
	4olJ5fa3vmYEgzVsKTH8Bpj6nE48DRGVV57zEZ0nbgkko8n7Gl0jSc4lC8i9HayH0UKs1JW7hoy
	Bjtzd2s1XQTTI+rfmapXHKePpxGNG4Xx12Bjjh2c9ETU0HsOlbYlKS726Nda/9Rn5WaJy6H8t9o
	PQ//gQ4PbjFgjkQs6T57k9Tca2PHArQs8nePqcXeylzyjoXTRrnumv2ss8eIJzzO33FvukH/ffk
	AmrGE2kzrlhLgma4KU7DcQe4RDT5gfo9erQZi7BovDVga8jAIdhuI7uIKRUjtCuEhDzc+YvDtTE
	1
X-Received: by 2002:a25:bb0f:: with SMTP id z15mr21806500ybg.57.1548712402081;
        Mon, 28 Jan 2019 13:53:22 -0800 (PST)
X-Received: by 2002:a25:bb0f:: with SMTP id z15mr21806476ybg.57.1548712401428;
        Mon, 28 Jan 2019 13:53:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548712401; cv=none;
        d=google.com; s=arc-20160816;
        b=09GORpCMIlAY9Zdi1dku3bGmHKoS7BlQIATseX2CHwcwZf13uEODD+yKpe6DhpNBLi
         U3hYDWPRFWcR85+d6wm+ES+7Zcc9VkpWEJtnnBloGmIxY88act20eAE3I1OMDAgJI7EK
         krRS45tKO7TUFFjQd/4Hc7eXxUXL2n6++AL0zAtOCSfTPsvJ/acqgsNu3M5IY3YntJpS
         3UtyoDHreOL/jj8XAIbYUagvZFm06cxrfSN6qVle88NM74HYOz0lLV6cAgKwJ2rXZNXM
         C8dAUcfMR+5+pNwPIdVE5PIma7oWOZF9FYEERdGhuO7bT8yex45mc4hZDbxwzvCC95bh
         HIsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=6fUmvSDmEjz08XKF0ToKqbVBrxXVRyHjyqapg2MBg6Q=;
        b=nzdS3nIecFMfX9OvImuWoHEj1w2YnTnqlLZuBnAZvs2O7lqsLFjaAA32zcYU30pU9o
         oAlA9xaMVrGxcHFSI/nTapO4OBhIwrk3FU2jC/wZP7HW0ZBxli4zxxRF+XfKlCDo2ikC
         TQfwSNTLwhN5rE0LVBRcHweZ0ZptEtxMTbSgc+XidhAtvdCwc+2zSJpA9VVQWCcxYKzV
         6niCW+9J5sNUCPx52mbA6cO7nw36ce4z3UYo0UXmzmLEpuftdkUA8gMb3HF8aJ5i/enB
         SKBcDQaJKKPFkuuBuUBsonGSidLEX64mIgi75FHMzmfDH8UlrREQSSd6FAMV4i/VoONO
         zXXg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=vc03nv96;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t138sor4516968ywe.139.2019.01.28.13.53.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 13:53:16 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=vc03nv96;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=6fUmvSDmEjz08XKF0ToKqbVBrxXVRyHjyqapg2MBg6Q=;
        b=vc03nv96i0HISo7x2YIJjRidr5L5AP2IUQx6QxFgZmkIVUMJsMRy0c7TK3FrcHSURc
         aDa2L0TK5Pw30lt66CwIUbIRFXTIeZOeR5wYH0y3ZSoefARez89tTF1w08/hIiX/5Rlh
         GJjqcQ7j7h3kqaYtO+gCx58GfCaJU3ZPM0wKth+exXBNTulSBbeSLUaDHI0Ec3OnAg4g
         dByNON9C53Fc1E24EfHoaYt9+4l+UintuPdprpmzY+UswWd8CDo6bAtldH5kxOeofiZ1
         YBz7LQltzMI/JmZH1RSxBWnMzbc62P4Qaj5+NnVugVBXwh5S9CL0bDhvujlyxrbRU3I4
         LuFw==
X-Google-Smtp-Source: ALg8bN4OAl6UXpscoGwFFiaBA21eQ202GOZJFhhB7GKXE4/crw3XmlqCZtLMiadTAOmXTDWM+Q1W7g==
X-Received: by 2002:a81:b653:: with SMTP id h19mr22487323ywk.170.1548712396677;
        Mon, 28 Jan 2019 13:53:16 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::5:42c8])
        by smtp.gmail.com with ESMTPSA id u4sm24465788ywu.92.2019.01.28.13.53.15
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 28 Jan 2019 13:53:15 -0800 (PST)
Date: Mon, 28 Jan 2019 16:53:15 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>,
	Arkadiusz =?utf-8?Q?Mi=C5=9Bkiewicz?= <a.miskiewicz@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org,
	Aleksa Sarai <asarai@suse.de>, Jay Kamat <jgkamat@fb.com>,
	Roman Gushchin <guro@fb.com>, linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>
Subject: Re: [PATCH v3] oom, oom_reaper: do not enqueue same task twice
Message-ID: <20190128215315.GA2011@cmpxchg.org>
References: <6da6ca69-5a6e-a9f6-d091-f89a8488982a@gmail.com>
 <72aa8863-a534-b8df-6b9e-f69cf4dd5c4d@i-love.sakura.ne.jp>
 <33a07810-6dbc-36be-5bb6-a279773ccf69@i-love.sakura.ne.jp>
 <34e97b46-0792-cc66-e0f2-d72576cdec59@i-love.sakura.ne.jp>
 <2b0c7d6c-c58a-da7d-6f0a-4900694ec2d3@gmail.com>
 <1d161137-55a5-126f-b47e-b2625bd798ca@i-love.sakura.ne.jp>
 <20190127083724.GA18811@dhcp22.suse.cz>
 <ec0d0580-a2dd-f329-9707-0cb91205a216@i-love.sakura.ne.jp>
 <20190127114021.GB18811@dhcp22.suse.cz>
 <e865a044-2c10-9858-f4ef-254bc71d6cc2@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e865a044-2c10-9858-f4ef-254bc71d6cc2@i-love.sakura.ne.jp>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Tetsuo,

On Sun, Jan 27, 2019 at 11:57:38PM +0900, Tetsuo Handa wrote:
> From 9c9e935fc038342c48461aabca666f1b544e32b1 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Sun, 27 Jan 2019 23:51:37 +0900
> Subject: [PATCH v3] oom, oom_reaper: do not enqueue same task twice
> 
> Arkadiusz reported that enabling memcg's group oom killing causes
> strange memcg statistics where there is no task in a memcg despite
> the number of tasks in that memcg is not 0. It turned out that there
> is a bug in wake_oom_reaper() which allows enqueuing same task twice
> which makes impossible to decrease the number of tasks in that memcg
> due to a refcount leak.
> 
> This bug existed since the OOM reaper became invokable from
> task_will_free_mem(current) path in out_of_memory() in Linux 4.7,
> but memcg's group oom killing made it easier to trigger this bug by
> calling wake_oom_reaper() on the same task from one out_of_memory()
> request.

This changelog seems a little terse compared to how tricky this is.

Can you please include an explanation here *how* this bug is possible?
I.e. the race condition that causes the function te be entered twice
and the existing re-entrance check in there to fail.

> Fix this bug using an approach used by commit 855b018325737f76
> ("oom, oom_reaper: disable oom_reaper for oom_kill_allocating_task").
> As a side effect of this patch, this patch also avoids enqueuing
> multiple threads sharing memory via task_will_free_mem(current) path.

