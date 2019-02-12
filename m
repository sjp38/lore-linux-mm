Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61D04C282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:08:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E998217FA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:08:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="tmPMzeR5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E998217FA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 951B28E0004; Tue, 12 Feb 2019 11:08:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 900A08E0001; Tue, 12 Feb 2019 11:08:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F2338E0004; Tue, 12 Feb 2019 11:08:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4F8E18E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 11:08:38 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id v131so1974066ywb.19
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:08:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=25s6ZzpZBvcdHA9iUQ1peThatSnI2TBHe3HYkjmpXe0=;
        b=pLwePdikbmSrovH9juFUE/fyDBjN5FDJmn8J1cBrS8viVjTk7rmwZniZG2SFfeCgDj
         7gYE/K4ftmhv0X3vo4fELYVGS6uMAEicyhM5GOs6YDF5vs69yZ/VASIDFCAWVSknBwwX
         5kBqJC7APa/1ToCslqFyB7n56bCNu18wYoKj5HhWBtwEl9ddR79k+FXtkqr8/mHWOtMC
         CaGxWVPzWRKdQz0EcXp8DvCSlKlCDWoQarTV/Jy3oJ4u+KuH6tJoeQAsKczhPndat8gG
         YErcqh7ncZ2mNvYsf+7CSSs/OR+psGcYStBu4bItKrJ0pAxx6zrxasvnqjkdqspl+bM6
         Qtdg==
X-Gm-Message-State: AHQUAuax0xDONzoKQbAj8LsQjXOuCD8nJa/TcIsg6HyxLjuSIyxLePkC
	v8AUUe6H3eX5idqxyvZDpC/bIUHRt6RrYtDsCheg1ryIzCgHZGioaCjuTReC2kiYoElFCYGFSYh
	bgE1NHwUgn8gi2nxk8noai57+RY7CU18xsKHsf2OC3LzpIzwmmD4sc5wTGZ/BTXh19OkX157Sel
	nb8Cr7wY1bxNXa+O0Wpms5up3gYktwsQskIMZb7fyNQhQ3qyzNmbtp30XHI/9jJYWVXBCbO+rnj
	TrBFFB1FggFsQJyx0CHzGopc1HkkoEPzFJttmlfLsvH4zwQrL9K5rzRy3yr5klrgNJzNVHiLgXM
	HWwoppqIs9s0h+cMs1n5BAlzwOkhAhLGaTiFyoe+KWJz2MHwrWBa78Aeh/5e1vDaU7qG+6M+4z4
	a
X-Received: by 2002:a81:a9ca:: with SMTP id g193mr697879ywh.52.1549987717943;
        Tue, 12 Feb 2019 08:08:37 -0800 (PST)
X-Received: by 2002:a81:a9ca:: with SMTP id g193mr697810ywh.52.1549987717216;
        Tue, 12 Feb 2019 08:08:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549987717; cv=none;
        d=google.com; s=arc-20160816;
        b=kTgpuamIEPC0594XbRChwOa8KtdRageoWHwIXSmdCZfML91BmibyvcTWPM/P6gmmGq
         oRlxdq5CS0nN7fWhzkp+BlRJDUHiFvayW/AWXNWfM4aBj5T2+nD7oGqbV5MX1ai1z6XB
         +/538RgfAiFx/xy9aNRbC6AtYOLs2yvqyQEJd+1XwAJU4II7hYhZS86M8NsODaZtABPt
         gjpmDzhShMwNuQ+dFImtWIFxLEpcqIAPy8hW4z2334Nq0o9Xf1XtbMGXNiIFNNlR4SW4
         nie+Bxjm6ehIYQl+xfrHF1hkSqx5Cm/yGdFg+FPucGttv4/b8Mzg0VFGb8iugekJeHEb
         ZWnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=25s6ZzpZBvcdHA9iUQ1peThatSnI2TBHe3HYkjmpXe0=;
        b=DSsJJ94MahdWNJBsRiFu9iJ3njiDktzcHo4FOYUclnO6W5wwTdElZmoPkQqr3rrK7k
         1LEh1cm3CoNkCjuEXDMK9AxWduBGzqnCjccdq9Ani642V7C6jUociIZu2wfShRCPPH4z
         02wSnDVtQvhgf1ITFt/+zrTJGMbnXD+VkutHVldXS/u+dhIwFsj58/0l4sbNpr5Orbx5
         AHbXmVadhJGy3PyKpPYZMslHzh3Ss7Mp/vwvwPRAGpjuJn6cjxwZTBlYsmxTqMJ1ntlu
         znrNVfFBMWsD8/YEAkcML9IL3Tz5jYYH8MSE/D1jfbncwee3tUa0lgwNOpW1iHI63R72
         ZKxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=tmPMzeR5;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 206sor1751901ywi.61.2019.02.12.08.08.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 08:08:35 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=tmPMzeR5;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=25s6ZzpZBvcdHA9iUQ1peThatSnI2TBHe3HYkjmpXe0=;
        b=tmPMzeR5aNZd2v/KezfkXsfcEtRhX0m2PsZ9JjbgFgY4LQZw+t96OPzWv93Aofc0gd
         zGqfDwR3lKpwbqviQ5bLjsJlC5PcacEYfsxRcYXCt/J368b/xmGd/8jVT8TF54feRZv6
         dB/qomR9zsAogwAaE/QaKxihmDPc9fyuoypeSfxz6Qb9reiSC0CZadM7o1a0Uy52Q4XE
         rXPQYgDv1OWEVDNDr3u2aisXLMEhZTYl0KNN9kp1ySgRyxZkDgl9hS9Gx+EWj4YqUCTK
         +uaiYapXarW8+FUqyqQdDbvbooF02ADtwASSBowC4E4ad1IcBngSDe71j/ncajjU38WO
         jD9A==
X-Google-Smtp-Source: AHgI3Iar1Fw4cjlPFNp8NTALnE9GYU54kXPdqThc74HyaWjuSGDpvOQijVQSKBMX40Xk85wN8su1Lg==
X-Received: by 2002:a81:1690:: with SMTP id 138mr684794yww.276.1549987714740;
        Tue, 12 Feb 2019 08:08:34 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::4:41f4])
        by smtp.gmail.com with ESMTPSA id s7sm5004150ywe.20.2019.02.12.08.08.33
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Feb 2019 08:08:33 -0800 (PST)
Date: Tue, 12 Feb 2019 11:08:32 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	David Rientjes <rientjes@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Yong-Taek Lee <ytk.lee@samsung.com>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] proc, oom: do not report alien mms when setting
 oom_score_adj
Message-ID: <20190212160832.GB14231@cmpxchg.org>
References: <20190212102129.26288-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212102129.26288-1-mhocko@kernel.org>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 11:21:29AM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Tetsuo has reported that creating a thousands of processes sharing MM
> without SIGHAND (aka alien threads) and setting
> /proc/<pid>/oom_score_adj will swamp the kernel log and takes ages [1]
> to finish. This is especially worrisome that all that printing is done
> under RCU lock and this can potentially trigger RCU stall or softlockup
> detector.
> 
> The primary reason for the printk was to catch potential users who might
> depend on the behavior prior to 44a70adec910 ("mm, oom_adj: make sure
> processes sharing mm have same view of oom_score_adj") but after more
> than 2 years without a single report I guess it is safe to simply remove
> the printk altogether.
> 
> The next step should be moving oom_score_adj over to the mm struct and
> remove all the tasks crawling as suggested by [2]
> 
> [1] http://lkml.kernel.org/r/97fce864-6f75-bca5-14bc-12c9f890e740@i-love.sakura.ne.jp
> [2] http://lkml.kernel.org/r/20190117155159.GA4087@dhcp22.suse.cz
> Reported-by: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

