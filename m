Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7C78C04AB6
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 02:40:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87B7C216FD
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 02:40:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87B7C216FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 290E16B026A; Tue, 28 May 2019 22:40:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 219A66B026B; Tue, 28 May 2019 22:40:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BAD76B0271; Tue, 28 May 2019 22:40:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id D53A46B026A
	for <linux-mm@kvack.org>; Tue, 28 May 2019 22:40:46 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id r191so640308pgr.23
        for <linux-mm@kvack.org>; Tue, 28 May 2019 19:40:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:thread-topic
         :content-transfer-encoding;
        bh=mELf59eIMtv+XXa24hwV+Ijol6dakbtV/AwrZkgdfNA=;
        b=HdzDnr7IlwlH9enIiHSQIN91Fq8rWWm55iP8H1fZvEzhgPzn39XBx2jVH4bziq6PbL
         sRnKHnRMO8khYJY7ZTiQ07S1NFbK6/DnpwWuj/xztAVf+ZtPN64sXg+hgB0WgidBLJBK
         43d8/9mgARkNO4g6NaDANrIHhhCBjtx+1NLqMWhA8Pa6rRTIUfJemNw/MpfsgnpA2JM0
         PNFYPBwrBB+7jJu/tRZWJ9d0LmD3sdrz/BgV5bt+J1WrJLg/h53FfV0OS8PNdV3IiHCl
         H66CQiQE0iAvYz6yVxjINRyeehYU2bEIjE0Hf3ff9m1sLs+RInANkwtuB0aMBeio6F0u
         51dw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.162 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAU9ngIKKdJiwnrgnCh8PbpRZ9epjG/bFqrNhPgtDzU5W1JO2XUu
	t85Ie+//OG4xKZXCjsK1LEs4i3jt96ERwRSUXOQzwtJQNPQ//QbXUgCN1xNXnwh4VqETGGAnDOt
	lKbWR+NJDpT/RwDN644VmGNSGCYHQLJzEk1ITn7lpbl3gUFPuQQToWRXIAaIlrcf09Q==
X-Received: by 2002:a17:902:8c8f:: with SMTP id t15mr82942434plo.87.1559097646555;
        Tue, 28 May 2019 19:40:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz58vV3crueAa12Ll65CJe1WQ8XZ5X2BLHx4btC3m2a/mIyZNeh+kqcytm4pPSxUCtkOTju
X-Received: by 2002:a17:902:8c8f:: with SMTP id t15mr82942368plo.87.1559097645386;
        Tue, 28 May 2019 19:40:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559097645; cv=none;
        d=google.com; s=arc-20160816;
        b=UVwBnJyhF/GUKK3a3H1CuuMAn3r305zoMbhhMiAQJKHtzyZ4VC9oeiqb5QtNPc76UK
         nt24DeOawHGpNMPS/WqaCeXktjBcHXhIuslQ8c4hUTfJerUCn1hS1v6/djTr1Auqvkhq
         WiJxe8b1CM5Z+BIftNnFPAG/0KTOkw0yEhiYkOURH/CPfC6kGWQ4jfZmHsJe50fuaegE
         z16+HQYX+en7WMaohXgFM2dJOkF5/K8DMUwU8Rfcd/kpPpnEaaiYQtcP3S2TRWZeRx/5
         vmaNoe6L+jLaC4DAvJ2pvLfu0yJrnLeGHbtWcEzxsWjo1sAqnNbduvqG4XO7Lg8SKk/+
         e3hg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:thread-topic:mime-version:message-id:date
         :subject:cc:to:from;
        bh=mELf59eIMtv+XXa24hwV+Ijol6dakbtV/AwrZkgdfNA=;
        b=oFpOBzSodLaYYTUwyaRZJMVZMeThwnH/gFiyWdVv1IQTAJTwhN80w5/zqFQIcaaq5A
         wquS0OmshrhEKV11/66fn9dvn1FZzvtUwfUGVWdWCAa/Z56YLd/mq5BlS2yLg4QxIK8B
         vo2QK6IZmzimhD9bAWNFRviyupPZM+ci3Dy8VjMiATqo8jL5AArg+d52K40150y7VMb9
         kLdX0fI4plZQPqzlTlsdSyAyv/zFvvKrG7ZVaf5n8qiUowKBpofINSL/+CTGoggOYN+e
         8bnuOdRoJ3jczQMivuOWPHWSYBLHsPiTeXpPMNiDVBpfW+VByHEnxDRhkj3CoHgtbeBo
         nLrg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.162 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail3-162.sinamail.sina.com.cn (mail3-162.sinamail.sina.com.cn. [202.108.3.162])
        by mx.google.com with SMTP id p14si22641693plq.318.2019.05.28.19.40.44
        for <linux-mm@kvack.org>;
        Tue, 28 May 2019 19:40:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.162 as permitted sender) client-ip=202.108.3.162;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.162 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([123.112.52.157])
	by sina.com with ESMTP
	id 5CEDF129000029D9; Wed, 29 May 2019 10:40:43 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 580316394929
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
Date: Wed, 29 May 2019 10:40:33 +0800
Message-Id: <20190529024033.13500-1-hdanton@sina.com>
MIME-Version: 1.0
Thread-Topic: Re: [RFC 1/7] mm: introduce MADV_COOL
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 29 May 2019 00:11:15 +0800 Michal Hocko wrote:
> On Tue 28-05-19 23:38:11, Hillf Danton wrote:
> > 
> > In short, I prefer to skip IO mapping since any kind of address range
> > can be expected from userspace, and it may probably cover an IO mapping.
> > And things can get out of control, if we reclaim some IO pages while
> > underlying device is trying to fill data into any of them, for instance.
> 
> What do you mean by IO pages why what is the actual problem?
> 
Io pages are the backing-store pages of a mapping whose vm_flags has
VM_IO set, and the comment in mm/memory.c says:
        /*
         * Physically remapped pages are special. Tell the
         * rest of the world about it:
         *   VM_IO tells people not to look at these pages
         *      (accesses can have side effects).

BR
Hillf

