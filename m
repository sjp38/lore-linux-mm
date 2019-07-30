Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 079CEC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 18:05:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C17272089E
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 18:05:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C17272089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6FB6A8E0005; Tue, 30 Jul 2019 14:05:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6AC108E0001; Tue, 30 Jul 2019 14:05:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59B5D8E0005; Tue, 30 Jul 2019 14:05:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 253048E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 14:05:51 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s21so35751343plr.2
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 11:05:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=v/E9LJNGoi4BcOEdPZ8kvnuUmdY5WNiLSbl2ggsYh+0=;
        b=eUMRzDIgYGfxCew/aRCD31Yg+XTGn6GRVsbn7+wUwRJPWlMDBhAYZ8kB0bofkO7WTr
         aT/4CmvTokpsOmJsdp2lHBBC/XWbBIFWzGmH0fnlcSef5KgOz0QkQRcDh1Yn8kTn3tsV
         1+kYuG2cPTI2wcZy0S0oZz9VyGLrW5fUAUzCyG5bTp/HNm8WBkpiZzb65Danx8Y8b2ti
         uC2+Q9khdo4v8Cd/gI4bVjMKBuwhce/uYYjTmg835XAFH300n0XPCkD2DKkTbDnv1Bcr
         ix1ku/ycOHWdVHf8GCGEFeSctyy3oxMzRMC3C4Ej/l+jvUad432kQ5H7Cq77ZJqF/esp
         pKYA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAUxyqy9k5BiPGJu3iDC3Q3mtvG15QKiEdyhkntYTBAYN5j2FZrW
	yxUFjSLsSa/cnU6at9DGYPcfQO6VAWKlhVOx+1KHXf3LKcVJcs3a9NohM/b103dAzl5BKJyYwDJ
	c5sfCnxgkkr2gF90RjgEb48iPi+s6ffDD0bq570XgXHthJHj7F5NyviC12UoSycE2rQ==
X-Received: by 2002:a17:90a:d998:: with SMTP id d24mr90633767pjv.89.1564509950853;
        Tue, 30 Jul 2019 11:05:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyn6QdfxGrvspV9rqKH4lUNfu0QsqQAZXoRKnlGm3nphahMVQXHBKIm/ihsUQvjWFzWFjLo
X-Received: by 2002:a17:90a:d998:: with SMTP id d24mr90633732pjv.89.1564509950240;
        Tue, 30 Jul 2019 11:05:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564509950; cv=none;
        d=google.com; s=arc-20160816;
        b=mLfBcQK1D8GcY5Etz9FWHLjNtxAUmm15Hb74cBV0vm6M2lBVRdPYB1a7Fq+GkjfPoN
         XBSgHaEyB3DM7OQ0HFIwpL3erSudcwUWHba/nrPYVd9SWv/HzfTs3tkwv03aq2FxkKY5
         yeGUZZG43S5fKmrtba2rjfsfG1gbyOtaLgqtlsxCzdT1meNr/I0aIjw0hmex2p39UxiB
         zPTt4SfNJ/IY6N8bgcv00L7QGntG4mM0a4T9QF7CZc5crAI42GpcC0nQDQIPwym6OLBW
         qrHJlNu4ncfMTc5PI/2iE4CNx0kFmistynL+scmda2QcJVk132n/QXQu7AZZPc1fWGGV
         zqCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=v/E9LJNGoi4BcOEdPZ8kvnuUmdY5WNiLSbl2ggsYh+0=;
        b=lRe7spf1LKu6carS9XlXx40eXJ8HDtEfIBsKydPDulN/M3ZdBi09P81gjqGazBMhAE
         gtRV+qYtx5JJHmq4mRhmwxp66Htd+bBhkOSfBQGGax8ENE2o8Sq3CNrQUSj+V08D9Tjq
         Gb5wBYDQIoNSMRwKZ4pIfpkB6ct+MjzF428X1tFSHocc5w43mj+nHunuXCGbeA8rnu3i
         AQD0FDhizv1ElOfBmQ5Ygo/n6aHJOJS2I0jFx0tkLXE5rJRfeJhdrF0NVRVPOCjcdi7y
         jJKiQ3Cu3VcNhMVV6zVpZ9BWfU/tO4I36QWWYr4/Stk/pmKlRjydfkzdkGYOY4/YnHEh
         dg4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y8si30448429pgr.89.2019.07.30.11.05.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 11:05:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from X1 (216.sub-174-222-135.myvzw.com [174.222.135.216])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id E68D5310E;
	Tue, 30 Jul 2019 18:05:46 +0000 (UTC)
Date: Tue, 30 Jul 2019 11:05:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>,
 Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>,
 Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG
 <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] Revert
 "mm, thp: restore node-local hugepage allocations"
Message-Id: <20190730110544.84d91ba80365cf35f5aae291@linux-foundation.org>
In-Reply-To: <20190730131127.GT9330@dhcp22.suse.cz>
References: <20190503223146.2312-1-aarcange@redhat.com>
	<20190503223146.2312-3-aarcange@redhat.com>
	<alpine.DEB.2.21.1905151304190.203145@chino.kir.corp.google.com>
	<20190520153621.GL18914@techsingularity.net>
	<alpine.DEB.2.21.1905201018480.96074@chino.kir.corp.google.com>
	<20190523175737.2fb5b997df85b5d117092b5b@linux-foundation.org>
	<20190730131127.GT9330@dhcp22.suse.cz>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Jul 2019 15:11:27 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> On Thu 23-05-19 17:57:37, Andrew Morton wrote:
> [...]
> > It does appear to me that this patch does more good than harm for the
> > totality of kernel users, so I'm inclined to push it through and to try
> > to talk Linus out of reverting it again.  
> 
> What is the status here?

I doesn't seem that the mooted alternatives will be happening any time
soon,

I would like a version of this patch which has a changelog which fully
describes our reasons for reapplying the reverted revert.  At this
time, *someone* is going to have to carry a private patch.  It's best
that the version which suits the larger number of users be the one
which we carry in mainline.

I'll add a cc:stable to this revert.

