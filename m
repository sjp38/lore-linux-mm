Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F034C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 09:46:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BED3120843
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 09:46:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="VhCDJgQB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BED3120843
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 619E66B0007; Tue, 23 Apr 2019 05:46:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A2A16B0008; Tue, 23 Apr 2019 05:46:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 492806B000A; Tue, 23 Apr 2019 05:46:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 286886B0007
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 05:46:23 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id s1so15065191itl.1
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 02:46:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=ZDorSYmy5pifOTHN5/R3ArDCdlVxn3mnwyoVkmNtAtk=;
        b=ACRKv+bkj1rDPAmdQNNyuVZdeq4st4Uz61Y8MT5L+FoC4vxEYobCM5ZYqpu4onZdTL
         8wvkTbeDaNUmdfbNU6OzG1YZBRvpW8AugM+MUTSZ5OVOr9NIYSUzP8nimxNFheRYrVCV
         ojU2W4CyfP3DHPj8QL6PrQuLigc7v1/liDcmdpkpY+IUuaCG5I8y9D5rZvfAfhxgyUJd
         bOh3PVQLJWBXZZ6vLXdTQ7PjaUOeii+bi8oKY392Ns0dOUmfa6UInJrCPVbDHGvX8Va+
         uGsKOUPlynePTxiNh/1V4Q+o9Sr1qI6aE+ldtUIEqcHYaHSxDNXDSsPIqpO9jUDA9Eng
         HfOQ==
X-Gm-Message-State: APjAAAW8eOnLGifNIcgdor75IeEd3t8N6SIBUKCeKtbdDZCJBq2BpVYr
	iy3nCbyOlHhkrt5gAPZw/Ev6HxS8lQ64FqHiOyB8t3C4O+19JEawNcXCif8ZVnzLY/lQcuqLG5Z
	XDdWhkBlHNGbgvGcIqUP6J9LjGhRFwUpZOFhF9d2EZL6cOAfVBlcVfHbfM56fC2YtaA==
X-Received: by 2002:a24:56d1:: with SMTP id o200mr1390651itb.111.1556012782925;
        Tue, 23 Apr 2019 02:46:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhrYxjPbYY97yNZ3IElU94o9D55wR6Eny7YmnuZpiJbF5D71aUhLorVmrP5C/dJZ3MYKoi
X-Received: by 2002:a24:56d1:: with SMTP id o200mr1390632itb.111.1556012782420;
        Tue, 23 Apr 2019 02:46:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556012782; cv=none;
        d=google.com; s=arc-20160816;
        b=zwXkg2ip+cCALiYY9zVEW0qdmCV4ESSTX5ewxgdfFfGPnKFr3BGbwqSFGKI3CvcFxc
         v44XJfajVYPBoGD0Ks9Hn/CDwvg2by8bTRZV5E5oo+PVtdb/A4+/lxx3sLf5yS7gjv13
         1KD0uNN9V21Zm6LVFrFBStPQktFtjyU0k9uoQWw4+7juVQvTJ6uRXru/Dq3rohAkUrow
         WkNpRuBQSCb/RkS/10Bq8YkWvY6lG909SKWveXK23u2X7AaZOMZCiuyYjFR9QQrB8ktR
         ohGVvtQXdzY2Zw3RNGkxQE7F2ZPg6AucvypCtEOt4IWRVHeaZum5Fbr+SZtECPuT4Y92
         fgGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=ZDorSYmy5pifOTHN5/R3ArDCdlVxn3mnwyoVkmNtAtk=;
        b=IXeXPBqnPopcMiKoZYrm4xKnzljN+nseKbl6KLcpchXy/7tHm6NxbOraoBEc8vPUkh
         m/Nn45f95YueBsxzhGLL2Svq+VXp1ysXxmJrFvwjuaXTffM8rwBwrHlpyOv60ea7ICiv
         5JxUiZ+L8wjL6eqBeswFkR5AermBXCYBKHXkBetFmcdezix5NQpHTbqt5jWDtYsIONWv
         EgQc0a9GoKMTVqaqT8zuraqWnWLCRafq9knAGUUJ/2kstfWfcAuwSuR1aHqvdvx1ujPb
         b2mqGh9tIH/CERj6E7VkHgEcqGH4x0kX4jzcwkJceZM6mE+pLmVQBDPFJLJJziKOMe5w
         +DbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=VhCDJgQB;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id y139si9850204itb.94.2019.04.23.02.46.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 02:46:22 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=VhCDJgQB;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Transfer-Encoding:
	Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=ZDorSYmy5pifOTHN5/R3ArDCdlVxn3mnwyoVkmNtAtk=; b=VhCDJgQBiA236vNR4anmbsAMXL
	iKoz13puLU3Kc/59ZTI7P9DnUr9OHwD93GcjQh9E7uYv8wbd0wqaokjsOKy3vOOuUWmExvfTYAbT4
	6vxpv6oPbmJ21DxtsSrcmPKLRZ+y7jBBaEhdJPeNSTbWD7z3aGOkwcyI8YRXdoapScIPbHdU/XXEk
	1BPrb0+kAYTfnvJKEgbWV7hV6BLNeWCzHqaMdOcf7P761H3Csf+VD39hheTQ8GDXFNYbmlUOSPHsN
	9Yx2NlSnYMVNsvSH6uieX/wAQBElNwObTUe5sQtnAyblmtpOfYK9NmQrAXyf3V9d89q84UF0RfFou
	9hsFg8pQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hIs07-0001ze-Rv; Tue, 23 Apr 2019 09:46:08 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 75A5A29BB5057; Tue, 23 Apr 2019 11:46:06 +0200 (CEST)
Date: Tue, 23 Apr 2019 11:46:06 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: =?utf-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [RFC PATCH 1/5] numa: introduce per-cgroup numa balancing
 locality, statistic
Message-ID: <20190423094606.GK11158@hirez.programming.kicks-ass.net>
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <c0ec8861-2387-e73b-e450-2d636557a3dd@linux.alibaba.com>
 <20190423084722.GD11158@hirez.programming.kicks-ass.net>
 <b1a3aebf-e699-23ce-b7b8-06b6155f3dbe@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <b1a3aebf-e699-23ce-b7b8-06b6155f3dbe@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 05:33:25PM +0800, 王贇 wrote:
> 
> 
> On 2019/4/23 下午4:47, Peter Zijlstra wrote:
> > On Mon, Apr 22, 2019 at 10:11:24AM +0800, 王贇 wrote:
> >> +	p->numa_faults_locality[mem_node == numa_node_id() ? 4 : 3] += pages;
> > 
> > Possibly: 3 + !!(mem_node = numa_node_id()), generates better code.
> 
> Sounds good~ will apply in next version.

Well, check code gen first, of course.

