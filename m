Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE03FC74A54
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:27:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E4722177B
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:27:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="vYqpYvpe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E4722177B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 034268E00DD; Thu, 11 Jul 2019 10:27:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F010D8E00DB; Thu, 11 Jul 2019 10:27:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC6AD8E00DD; Thu, 11 Jul 2019 10:27:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8BD5E8E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:27:39 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id r4so2696014wrt.13
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:27:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=kgSCqCMgkzHP3NI7bApdCQ2mgMy1VndTbhMfuP51VMY=;
        b=ALlUvjeB0LEaG+dqI9O8W6ITFhAaDGkXJI/99xBghyKLhCVDtaZqJpTm84ScXVlNYi
         44+UUdTQVrQpnJXDckU3TqC0LfcIyawTmP1SLV5kl4OMU8PIwNUyHhEzK1GXC5E1vHcr
         2iBXWbZuuISdI51y6HqP48Kqdo491Vit9iF8LlRWzy0og54boN4Vm/ZZewNBJjlJOEn/
         uPX49xxCStkr75x7VA0w0I7yRkRlSv4ATnPnuMHctx+0OWj7JZdfN73E14uycVZivRal
         DTyO9YPzJr33Rp5S6n5FjznBjUTyvHdgp0e4nLqjYOl6v3RzZemhPkWttnmFqJjMU/h1
         DDmQ==
X-Gm-Message-State: APjAAAXV/yElaXMt1i+vC15vGsk/vkEd12JM4y2sgtqPWboD4n1I6ONz
	Mosc1YhFdhwgdx/tB7w2WL+vAMRIpqkTtRCmgRd0ih7Q7M1CBl8kuqLrheJ3N5KX46EhJqPy6RD
	LuDUElXMcTZIHRFVswtYJCZpGK21a/VJATRd8dqHsd2s35ZJZjz4G42D1drum3GK7lw==
X-Received: by 2002:a5d:518f:: with SMTP id k15mr5424550wrv.321.1562855259161;
        Thu, 11 Jul 2019 07:27:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqythNp3bfXIrxpC8so2udSR+1+Em/PSBTGHhLvXS9z7z8LbFUOW7g0dHjC5ueJY+12vrzaR
X-Received: by 2002:a5d:518f:: with SMTP id k15mr5424479wrv.321.1562855258185;
        Thu, 11 Jul 2019 07:27:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562855258; cv=none;
        d=google.com; s=arc-20160816;
        b=BL95I3qn2X0Y7P/Dv2Xj6s2Mm6UbXGVyAFaLz3aVXmclX8oVvHApt1H7qyFzJRGOcv
         PkalPgg7Xy+TwZlHTYG5gW1JUz5uiDREpwc4KpKDWwIIp4cCCvc7DAqEW6s5fwr4Ummu
         k/G3GHcxSYPICNGWfA9HnKaupiYtHpKPnqbVAtevIeEOYhXqEFHheDo/AUpi4MYCZMXq
         fqgaGfBBd8va/i665x8qmi4hKZfvQ+NIR5nfrY+0krZ/J70/aSLPescasKPxOfZW9wR2
         550ablJ5+72u6v2A2M0zMzvxeYflGRIg7TRoNQuNU4u3ETfNmm+IV1qasS24yJjoeZDx
         xmVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=kgSCqCMgkzHP3NI7bApdCQ2mgMy1VndTbhMfuP51VMY=;
        b=nKV+GUN9hISEkXXNJxy/F9hpxhFweDliwenpKQ0UzO8F7unZMI5TRJ82uzculA5z5t
         5wTcaUy8YgxqW5TKwJZhMzAQ8xrNXtGAxJHpPjYgdYOGIA0AKjA9HMdtbsGZWRdJiOSF
         GerkA3379sQBYj1PvVsEwuandYMMO8lcjNR65LtT6jGGILdwihGk790Baj7TBR5KyiGW
         h/kZNKAsONxle90SRG67xwgfEzOZahWES2j4UOmwxE5pY4XaDbnhAsgPgEtyO6i96nAN
         LnjFXUXKPGeSISFM8vp6Dr2ymKZGXFgZHJFAdKiBf4N8l2K+qD7UpeF1L7p9K95WkL1k
         m2Bg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=vYqpYvpe;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id l15si3227694wrm.327.2019.07.11.07.27.38
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 11 Jul 2019 07:27:38 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=vYqpYvpe;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Transfer-Encoding:
	Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=kgSCqCMgkzHP3NI7bApdCQ2mgMy1VndTbhMfuP51VMY=; b=vYqpYvpe4pu04ng6B0A06A2Ebt
	IEotIWqUDGlLiIeJXs3STCRzutaBfRE8kMERKV9c7ZRD5PB+jVgbutrHwHhFQdoFSNubb17mq05ay
	pILpcnf6sG5BKWFktgHStubOK9UqnnoPCyptfIMcsrCDcCoV/zaZdI6rh/UVSFFCapTpb0LStSgYV
	XEAUQnYOyieF5R42wT7u2kL17EUSlkCjtyvlmXvQQsct3CXPyDLrc3Cixv/gAoOluBL6Y/OSSpg9A
	iqvrC7IKzdy209HkI4yhcxi7UtnvQ5PpTa86x0CyyEahVMeohTVHZCpUSg97S19SCOjj4iR+cjY8o
	1+fQ8g6g==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hla2n-0003zh-2O; Thu, 11 Jul 2019 14:27:33 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id D714220213042; Thu, 11 Jul 2019 16:27:28 +0200 (CEST)
Date: Thu, 11 Jul 2019 16:27:28 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: =?utf-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, mcgrof@kernel.org, keescook@chromium.org,
	linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
	Mel Gorman <mgorman@suse.de>, riel@surriel.com
Subject: Re: [PATCH 4/4] numa: introduce numa cling feature
Message-ID: <20190711142728.GF3402@hirez.programming.kicks-ass.net>
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
 <9a440936-1e5d-d3bb-c795-ef6f9839a021@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <9a440936-1e5d-d3bb-c795-ef6f9839a021@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 03, 2019 at 11:34:16AM +0800, 王贇 wrote:
> Although we paid so many effort to settle down task on a particular
> node, there are still chances for a task to leave it's preferred
> node, that is by wakeup, numa swap migrations or load balance.
> 
> When we are using cpu cgroup in share way, since all the workloads
> see all the cpus, it could be really bad especially when there
> are too many fast wakeup, although now we can numa group the tasks,
> they won't really stay on the same node, for example we have numa
> group ng_A, ng_B, ng_C, ng_D, it's very likely result as:
> 
> 	CPU Usage:
> 		Node 0		Node 1
> 		ng_A(600%)	ng_A(400%)
> 		ng_B(400%)	ng_B(600%)
> 		ng_C(400%)	ng_C(600%)
> 		ng_D(600%)	ng_D(400%)
> 
> 	Memory Ratio:
> 		Node 0		Node 1
> 		ng_A(60%)	ng_A(40%)
> 		ng_B(40%)	ng_B(60%)
> 		ng_C(40%)	ng_C(60%)
> 		ng_D(60%)	ng_D(40%)
> 
> Locality won't be too bad but far from the best situation, we want
> a numa group to settle down thoroughly on a particular node, with
> every thing balanced.
> 
> Thus we introduce the numa cling, which try to prevent tasks leaving
> the preferred node on wakeup fast path.


> @@ -6195,6 +6447,13 @@ static int select_idle_sibling(struct task_struct *p, int prev, int target)
>  	if ((unsigned)i < nr_cpumask_bits)
>  		return i;
> 
> +	/*
> +	 * Failed to find an idle cpu, wake affine may want to pull but
> +	 * try stay on prev-cpu when the task cling to it.
> +	 */
> +	if (task_numa_cling(p, cpu_to_node(prev), cpu_to_node(target)))
> +		return prev;
> +
>  	return target;
>  }

Select idle sibling should never cross node boundaries and is thus the
entirely wrong place to fix anything.

