Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 099CDC761A8
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 23:25:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C37EB227BF
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 23:25:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="MmKZKEj9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C37EB227BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B2416B0005; Tue, 23 Jul 2019 19:25:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 364146B0006; Tue, 23 Jul 2019 19:25:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 22B318E0002; Tue, 23 Jul 2019 19:25:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id DDBCD6B0005
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 19:25:05 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id g2so5713800pgj.2
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 16:25:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mail-followup-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ocYhdcO3SU6GlO5SMsDd4UneO2+NmP0HUtqWfePl8kM=;
        b=Gc5LztQASGpswEfTrN1sT/tR3yw6050lfZ3PXmbCHHT+1iN/oLHOmDaSo3LF+ePvJC
         32/veWU+kOxAZIiq2zcTmVlwih4gJsxiabyW1AFPwOQwo403Zn8QDGuWq9pX/A1rQGQh
         qe8NEJBX2GJICaepRXVZqD2OtZ8LEikKqNvO/u50t2HAaFkdDFCEizu6BiXNFGemTdQz
         Vt3XFKcLtze4ztHPqLymNM6ewmAHREbg9l8tnyH1rtLARgw3pXfdXH6hHmb1fJ0BXoQJ
         FBEmhNK09IqpJzIGIRdCnyRsQiCf5b2OSIFmUQZUkukWpQXjxDGHaj/R9uCk2Cwy5qxg
         1LIw==
X-Gm-Message-State: APjAAAV0Etgd3ir6kXKnj7zBjVNsSwjdv/sC16t0ZecfAO/b6ec490fS
	ndcku1t9gNiJG4s1OddYakQiG4e8X+hqlBqDUNfAWqLQ7ActXotMnbBQ2RzqOLyeA035Nx421zF
	rJlfntj5e3MNMIiNIc/IKQi0e9et7ksHKw+d+Ax4L/9a+KY9tg033OOCkWxwpJF4pnA==
X-Received: by 2002:aa7:9819:: with SMTP id e25mr7905248pfl.47.1563924305435;
        Tue, 23 Jul 2019 16:25:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPBwW4HXSVVHh9BOy/yVD/VabjXR2aK6WPa8ig7kQd+T/Qpm2tVdFfX2/ZyOQal/mKJeIC
X-Received: by 2002:aa7:9819:: with SMTP id e25mr7905211pfl.47.1563924304710;
        Tue, 23 Jul 2019 16:25:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563924304; cv=none;
        d=google.com; s=arc-20160816;
        b=bOM0fZz1iQQDokEiTRQDYCXrSPlAKaZDsbPEzWZjORFFOKKZfSrm26h3Ji6ZXQoDdY
         8Dm+1FvbY0o/A8vBMzmVpZap+KTgUmMj9WKrXiDGlK8sKLJWFgcVxqeZsJTs2zIDfqux
         FR+l/gZK7qkHxiFTmLz2LtvS/4152JtxC5XYI62q6fYTh06OR8emhuXtGvzb92874LDU
         I+Dhdg3Oltywbm+BA0CEYby8AqhrEw9ngvUQ0YWEEvSVBrUvjM4RoIJRVStitBhRePaE
         h+Ce2N7Kzj+gZwr/g6eOIr1HmqA5FFbpFsIDXCPcE9y0rs8C8I3qLl9BSg90XBSnxb/z
         MDHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:message-id:subject:cc:to:from:date:dkim-signature;
        bh=ocYhdcO3SU6GlO5SMsDd4UneO2+NmP0HUtqWfePl8kM=;
        b=TUkVL9bu8DOT0vdeoxnC7RtnPc8MgsEPH2d6Dznh23aTMlFEAn74by+zf1QShpyDYq
         6ji8LtV3OyUC8BCQyR2nxuIGpW4MdJOF0td0NnTvQVO8TNYvzzUIHWjvrpeIoglBvwup
         ELnnaxe0OIhwqtIkef/Q4Fj7dmBCJ+3jLr1eZLQVlVx5AAdA6tLf05NANzbP1YTNc3nv
         eKgqu6Axazfd0j2RIeJWxuKQIgzwedeIYJMkAvGgYZT+hfuyfFCaYrMKIhFEK/x/I83L
         F6E3xQT2kJSvxgDI0YyAo+31qT4Z68Z0d1Z6Oyaa3p79Ch875FuGERWhe/sYF2FRb76e
         BGUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=MmKZKEj9;
       spf=pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=ebiggers@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t15si15494906pjr.46.2019.07.23.16.25.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 16:25:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=MmKZKEj9;
       spf=pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=ebiggers@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from gmail.com (unknown [104.132.1.77])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CE1AB2253D;
	Tue, 23 Jul 2019 23:25:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563924304;
	bh=FGNG2bsI180IX9yfVVejxvvKc6LPkLx7d3W+nSaEtYY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=MmKZKEj9rYYuSx5IhPuVqW3yDLIXTJo+2Pjo8kn2rXJQRI0BajWjrOke5jXiV/Myq
	 KkhnD1MWfZQbxAaTDQvQWLNNBmhF1dZIuAcp4Ha09rkCKnFHgdoOJB121myzkHrs7P
	 Yd0vHiCvZb0zZO+CZbS9JAzOgO2NtIXCSPxE+R/o=
Date: Tue, 23 Jul 2019 16:25:02 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: syzbot <syzbot+5134cdf021c4ed5aaa5f@syzkaller.appspotmail.com>,
	catalin.marinas@arm.com, davem@davemloft.net, dvyukov@google.com,
	jack@suse.com, kirill.shutemov@linux.intel.com, koct9i@gmail.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-rdma@vger.kernel.org, neilb@suse.de, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com, ross.zwisler@linux.intel.com,
	santosh.shilimkar@oracle.com, syzkaller-bugs@googlegroups.com,
	torvalds@linux-foundation.org, willy@linux.intel.com
Subject: Re: memory leak in rds_send_probe
Message-ID: <20190723232500.GA71043@gmail.com>
Mail-Followup-To: Andrew Morton <akpm@linux-foundation.org>,
	syzbot <syzbot+5134cdf021c4ed5aaa5f@syzkaller.appspotmail.com>,
	catalin.marinas@arm.com, davem@davemloft.net, dvyukov@google.com,
	jack@suse.com, kirill.shutemov@linux.intel.com, koct9i@gmail.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-rdma@vger.kernel.org, neilb@suse.de, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com, ross.zwisler@linux.intel.com,
	santosh.shilimkar@oracle.com, syzkaller-bugs@googlegroups.com,
	torvalds@linux-foundation.org, willy@linux.intel.com
References: <000000000000ad1dfe058e5b89ab@google.com>
 <00000000000034c84a058e608d45@google.com>
 <20190723152336.29ed51551d8c9600bb316b52@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190723152336.29ed51551d8c9600bb316b52@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 03:23:36PM -0700, Andrew Morton wrote:
> On Tue, 23 Jul 2019 15:17:00 -0700 syzbot <syzbot+5134cdf021c4ed5aaa5f@syzkaller.appspotmail.com> wrote:
> 
> > syzbot has bisected this bug to:
> > 
> > commit af49a63e101eb62376cc1d6bd25b97eb8c691d54
> > Author: Matthew Wilcox <willy@linux.intel.com>
> > Date:   Sat May 21 00:03:33 2016 +0000
> > 
> >      radix-tree: change naming conventions in radix_tree_shrink
> > 
> > bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=176528c8600000
> > start commit:   c6dd78fc Merge branch 'x86-urgent-for-linus' of git://git...
> > git tree:       upstream
> > final crash:    https://syzkaller.appspot.com/x/report.txt?x=14e528c8600000
> > console output: https://syzkaller.appspot.com/x/log.txt?x=10e528c8600000
> > kernel config:  https://syzkaller.appspot.com/x/.config?x=8de7d700ea5ac607
> > dashboard link: https://syzkaller.appspot.com/bug?extid=5134cdf021c4ed5aaa5f
> > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=145df0c8600000
> > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=170001f4600000
> > 
> > Reported-by: syzbot+5134cdf021c4ed5aaa5f@syzkaller.appspotmail.com
> > Fixes: af49a63e101e ("radix-tree: change naming conventions in  
> > radix_tree_shrink")
> > 
> > For information about bisection process see: https://goo.gl/tpsmEJ#bisection
> 
> That's rather hard to believe.  af49a63e101eb6237 simply renames a
> couple of local variables.
> 

It's been known for months (basically ever since bisection was added) that about
50% of syzbot bisection results are obviously incorrect, often a commit selected
at random.  Unfortunately, the people actually funded to work on syzbot
apparently don't consider fixing this to be high priority issue, so we have to
live with it for now.  Or until someone volunteers to fix it themselves; source
is at https://github.com/google/syzkaller.

So for now, please don't waste much time on bisection results that look wonky.

But please do pay attention to any bisection results in reminders I've been
sending like "Reminder: 10 open syzbot bugs in foo subsystem", since I've
manually reviewed those to exclude the obviously wrong results...

- Eric

