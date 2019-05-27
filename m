Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 573C3C28CBF
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 07:43:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 167AB2173C
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 07:43:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QR6jJPIt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 167AB2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A44366B0266; Mon, 27 May 2019 03:43:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F43B6B026B; Mon, 27 May 2019 03:43:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E3806B026C; Mon, 27 May 2019 03:43:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 542336B0266
	for <linux-mm@kvack.org>; Mon, 27 May 2019 03:43:08 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e16so11267389pga.4
        for <linux-mm@kvack.org>; Mon, 27 May 2019 00:43:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=lXwtkUKjJRctNYznRKr06c91Cgy9C63icBzCRvy/T1w=;
        b=pCc1Rs7GLR54t8APr8RaNVXWPYtryjNdtGjroJ6Zo/LqeL0+DNjpqgulb9db6yVup+
         l+bHFQunTn57Nqki/I63eFlv80dW8caEGEnAfKvILJBcM1/LjmB34BcNoDJQPmwhg37I
         L7igRKaZsud1ynqps2AMt9oFn+J4DCV5/VdOdLUX5ravEoJlfXAuczjq/bXZzhvdeKJ2
         OLoGHsnpV2YrUxnh/XR8P+9fptsadsoabFH0Oby5zJXsiW5tryllGrkzNVdhBL9PawT5
         1z+5JiEls9bhz60Z91jRXA9nzvhoT6U/o2CpUd7ewkGhcwbfl+8QU61qJoHrodjCxjEl
         8nkA==
X-Gm-Message-State: APjAAAU4McCTIKyOkUPoSFU+n+GB8zDlgQx0QQqyYEHOGWyB12IeNjRZ
	ANWMQvA1Bp3DOgCI2JAADAwP3Lny7+ROhv2oFtmlHDuvvbG7jco6P8PJvrU1gCVygMbD0NZ4+CX
	MCODrZ1bXyP7bTw8nVKbIE2M1Op43MdIDCJF/Fr5DhwQtjVLeZOoJi7Sb48QrJfs=
X-Received: by 2002:a62:ea04:: with SMTP id t4mr131220841pfh.47.1558942987920;
        Mon, 27 May 2019 00:43:07 -0700 (PDT)
X-Received: by 2002:a62:ea04:: with SMTP id t4mr131220780pfh.47.1558942987246;
        Mon, 27 May 2019 00:43:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558942987; cv=none;
        d=google.com; s=arc-20160816;
        b=JLVaMaCZkGjCcHflKeQLtNqOIYvOKkdigw4mJLCdeCiQjHihmuukFI+UCB1f/SwMBg
         jKO21FWLkS+YOtdV9J8mv5Xuvon9oJu3QokuR6RYRdGKg5b6F5shUtrQJV0QFKcfr7L7
         dECq/3D12a2Ld6hpVwUtgpShctYsPC+wR1b/JtaQrIA4Hgk7ndD6vdX98EPpa0Tj4C9d
         Z4V8VvXINMgVhtIhDvcsDEhdRs+/QwPhYe8cGfHIopROwjdzLToENUQjTFdyIytrnUWY
         jVVZbMQaDzQcxIw6ZtQ3V372wT56YnDViLN+QR4GtM9QfW4686O4KLTmm8XY6ViCxwyI
         IPug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=lXwtkUKjJRctNYznRKr06c91Cgy9C63icBzCRvy/T1w=;
        b=DO3oPldpi8lN0KNXDPbkL2xchh0J9hLS+jyzWw0LCizBbxpQuY8Q/SB1gPRIPbyLNc
         hJLIG5io7rXY9+ey+tQDx9YWnEphrJKLV/n5eHAd1Q8x97QcQvJITWtcYD4ZmJh3nbTi
         ry623Q3LUkTgkP0sg/rMgQ72phvcoQl26IaRAX0vQSL3pc2qbZ+mGfIdDwEOzYj6jMNU
         ChITCY4DJekyopJRqVXur1+S1KgqmxizLyPcGCaW/tIAGetUleLCJSxVMUOGyoNQAsXQ
         gWs7/QBZ6nBnPxF7OyABbLP2NBDuydwsZjxFLOEpFDvb7lVC4stsYQxAOiu4RlNTqVJU
         xZ/A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QR6jJPIt;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e33sor12451478pld.69.2019.05.27.00.43.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 May 2019 00:43:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QR6jJPIt;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=lXwtkUKjJRctNYznRKr06c91Cgy9C63icBzCRvy/T1w=;
        b=QR6jJPItZ8Rz7z74p4b9j9wtPd8xgqz3msBmmSz49q9GIZ+wNyU8WoH5wmAG5ujTT4
         ZG0ewEzX+SWlNilKu39R1gD2jcTu+0RDpAaENMrl5z4G7OIVnc95SUtK/MnRY8rzIp14
         p9mBhlnuxGq6cWe8nUwhBHVobbuRMb0BG0NiorPdgDrRxwgHtY90D5esPw/xjQ2TEnek
         i5hHksIVCegyo3by8HhykHa7MJAsx+fZhtnMaN4J4+MoX8GoE3O3iM8tBuoKAGGWE2q4
         /kLZLsJEa+mn7ouhwLI9sQnMxIgt50b5cIJ4RtU7MBMfeifeDJAM22at8IK5rxJ37+gC
         jQ3Q==
X-Google-Smtp-Source: APXvYqxa35u12pQHum/AcABmpbDr09kLk3WP9Gem47sfN0k5HrNMA7iKabi/mN8AIWOV57ysYuVnkw==
X-Received: by 2002:a17:902:ac8b:: with SMTP id h11mr13047842plr.31.1558942986856;
        Mon, 27 May 2019 00:43:06 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id z7sm12464953pfr.23.2019.05.27.00.43.02
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 27 May 2019 00:43:05 -0700 (PDT)
Date: Mon, 27 May 2019 16:43:00 +0900
From: Minchan Kim <minchan@kernel.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 5/7] mm: introduce external memory hinting API
Message-ID: <20190527074300.GA6879@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-6-minchan@kernel.org>
 <20190521153113.GA2235@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521153113.GA2235@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Sorry for the late response. I miseed your comment. :(

On Tue, May 21, 2019 at 05:31:13PM +0200, Oleg Nesterov wrote:
> On 05/20, Minchan Kim wrote:
> >
> > +	rcu_read_lock();
> > +	tsk = pid_task(pid, PIDTYPE_PID);
> > +	if (!tsk) {
> > +		rcu_read_unlock();
> > +		goto err;
> > +	}
> > +	get_task_struct(tsk);
> > +	rcu_read_unlock();
> > +	mm = mm_access(tsk, PTRACE_MODE_ATTACH_REALCREDS);
> > +	if (!mm || IS_ERR(mm)) {
> > +		ret = IS_ERR(mm) ? PTR_ERR(mm) : -ESRCH;
> > +		if (ret == -EACCES)
> > +			ret = -EPERM;
> > +		goto err;
> > +	}
> > +	ret = madvise_core(tsk, start, len_in, behavior);
> 
> IIUC, madvise_core(tsk) plays with tsk->mm->mmap_sem. But this tsk can exit and
> nullify its ->mm right after mm_access() succeeds.

You're absolutely right. I will fix it via passing mm_struct instead of
task_struct.

Thanks!

> 
> another problem is that pid_task(pid) can return a zombie leader, in this case
> mm_access() will fail while it shouldn't.

I'm sorry. I didn't notice that. However, I couldn't understand your point. 
Why do you think mm_access shouldn't fail even though pid_task returns
a zombie leader? I thought it's okay since the target process is exiting
so hinting operation would be meaniness for the process.

