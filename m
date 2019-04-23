Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED9D1C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 08:46:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADE0020685
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 08:46:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ZxwEBBsC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADE0020685
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3613A6B0003; Tue, 23 Apr 2019 04:46:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 30E746B0006; Tue, 23 Apr 2019 04:46:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B2D06B0007; Tue, 23 Apr 2019 04:46:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id EEF656B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 04:46:39 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id e126so12492720ioa.8
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 01:46:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=mDLdgtTp5gy52ijm7HK8Ps+IDdAF+jR+CvS+usFlua4=;
        b=MEANNq5LHHWlobW1bMMGmV27NiB7LKZGtk1oUJEqISDj5b7cbV7aXVxUvOw+gmuBVy
         ARMcf3P0iPCxIfKTSzvx20dV+Al4vOJ0mBLL3QA2W/6ENQJlBGCTejPm8gSXxxYm0STR
         gJV6o0rhTaf5RIroZIb9UXN0UuRQfVeh766SqIjBsLaga9ErIDVLWePCOqvxPXULBs41
         7d/lfXurgz3pNOROvqb5NekOlpCe80TFelP8tgW8IV4Q6JKZ2jc2dtvQzHe3/GqpsC9G
         G4IWER0ILFDkplfoj+cezZmCSFALmt873QahV9NtyfqgH+EW2yYusiil1JnHTcHxfidv
         nfNQ==
X-Gm-Message-State: APjAAAVu4SVkY3+ocX7suQf/TxtPTlWH1exuVjXihiIzPZVFnCHOAasP
	w4M797W4J3RmN3mdw0N7x3aR0LKHcpqYxg/2zrC34aLVlE1ukP3mkZ8Kk6NZESlzRAs4DhCRJMv
	8yYE9FqYWvZqmVUfZ7vZV4XMkfb27MmcbSRwHqWSRFtjEtYxncXOeFLyaW7PDBwDddw==
X-Received: by 2002:a5e:c742:: with SMTP id g2mr16105278iop.56.1556009199772;
        Tue, 23 Apr 2019 01:46:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwA7TGjyXsSjo8XwZPDIoy8a2E3XZEGjuRVswUVO8eTyQyFDxK21WF3Xmsq0JgzBAzPNPT0
X-Received: by 2002:a5e:c742:: with SMTP id g2mr16105258iop.56.1556009199225;
        Tue, 23 Apr 2019 01:46:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556009199; cv=none;
        d=google.com; s=arc-20160816;
        b=Vh1GqwRp9lO2jjg2W1RSXTl5bIBwo/XhTK8iehP03Wk33Dg9ivU/VTU7Ft0S957Atv
         +ilx9VQhiiYAiYAA5pMKVWFbVdZWpNECreb2kgRvQWqEAvDvO+SooS6ndJv/1MDjXUtR
         Ey+YAkBQor9m8hUwadyLVJKGy1ZbhhYVY/370I8wIAW5QWbRMAac4YmVVNDTR+PeMd1R
         we655ONBvv89sulKUmA/vuQjWyJ7nvO+8TdwlNgbD/WthXCoK8q5zRMXvf1Y1snpdIi6
         6TpnkSMxPa10Jz0yDongRI/alMckcgwF7n2MuTQu5iAxZWDyUzcIrJCbUgvPEqjpQcY2
         GMXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=mDLdgtTp5gy52ijm7HK8Ps+IDdAF+jR+CvS+usFlua4=;
        b=fivWmTpfVcBp0mDtqw3UhRjfUbvrtgImMSNYvVTW3ZFBh1/Cdowk4SHGZOObaouXzi
         lw+VbkIvttreRJC170qrV5RXUgVhYTFTZqPTQquBlMbLj3NswGt/NyWiZ/u+rre+XwfL
         OcIbbNBRIiMgk9XA/3/nlConqLGV74gw1c5iSWndZBC6FkkShpgD2bIoyAZEmFD1WmTC
         B8b0GhMjNijc2vP6uc83TgYbdrW4kykMS92G3EqFagynt8UShUpWZ2C3jRALGHLk6W4Z
         dhJjYCzcPIqO0frE8o+puIdnkB/lwzDl4t6b4CfHZ3EYsyb0ZskVhheHnVRg/ADzJhJM
         4R9A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=ZxwEBBsC;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 18si808936itv.46.2019.04.23.01.46.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 01:46:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=ZxwEBBsC;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Transfer-Encoding:
	Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=mDLdgtTp5gy52ijm7HK8Ps+IDdAF+jR+CvS+usFlua4=; b=ZxwEBBsC1roM8wjsBn78JtKjte
	gYs9e79GmF/LS6zKy1lPKog7ssg2+nX7vX7n8HLh9XJvCjQD/4fhOEt/6TI6wcIrzLhzO4XeuTpFl
	JvZG4b85yAM4Eff/4uVPqSqTzhopVjvK8ZEGMBC+WOFRAGt/F+qbSHYl0itm5jgBKhLWaJj8S5lpj
	f9HLbBf/k7j104SPRnDX467cqSB30XB2glms8cz1a/gOn6v0CLH4a/X8f6DXMlVXFtfRz2JWzfGWf
	0tBh9ZJ4wulDV+Y2NRtlcJ5tCZhVtVnaBrUcSgqKepkDeiKz1y/jjwW8US1lmybnX4ZAnP0Q5Wntt
	cKns57BA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hIr4V-0001Ef-4F; Tue, 23 Apr 2019 08:46:35 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id DBEB329B47DC8; Tue, 23 Apr 2019 10:46:33 +0200 (CEST)
Date: Tue, 23 Apr 2019 10:46:33 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: =?utf-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [RFC PATCH 1/5] numa: introduce per-cgroup numa balancing
 locality, statistic
Message-ID: <20190423084633.GC11158@hirez.programming.kicks-ass.net>
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <c0ec8861-2387-e73b-e450-2d636557a3dd@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <c0ec8861-2387-e73b-e450-2d636557a3dd@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 22, 2019 at 10:11:24AM +0800, 王贇 wrote:
> +	 * 0 -- remote faults
> +	 * 1 -- local faults
> +	 * 2 -- page migration failure
> +	 * 3 -- remote page accessing after page migration
> +	 * 4 -- local page accessing after page migration

> @@ -2387,6 +2388,11 @@ void task_numa_fault(int last_cpupid, int mem_node, int pages, int flags)
>  		memset(p->numa_faults_locality, 0, sizeof(p->numa_faults_locality));
>  	}
> 
> +	p->numa_faults_locality[mem_node == numa_node_id() ? 4 : 3] += pages;
> +
> +	if (mem_node == NUMA_NO_NODE)
> +		return;

I'm confused on the meaning of 3 & 4. It says 'after page migration' but
'every' access if after 'a' migration. But even more confusingly, you
even account it if we know the page has never been migrated.

So what are you really counting?

