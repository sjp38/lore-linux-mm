Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE8E7C31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 01:45:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 915982084B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 01:45:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="yNs5c0Qr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 915982084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0BD228E0005; Mon, 17 Jun 2019 21:45:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 06DE08E0001; Mon, 17 Jun 2019 21:45:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E9F748E0005; Mon, 17 Jun 2019 21:45:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id ACF9A8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 21:45:50 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e16so8886874pga.4
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 18:45:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=v94EC3Ly9N8znMaUvo6aI0M5YUCyspTmqnqky3coBh8=;
        b=tUE6TFaF505gjuVBikFmLlWOP/+fUGeWFwFCsbO3ioyT1A+9wPuvQr6HEwK5McBNow
         xkOxkT9dA/BtZvk2ZpTBJQHcX1wXANcnZ1G9XH0wI9nHLGF679pcl2bXVh3XClWGvoJc
         KXGKa2Ouj1qAwf6qpD/u3f1uNS6rxEg3+iIsIc7aPlEbLpQRurwn7ClVxapwPk2K9aR7
         fQSRvWNhUZ9V/G2MKfTJjyxIx0gd8csf739JYo5PFFyZCigSCuKSlIYoQbf0yZHZgYYS
         dqNwW6DYWSc11GpO5T8ZHNgRdC7AO47UcWwzuIWJNHP8WUc5T9eg5wo+twe6kQP+DwoZ
         0P4w==
X-Gm-Message-State: APjAAAVYir92r92VKd9riuV6X5nKYWIV2bpyYJCQuaOYs1bRT9UxQ9Fj
	BOmvHU9JtM1fQG1owuNaGnkHVo8+zwK3+938eLG4S6jhSPGVqclMYOS7WDbXxiclRnQOLEV6RXD
	cDoLyodi4i8t9wuPWA87lM5ioGgSkkMwv6wYKDGt7adW44d2J3A97zS9GNthWjAq52g==
X-Received: by 2002:a17:902:8ec3:: with SMTP id x3mr24311747plo.313.1560822350360;
        Mon, 17 Jun 2019 18:45:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxeTdFCNgCf0f/4N6PDhuLm++xdJfHfLh6XpcxUk5xXeqHB/e9eZ6EVLFAVER1lHee/YRBu
X-Received: by 2002:a17:902:8ec3:: with SMTP id x3mr24311706plo.313.1560822349734;
        Mon, 17 Jun 2019 18:45:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560822349; cv=none;
        d=google.com; s=arc-20160816;
        b=oy2+VKs331dKPs7wdVlyaODC8HRRvkOgJ6PcTZ7qIV5OeWqn/jXlYCElUDhZb8DqTH
         TDbrJAb8NMyo6neaJAitYAvBGyXTL5O6WldJTyM4vC4xlXBsCjyw72pUUw6+9uVU9HzW
         u8ZsC/z1iQcIl9cTyesW0/WVhyZpoAW/1tbocIOIaWcl140oKo+olZavzvKgfi6DktfG
         AUvH4QAqj6zIlw1mV4bkgdH9lrUSZXFllsGV9Nizqh0GU6o+yElGUASp4z/xVsLfn49G
         xlE75y6KsH1RGgBqODXC7+lSEN4N7X63S1PCVDrTrn2Q/tG1/94Jq93hDvphyvKB51A0
         88hg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=v94EC3Ly9N8znMaUvo6aI0M5YUCyspTmqnqky3coBh8=;
        b=GDKLsh3JQ/23yDtvvoaoJuqnBRYJKszOmj1e3ZW4ZOnrf8BvnoWK0KPFWO51Hdd3CH
         I3KeNFf2D4/CumymUFfyd/2KBwJnVi7HTfggghKIdFI9HSwclgVzLXZGkKs3iaSYo6cj
         AX8WGQtsQM7Fmpn81NFK54W8jep+HhbBqmGZVZhzy+VR4jzy/RX9YsPguzwbXgw/nfvA
         vJRXBOUTLWU8c4XcUi2WH3/LAiM+wK7GDTBmAEM3nn9kuph+ZtfeFeDAw7zOIChL7BWI
         QNG149smerONExLyL6Acrbcqoc/mNJGzQ5+zst0JsIkLIdtsLdimzfA5KefaN3Ic6Uzm
         mlEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=yNs5c0Qr;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y6si12303910pgv.210.2019.06.17.18.45.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 18:45:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=yNs5c0Qr;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 606D22082C;
	Tue, 18 Jun 2019 01:45:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560822349;
	bh=oSzNYEyekhj/NlwHW0X2pXMLHkV8SDK6JssH3xf5sKg=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=yNs5c0QrkZ+OIgygnIUxK1vdNmaCS4P0DJmYxw82YOS8uUEUaNn7eElyjXdJTD7e6
	 AfBWK397l1VTwpLOKs0GssDSAozZx2a+g3IrfRp4gA0WGzszrWdzhMeqc4VaY4cRJc
	 ay+PycslEeYEG8Qr0sSGPmcGs7WwRl+eZQ6k8OdY=
Date: Mon, 17 Jun 2019 18:45:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Michal Hocko
 <mhocko@kernel.org>, syzbot
 <syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com>,
 "Eric W. Biederman" <ebiederm@xmission.com>, Roman Gushchin <guro@fb.com>,
 Johannes Weiner <hannes@cmpxchg.org>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse
 <jglisse@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM
 <linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
 yuzhoujian@didichuxing.com
Subject: Re: general protection fault in oom_unkillable_task
Message-Id: <20190617184547.5b81f7df81af46e86441ba8c@linux-foundation.org>
In-Reply-To: <CALvZod5VPLVEwRzy83+wT=aA8vsrUkvoJJZvmQxyv4YbXvrQWw@mail.gmail.com>
References: <0000000000004143a5058b526503@google.com>
	<CALvZod72=KuBZkSd0ey5orJFGFpwx462XY=cZvO3NOXC0MogFw@mail.gmail.com>
	<20190615134955.GA28441@dhcp22.suse.cz>
	<CALvZod4hT39PfGt9Ohj+g77om5=G0coHK=+G1=GKcm-PowkXsw@mail.gmail.com>
	<5bb1fe5d-f0e1-678b-4f64-82c8d5d81f61@i-love.sakura.ne.jp>
	<CALvZod4etSv9Hv4UD=E6D7U4vyjCqhxQgq61AoTUCd+VubofFg@mail.gmail.com>
	<791594c6-45a3-d78a-70b5-901aa580ed9f@i-love.sakura.ne.jp>
	<840fa9f1-07e2-e206-2fc0-725392f96baf@i-love.sakura.ne.jp>
	<c763afc8-f0ae-756a-56a7-395f625b95fc@i-love.sakura.ne.jp>
	<CALvZod5VPLVEwRzy83+wT=aA8vsrUkvoJJZvmQxyv4YbXvrQWw@mail.gmail.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 17 Jun 2019 06:23:07 -0700 Shakeel Butt <shakeelb@google.com> wrote:

> > Here is a patch to use CSS_TASK_ITER_PROCS.
> >
> > From 415e52cf55bc4ad931e4f005421b827f0b02693d Mon Sep 17 00:00:00 2001
> > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Date: Mon, 17 Jun 2019 00:09:38 +0900
> > Subject: [PATCH] mm: memcontrol: Use CSS_TASK_ITER_PROCS at mem_cgroup_scan_tasks().
> >
> > Since commit c03cd7738a83b137 ("cgroup: Include dying leaders with live
> > threads in PROCS iterations") corrected how CSS_TASK_ITER_PROCS works,
> > mem_cgroup_scan_tasks() can use CSS_TASK_ITER_PROCS in order to check
> > only one thread from each thread group.
> >
> > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> 
> Reviewed-by: Shakeel Butt <shakeelb@google.com>
> 
> Why not add the reproducer in the commit message?

That would be nice.

More nice would be, as always, a descriptoin of the user-visible impact
of the patch.

As I understand it, it's just a bit of a cleanup against current
mainline but without this patch in place, Shakeel's "mm, oom: refactor
dump_tasks for memcg OOMs" will cause kernel crashes.  Correct?

