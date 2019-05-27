Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E33CC07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 23:33:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13F922081C
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 23:33:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Pcm1ooQR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13F922081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9EDEE6B027C; Mon, 27 May 2019 19:33:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99E526B027F; Mon, 27 May 2019 19:33:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88DC86B0281; Mon, 27 May 2019 19:33:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 522476B027C
	for <linux-mm@kvack.org>; Mon, 27 May 2019 19:33:15 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d9so14312620pfo.13
        for <linux-mm@kvack.org>; Mon, 27 May 2019 16:33:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=+Tzevj0aBFVFkJCWK4eLpOvzUlkBo2BfRqQfZEvwMvs=;
        b=bT9wRes/UNuXYaZMdUE9PXvTfGcX2n61EDn1OxiebnmxrITYdZTsb3xE4jyJ5Ndvw6
         +N6Ei+XjpAvLU/berRs7NhsHX7FUZo4iBz4I4ff3wezzpuavmFN8BMWwhvhaDCA9PUc5
         8iB+9Oj4EQWcVRy34r5JGl8KZ5MM4IJzYm6iuPsMuN5Ukkn50mndlPXojEPV3Y29RG/c
         9FzvC32taopdvwhHtMVCPMpiA906SGSWqeRvw/2QDA4SwzQASPC3CaPr86B5Wa6MD1NF
         4nF73zz1nn+lkC5ym3YSs6O0qlN8SK00iOmD1WVrTSMv5/1OeE9M+fqHpVYvVWKGD1yP
         RJdw==
X-Gm-Message-State: APjAAAXsd9zkhtPh2r7xPQmn7/vjcRyBaWLjMIQIRaXPbOo8hRDF34J2
	PR65+KYyJiW9WXeHbM5D3JBhP7N6ATms/pl+fgcCMMvoGPZ1QH1f20Cjb6pP+28TUd6itAXhx9u
	TOtqlZXeUNEh24jYyLCh7vWhKGhMiGwTG3+k3JHtcudcdNmUcPcoNRCiBSCrTt04=
X-Received: by 2002:a17:902:9f8b:: with SMTP id g11mr124226844plq.199.1558999994869;
        Mon, 27 May 2019 16:33:14 -0700 (PDT)
X-Received: by 2002:a17:902:9f8b:: with SMTP id g11mr124226803plq.199.1558999994188;
        Mon, 27 May 2019 16:33:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558999994; cv=none;
        d=google.com; s=arc-20160816;
        b=Kcp87hz857N/rBTH1lUHvFlzOJYHixvsSpcG9WltGBBlIt/uh0DGZoelxUm+ZZgqUT
         F4zZd5rPFnzl5NFBvLG0tMkJ1aNbHQpmltrRWoyY1uEJGecrmNtT/4xqRD57CC9cDDu7
         tg4so+D+KNk4uA/f6iSdKlV9SGOoSXylK0AysLuCLB6/Qq/7A9bOXuwEhnc8xvJP+bwf
         ZTCTfgbxK0dky2LLXdIFCokglFKYQs8Kf0vRlc4VnKV3AkYXvrUCB5JOZ7A+8fyhM3QA
         nPHhG/znMmcHF39Oy/zs7cPoW/Ub3+sop00vy1TSa5DklW4Y4Qy7fP3oF6ps+8fQ+eiR
         Ip+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=+Tzevj0aBFVFkJCWK4eLpOvzUlkBo2BfRqQfZEvwMvs=;
        b=Ng+dWwwlPEGps++gQphuLd/2kqYINERWP4LJiLnN02Y0rWGWkjXG9mSM7HRZvJRfbm
         cyGuIpOl8zU/m/I1UtHUql/W2hPtzOjDfI4D1VAGDI2RV+o+tioW7txUcwxBqlpY071y
         Fz0XI77uDnrm7+/RqqPHC9GytBE6nYfCbT78bq+aPrpHAa1MEcFSZq9mAv1kZE71xv1W
         bdDOzyX+VNYOQY38gFcBl95Pn1ZHNSta3CHJSy7pTllRzFnk0KR8AU5/vJTiFg2dlxNm
         n7oPFa3x9ns/ICdnfMreij/iza/6WVXMK4OphTeQHPrQRuopsg/GOQ9ePZnRnZxJdy3v
         iGWA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Pcm1ooQR;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w4sor14743687pfi.67.2019.05.27.16.33.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 May 2019 16:33:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Pcm1ooQR;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=+Tzevj0aBFVFkJCWK4eLpOvzUlkBo2BfRqQfZEvwMvs=;
        b=Pcm1ooQR7nJPiwEsinFV/L6nU72jYejpbNC7QlSuOh8Pr/Z7jHPUQy9LUaDpG3ZZiM
         +y0KLQUxNoHblKkmwGb+K2LT3jNmHSweUA8KOn53jFvOagl8BB01uHMmr4Urgm7G7kzD
         i9oE0PzDFV3dp3p4jzFvhv08fTGoOAyudo4yFzXQ/AYO1FA/npUwnQLAk0eTJe8aRySd
         xpHXTeOT1+LNS9vzNUHPyk3kEzHbL8xv+pWQfDUV7yC6yNTdtI7zVh6xRdi56muGJLNV
         vrxlxGW79TUzoRd+V1xYEHmU+3m+Re5rThIDKwi1R9C/6KzcnUuFWJPjFMXqnM9HA3Tt
         aC1Q==
X-Google-Smtp-Source: APXvYqw64MwbF8rBzoFZuNCZfbyzEPvHcK3q4MMq9vzVc16EWSgge+/RGsYDd+RrqQ/wO+LlCjxZUw==
X-Received: by 2002:a62:d41c:: with SMTP id a28mr40306175pfh.31.1558999993555;
        Mon, 27 May 2019 16:33:13 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id n2sm10802478pgp.27.2019.05.27.16.33.09
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 27 May 2019 16:33:12 -0700 (PDT)
Date: Tue, 28 May 2019 08:33:06 +0900
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
Message-ID: <20190527233306.GE6879@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-6-minchan@kernel.org>
 <20190521153113.GA2235@redhat.com>
 <20190527074300.GA6879@google.com>
 <20190527151201.GB8961@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527151201.GB8961@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 27, 2019 at 05:12:02PM +0200, Oleg Nesterov wrote:
> On 05/27, Minchan Kim wrote:
> >
> > > another problem is that pid_task(pid) can return a zombie leader, in this case
> > > mm_access() will fail while it shouldn't.
> >
> > I'm sorry. I didn't notice that. However, I couldn't understand your point.
> > Why do you think mm_access shouldn't fail even though pid_task returns
> > a zombie leader?
> 
> The leader can exit (call sys_exit(), not sys_exit_group()), this won't affect
> other threads. In this case the process is still alive even if the leader thread
> is zombie. That is why we have find_lock_task_mm().

Thanks for clarification, Oleg. Then, Let me have a further question.

It means process_vm_readv, move_pages have same problem too because find_task_by_vpid
can return a zomebie leader and next line checks for mm_struct validation makes a
failure. My understand is correct? If so, we need to fix all places.

