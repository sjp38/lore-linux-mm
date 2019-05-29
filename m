Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 591E2C28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 04:36:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 042FD21721
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 04:36:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 042FD21721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 936A16B026E; Wed, 29 May 2019 00:36:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E7DC6B0271; Wed, 29 May 2019 00:36:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D5F56B0272; Wed, 29 May 2019 00:36:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 517776B026E
	for <linux-mm@kvack.org>; Wed, 29 May 2019 00:36:44 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id bb9so725693plb.2
        for <linux-mm@kvack.org>; Tue, 28 May 2019 21:36:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version:sender
         :precedence:list-id:archived-at:list-archive:list-post
         :content-transfer-encoding;
        bh=WcXCR0OuZ7dOG6IKLRLbHDfybaQe9gCYatVl+1THdlg=;
        b=m6rVaD3874furcfgDZC+vCj9XN9fZGd098oObDVfiNcz/kIGXsXojsaC77OydWj1Mi
         bLj9T9STqwEKxZwzmjSMD9KWHflSSptgfeuk2LbI5wWhC3O/ytJPa9zIrMYvEeohyU35
         fJDMcOlW+n3lp48JZr0+0olUzdLrht5HbxzMvoYJNTN6VvLaoXJGyLcS9oyJcRlFkX8B
         0xQd9jDSBypqmvXgAO4w3O+MB0m5ly/LUJe8wlCS91s+UY4X8V+b1UkQ9OhBxNlqMQ07
         7Bv+9V91w2kQ/Y6RygtZjqPnVMFRwtT6dvGakCR1z0i7RbhyAzEpawyL7JLf6fUgUKCY
         fwkA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.162 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAWgnj0lxjFUOvOXyhhFuhv0R0wduHN1d8NDkhziWPpSJ/XeNuFK
	VDUP3MZfekPDbhuXrT5tq7yTbcS8/4/AHmhLl99RRwqsi2wOsi2nIc9YXKV7wy3pPKKfKejZlXz
	sINIVHMvMQZGOi8K0/Mv5Y06rXJefFM7gu2l1pgNLVfAJaWkVR8kpSuq38ADGaF9D6Q==
X-Received: by 2002:aa7:9e9a:: with SMTP id p26mr114767446pfq.176.1559104604026;
        Tue, 28 May 2019 21:36:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzXilayjzMrmIYbqhI/PH37mPj6LIS+sJtEeSgoSl42uJ9a0Roc/BNPV/yls8NsPHNizcti
X-Received: by 2002:aa7:9e9a:: with SMTP id p26mr114767408pfq.176.1559104603274;
        Tue, 28 May 2019 21:36:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559104603; cv=none;
        d=google.com; s=arc-20160816;
        b=0ynxb3rA8X+z7oplzg1QxSqQwx03V2IfgQtqmsHAk4FR3dng0zw4r3tC0MRvNIPrCI
         XlE7EazeqGuwAJEXrlWU+zwMWjAaOg6jWqxMvRJRNc70oVKLOG1KfDyOSqb7Ri+ejiUE
         qJD1c3xYIOMzR1hYCocjtZG+woVevpF3A//ZWJVqUNdhR2nIWGdj8qChaptIcPmE5uTm
         /4wHPUrRqSAesAuSZdIgNX0W9xi/PivPdq4bazktTrxNTXaI+c5tl4iWz7zbRBhnB0UW
         g22Dmm3Sl3jPS83bIfHm0fsEXUUptkba+ev7cZEPA/VAtz8StygwLSaHu5yjA3nADVtt
         nyhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:list-post:list-archive:archived-at
         :list-id:precedence:sender:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=WcXCR0OuZ7dOG6IKLRLbHDfybaQe9gCYatVl+1THdlg=;
        b=LxCtxx1Aegc9TAptv0rv7GtzWWabBNKqElny49D7qWilEQskTqTr2BMAf8YR6KjPqe
         8VQt9MY3SQbz6DvDgEXwJj0vlcblkpEs+2nrDq3hnU0hwu48RLlerWVBtxX8WRnRSvZu
         jPtUItvdzah0ruP0+mTe3cPrrNexryi+npsg7M0iznEK+vjaP5B9PpUUpJXqJYTNrdpo
         ufoOZrMA0oEmmuanbLwxmvAs3bkhgTh9cP1JqqwfLq0snob6HXLxYbJWYCITez8o48Nq
         3ky6hGXVcXeQ8wX05drtXWgufk+c3NHzCczO23QoicBu6JWYPT1jwmXdFP/Pvt09Vv/Y
         eSlw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.162 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail3-162.sinamail.sina.com.cn (mail3-162.sinamail.sina.com.cn. [202.108.3.162])
        by mx.google.com with SMTP id l96si20519775plb.115.2019.05.28.21.36.42
        for <linux-mm@kvack.org>;
        Tue, 28 May 2019 21:36:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.162 as permitted sender) client-ip=202.108.3.162;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.162 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([123.112.52.157])
	by sina.com with ESMTP
	id 5CEE0C4500006C74; Wed, 29 May 2019 12:36:39 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 87217397293
From: Hillf Danton <hdanton@sina.com>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>,
	Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 7/7] mm: madvise support MADV_ANONYMOUS_FILTER and MADV_FILE_FILTER
Date: Wed, 29 May 2019 12:36:04 +0800
Message-Id: <20190520035254.57579-8-minchan@kernel.org>
In-Reply-To: <20190520035254.57579-1-minchan@kernel.org>
References: <20190520035254.57579-1-minchan@kernel.org>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
MIME-Version: 1.0
List-ID: <linux-kernel.vger.kernel.org>
X-Mailing-List: linux-kernel@vger.kernel.org
Archived-At: <https://lore.kernel.org/lkml/20190520035254.57579-8-minchan@kernel.org/>
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190529043604.nRVP92CIzdPrMHnDptXKYYyHgsm8Qhx9t-6jFVSU99Y@z>


On Mon, 20 May 2019 12:52:54 +0900 Minchan Kim wrote:
> 
> With that, user could call a process_madvise syscall simply with a entire
> range(0x0 - 0xFFFFFFFFFFFFFFFF) but either of MADV_ANONYMOUS_FILTER and
> MADV_FILE_FILTER so there is no need to call the syscall range by range.
> 
Cool.

Look forward to seeing the non-RFC delivery.

BR
Hillf

