Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40CDEC10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 09:05:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E41BE21773
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 09:05:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="JzQhZaX9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E41BE21773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 835806B000D; Tue, 23 Apr 2019 05:05:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E4E26B000E; Tue, 23 Apr 2019 05:05:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D4BB6B0010; Tue, 23 Apr 2019 05:05:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3236C6B000D
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 05:05:10 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id r13so9692336pga.13
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 02:05:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=6VqXzTqzV4erjPSVPtVl2zQZ4ymXP6yRhCiCP3xmNmw=;
        b=rfkhOhP36nIvBjmd8cgBkU95XrQMO69nrgG5OtqGL9qFH5oxGABjMRn/5Lw9ghA1qB
         7JY+W3iciBGHaLLj/BbuQb/mvRB8R9N8KHNNyG4BOzCP5pKg5Q5ZTpfsAYfLXhJHbwVe
         QpvY3y6y4Hzso7195q4rrVqR5cdv+vZ63Qicx+dueB788+K3xS022IzGQ1FWVXYZM7NU
         dfvlcbiWGkNfBSvC/Fyg8aWNzyWdvyZwcodefVONYgf6x1/YwSk5KzLJiz8Os4q7rree
         618UpwmVy0GmES892VQ6ItjUOGz+PEsuzsclAnpQaPSqFP1DXW6i0ZQQMG+PuKeNKTfu
         rANQ==
X-Gm-Message-State: APjAAAXdszhAVJ1/m1VDBQNYIRE7Qpgrfs4iCAL5RcP/Q2OlfDoleheE
	TyCi+nU5K6jsgUu4U/cPg1NJQ1mfU0uaWcMMHj37A93OKm6ocNWH9f/LtAkkYoJ0IadHe1t0L0p
	jEvsj809Pe21jgzd0RPZ+gwBnGBR7nzUsoQj+EyGSHagtaWVZuBkLkS3gYOpjJz9hxw==
X-Received: by 2002:a62:62c3:: with SMTP id w186mr24954054pfb.73.1556010309752;
        Tue, 23 Apr 2019 02:05:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxVxORilvkDPWX9VEs9glucFwZ6ZZ916lKGtOAaGm6QlwXfeM8IqyV108upauVaRgEPQu4f
X-Received: by 2002:a62:62c3:: with SMTP id w186mr24953998pfb.73.1556010308994;
        Tue, 23 Apr 2019 02:05:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556010308; cv=none;
        d=google.com; s=arc-20160816;
        b=zf6JnCHWHSOo5tBj0paP7u7GMnFHY4swgdA+A1dv8hIkP1wq18ZqtOgkYrPVtunFc3
         HXYuRkFOlR1YmgV6SMx48nYszs81FJIpLEsOlS3brQRAs7hL8kWGllbFO4o32cT0mCXD
         JJ9moJm37cTrOVnYpkqVG9oQtfVY168Y0TLddPDfY4CZGnekaid+aeO9QLeaE5wc4Gtk
         uSp1nrRa8GLlNApjR33853RKJByslNtjtF8WjInkD/2joZqBqshAL5QZd06H38b/z1TQ
         TQRaXhVehs4DLNDC24tNhEN4UmVJoV5k84nYpHkq6ZY9Q+57FHnd8XLRBVGWFHuk7QNu
         MxFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=6VqXzTqzV4erjPSVPtVl2zQZ4ymXP6yRhCiCP3xmNmw=;
        b=Yqyes2zOTt9+aDdb0rjoFzrkxnZQy1lEgOte9lgh6m1ulcCCjRnFYUG3mgA03D7pvW
         7eHgSyyX5uryjdflkT7jqM3yXrUcjFI5nfhG+UAmCeb9tT/jCmvbUR33KO7kHFLlvHds
         3csfq6zOuORm+tluiGd1fy+HiBrsYAm09teoR2rKRbqLKYJdzMbslLNFIaGpc7DeC/KY
         dGGM9RhOTSS0vrW+uEjBo3rW7HM+9kuNdaW1UartC7mC/v5QfX0VOSYnWhp4KDKrXBUI
         HpXjvJo+jybzGwXZ+sz3nMg1ythec82ZtUVIyOIaj3sqZNRJVNXeWBC36uPt61WYNi2c
         1gdw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=JzQhZaX9;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b68si15937281plb.351.2019.04.23.02.05.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 02:05:08 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=JzQhZaX9;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=6VqXzTqzV4erjPSVPtVl2zQZ4ymXP6yRhCiCP3xmNmw=; b=JzQhZaX9wCR1O+q7wBnsYM6n0U
	V+FN/qJvVRDX/PdLVZhm0qsNatmpcnHcFuJ0sI9VMTSmVZiTDfFnQ/IalvfBTnz7WzD3W0/B3tTsS
	QpXw6XhiPzEw+nCaurIJhIoBvm2yg4Yptl8hMg0tWToYZQOOKLZ7EkwMnq7ZVqIo8wt3XxN4Ajh4f
	NjWysATDqv1dQ6ZV6VfP7HRwy4cr3txcBpY2O08fb3MncEICV/9yvPwSa6BYci7Zil6Uaw/tvBexY
	obgQhKwzPrTCW5m6f6dB4BvPaGA//4enbwbat3m+hpZZbnEFFQWVuUFyqoVwSLZpBD/HUvi6EIy/R
	B8+U44fw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hIrMR-0006tp-7X; Tue, 23 Apr 2019 09:05:07 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 90E0329B47DCD; Tue, 23 Apr 2019 11:05:05 +0200 (CEST)
Date: Tue, 23 Apr 2019 11:05:05 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: =?utf-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [RFC PATCH 5/5] numa: numa balancer
Message-ID: <20190423090505.GG11158@hirez.programming.kicks-ass.net>
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <85bcd381-ef27-ddda-6069-1f1d80cf296a@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <85bcd381-ef27-ddda-6069-1f1d80cf296a@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 22, 2019 at 10:21:17AM +0800, 王贇 wrote:
> numa balancer is a module which will try to automatically adjust numa
> balancing stuff to gain numa bonus as much as possible.
> 
> For each memory cgroup, we process the work in two steps:
> 
> On stage 1 we check cgroup's exectime and memory topology to see
> if there could be a candidate for settled down, if we got one then
> move onto stage 2.
> 
> On stage 2 we try to settle down as much as possible by prefer the
> candidate node, if the node no longer suitable or locality keep
> downturn, we reset things and new round begin.
> 
> Decision made with find_candidate_nid(), should_prefer() and keep_prefer(),
> which try to pick a candidate node, see if allowed to prefer it and if
> keep doing the prefer.
> 
> Tested on the box with 96 cpus with sysbench-mysql-oltp_read_write
> testing, 4 mysqld instances created and attached to 4 cgroups, 4
> sysbench instances then created and attached to corresponding cgroup
> to test the mysql with oltp_read_write script, average eps show:
> 
> 				origin		balancer
> 4 instances each 12 threads	5241.08		5375.59		+2.50%
> 4 instances each 24 threads	7497.29		7820.73		+4.13%
> 4 instances each 36 threads	8985.44		9317.04		+3.55%
> 4 instances each 48 threads	9716.50		9982.60		+2.66%
> 
> Other benchmark liks dbench, pgbench, perf bench numa also tested, and
> with different parameters and number of instances/threads, most of
> the cases show bonus, some show acceptable regression, and some got no
> changes.
> 
> TODO:
>   * improve the logical to address the regression cases
>   * Find a way, maybe, to handle the page cache left on remote
>   * find more scenery which could gain benefit
> 
> Signed-off-by: Michael Wang <yun.wang@linux.alibaba.com>
> ---
>  drivers/Makefile             |   1 +
>  drivers/numa/Makefile        |   1 +
>  drivers/numa/numa_balancer.c | 715 +++++++++++++++++++++++++++++++++++++++++++

So I really think this is the wrong direction. Why introduce yet another
balancer thingy and not extend the existing numa balancer with the
additional information you got from the previous patches?

Also, this really should not be a module and not in drivers/

