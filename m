Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38A26C04AB3
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 03:41:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5CAC21721
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 03:41:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5CAC21721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20D906B026A; Tue, 28 May 2019 23:41:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 195636B026B; Tue, 28 May 2019 23:41:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 087E36B026C; Tue, 28 May 2019 23:41:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id DDBF76B026A
	for <linux-mm@kvack.org>; Tue, 28 May 2019 23:41:44 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id s18so711075itl.7
        for <linux-mm@kvack.org>; Tue, 28 May 2019 20:41:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version:sender
         :precedence:list-id:archived-at:list-archive:list-post
         :content-transfer-encoding;
        bh=UjIQeXhkvn85mrWtlkur08PgzBnvE93HsXhxpMce0tI=;
        b=tFQb5UbhLJa1u9VL2GvS2K/lS4IkBdzK32D/NdgJb+oEyx0WPRlkcSQFbf/XyoVrGP
         EygSH/1L+rLHzIkeKbDf57a/ipDOuKKXShKjKpLaMQkeqdUvurH7MZiSzYaPjPuItgCa
         KdEv7/N63awkucYA9wEEzEYb7mGf0PzjUKgXMuYZYmmY+9kyz4MEBpyeUDrv3rPqMbN0
         UvyLxySstCdY6jTIFcnYhLepa87+YTuVPwayB1UMHY6aeYqedataqbMi9pd9f3cePm+E
         Yp6sydGdMz4zLQp3KuI5mfHN9Md0pNExHGudf2EFVdYaLp9eoW3M35vlBgYA1zNfCPGV
         9tMg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.166 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAUZD2o2KV9G2zuJJEP8acFhbjIGWbyUyOTILkwyQZPTKrDeiDHO
	u5asjMWsDjbSuJQ4TQkwp/iQM8s8LY0OhjqjEH6bxZsOfrjquKQ/0jQBgOWNsKUkIcF6Ci2bVrD
	DtR8OmOpfjakMEBL+1/j9zi1Gnb/Zdxs7OCIgfdYtwtlwWVHkXNjxgW8ywYk7Arp3NQ==
X-Received: by 2002:a05:660c:4:: with SMTP id q4mr5514914itj.30.1559101304589;
        Tue, 28 May 2019 20:41:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxiqjai8XsrK5f0kzOgm3f4LvNq3nopkDNLsG1h1iYDJhtB5sh4rMQ8f0tfEsHgG5/W86Wk
X-Received: by 2002:a05:660c:4:: with SMTP id q4mr5514875itj.30.1559101303292;
        Tue, 28 May 2019 20:41:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559101303; cv=none;
        d=google.com; s=arc-20160816;
        b=KINeqNGEkbjYlI35nOOqEwmElX+tSLvt/gMHb7eAA2ZGyDWi91gsA3TFAHzZLZhEpm
         XeZt5UvorYH35Zn1eS8lkdG/wY4R6Oeg8mCS102rqlWAAWB7sE3TWp5ZNOuxFqKZgPKL
         CzhRvobfTL4zaGeX8OJN5SlSRI3uqOux2PRY0UV+8CXRHc8Ad9Vz2T7+LOCCiN8NQI3r
         mnJQ2Q/N37QRTfGirohN3NOtGp1uoca8MggAgEaakj8Dkle1TO30BUsF0ZAq+jU6EYpM
         GamqVwLaEDZ1EsgrcP5OM/H20hLAQpvGiF3Z85IifSYr+ixy0xGLYRjaZTX5EJkf6Xq+
         4OHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:list-post:list-archive:archived-at
         :list-id:precedence:sender:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=UjIQeXhkvn85mrWtlkur08PgzBnvE93HsXhxpMce0tI=;
        b=dczruCWWwqy1u91Lyaj2maYNMnXUiA0344pBGGhBx1qDngYcOSlkqwJUyPosGAJQTO
         DLyYZMfmLZJ9Wlxmu+Kv8Yappy3REr15UijwnItyEoRXMVdEHOrZNC6WcJ5N77iYplL/
         MeHrFtBjCMV0e8LtqGxmGwJhS0ZX4Er3Yc3MfCIAcoLeILV1vVT6WIJszw1y6lqr3NTx
         7/TradjQHgVu3sW/1rTaIqiFrEp7xx5KCy2VFY+pRhXWg8oBBl38bfwqup/9LI4SIPNa
         AtG69UCCmf57PZiVJ6uS3nIzn8x0s1ESeyRurRrSkKVy3ig36lNTW69v49zij1R6AXEm
         fjCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.166 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail3-166.sinamail.sina.com.cn (mail3-166.sinamail.sina.com.cn. [202.108.3.166])
        by mx.google.com with SMTP id o140si673676ito.31.2019.05.28.20.41.42
        for <linux-mm@kvack.org>;
        Tue, 28 May 2019 20:41:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.166 as permitted sender) client-ip=202.108.3.166;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.166 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([123.112.52.157])
	by sina.com with ESMTP
	id 5CEDFF6B00000B5F; Wed, 29 May 2019 11:41:33 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 883528396263
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
Subject: Re: [RFC 5/7] mm: introduce external memory hinting API
Date: Wed, 29 May 2019 11:41:23 +0800
Message-Id: <20190520035254.57579-6-minchan@kernel.org>
In-Reply-To: <20190520035254.57579-1-minchan@kernel.org>
References: <20190520035254.57579-1-minchan@kernel.org>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
MIME-Version: 1.0
List-ID: <linux-kernel.vger.kernel.org>
X-Mailing-List: linux-kernel@vger.kernel.org
Archived-At: <https://lore.kernel.org/lkml/20190520035254.57579-6-minchan@kernel.org/>
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190529034123.Ydws0HZGButPCKc2uBNRJHio08XPB3nB1CUeGF-D3fs@z>


On Mon, 20 May 2019 12:52:52 +0900 Minchan Kim wrote:
> --- a/arch/x86/entry/syscalls/syscall_64.tbl
> +++ b/arch/x86/entry/syscalls/syscall_64.tbl
> @@ -355,6 +355,7 @@
>  425	common	io_uring_setup		__x64_sys_io_uring_setup
>  426	common	io_uring_enter		__x64_sys_io_uring_enter
>  427	common	io_uring_register	__x64_sys_io_uring_register
> +428	common	process_madvise		__x64_sys_process_madvise
>  
Much better if something similar is added for arm64.

>  #
>  # x32-specific system call numbers start at 512 to avoid cache impact
> --- a/include/uapi/asm-generic/unistd.h
> +++ b/include/uapi/asm-generic/unistd.h
> @@ -832,6 +832,8 @@ __SYSCALL(__NR_io_uring_setup, sys_io_uring_setup)
>  __SYSCALL(__NR_io_uring_enter, sys_io_uring_enter)
>  #define __NR_io_uring_register 427
>  __SYSCALL(__NR_io_uring_register, sys_io_uring_register)
> +#define __NR_process_madvise 428
> +__SYSCALL(__NR_process_madvise, sys_process_madvise)
>  
>  #undef __NR_syscalls
>  #define __NR_syscalls 428

Seems __NR_syscalls needs to increment by one.

BR
Hillf

