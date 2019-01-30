Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 729C3C282D8
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 09:13:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E5C02184D
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 09:13:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="QqkuLlvZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E5C02184D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD3308E0005; Wed, 30 Jan 2019 04:13:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B83968E0001; Wed, 30 Jan 2019 04:13:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A73E58E0005; Wed, 30 Jan 2019 04:13:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 62A3B8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 04:13:25 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id l9so16363319plt.7
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 01:13:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=MR822vHV0tQgjB8liomI4ONZtoIfEsWxF4ZnmDy1sCQ=;
        b=QFvqBhlMt7/IwLb6nlsv1mkt+obe08K8O14Oh9FsbsmYzWDyzzFU75GSO1Fwas8Rs9
         dLFGYKo6Mn1uoC2m/OKyqHotrZTZjLZ3rinAb6lzDbbpLO6BvUZnhXHnqz/Jv5y9QKE9
         qLrn0FJYxrwnYRBKDrU7Dq3UFQOlIsKWIXFF9qZxsocf5Coy5LnWj5+vSmdHOjNlhuC/
         Rf74sQBwIgs6H+Cl4VRzRtuT93/Yy1cE+bwihHZxaY1hy4vCcvqr8kxVpPjytAaTgiyv
         ZXNV7LN8Ce8WVieqtlpmyRUrKGa9kNOMqlcqokydOM4vOFtoG00NfFE4TVuVeq6YW318
         PzNQ==
X-Gm-Message-State: AJcUukf/xUOWc1ABhwvCjr1no6AXTmQi3/fPauRdkI/P1CQi812p5qAZ
	hhPVx2Ls76UOMsZYetw939yKQw3o1Kceo48DM6Fm9ekQCNifqamcAkHilHy19v9sFyOeD+Zoreh
	OiE7za3ecsyOtZeVc+CaEkPzFaYXDfI8i5SX0ni3vgxs1Bnu8VS5WK2gFfwor34vT8g==
X-Received: by 2002:a17:902:bd86:: with SMTP id q6mr28662367pls.16.1548839604966;
        Wed, 30 Jan 2019 01:13:24 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6ES3qv5jwcagBd9H5RBPmKeO4+ksYxkJKXoBCS1c32e2aa67gaupS+ZFpGJTc6aeHWTSPD
X-Received: by 2002:a17:902:bd86:: with SMTP id q6mr28662335pls.16.1548839604219;
        Wed, 30 Jan 2019 01:13:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548839604; cv=none;
        d=google.com; s=arc-20160816;
        b=gtMFkdTaNTn0o8bggECbluWB2/h3GxbG7eu8Fhxqrm5rwWqziXQavxaz9qIyzFea+6
         ZDEtu5LoSW38MxrxWY7t4O5Z6Pmq3WlYEMLyezpQxXbT5KdAsVrpA1e2DKm/HtlQ3St2
         wbtWmHN+3gBey/jICGEmte6feHgpOFheuTDLloWMl3WM2+TGeq5XrsyixBTt0reyLPem
         zOggjtrbSUra7t+UvyXhxJ/NWdnL9SioQ0Yk6bCC+DRyxYq9kqTiLzHNojorYBCiCUOs
         sZIoqOG7rzt26wwIBSkhW1MxyGitmiriWlFZi7GSs5YQubwRtbj/sx13vXNXnmoXJV9X
         frVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=MR822vHV0tQgjB8liomI4ONZtoIfEsWxF4ZnmDy1sCQ=;
        b=BqpIxYNHo+WfmH6kDOMjXMRxwrUQrqBdIwJ2uny7JdcMNZKgk7rdwp07riJ2P1Vuzq
         T4ZacUjsG6OJV/jRDD80a7WhJFtWpYX804VVyQBb3q4Y+1xK4WBZVdWJWPWy2PVeEFIi
         L426//oE5EOSBh61OFwSNswagaK8q9mv5oFjCtX17O0usuNBDeRNvOVc4Xs7o39fOozd
         yZE6VAadOxKbW7b/+x0jivC+VuyqqGYqyd7rX/nn1TI1UVdOhSJniwlAwzfUFloptM3n
         ireJ6p2ZGzFxd5ABiflDTIKYDwwgiqphlh0eSUo8iqoGnUUwQDc3yVlYsinXLpVwvVZa
         LFvw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=QqkuLlvZ;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u3si932170pgj.300.2019.01.30.01.13.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Jan 2019 01:13:24 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=QqkuLlvZ;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=MR822vHV0tQgjB8liomI4ONZtoIfEsWxF4ZnmDy1sCQ=; b=QqkuLlvZObvOlBt91xGLZoG2+
	BJPPa3tN7GYwjdo07yWyJz7mZktgiDfg32RHTfDnXsAZWnAyEyxn0rd4FPBhHGBlMxl2r071WfIb6
	2Y0tEFyQkc22Xchxx6RttWKXw4Mgp51a911+OfUE4/3EtceBPklVt3b39BVUNM1O57XVCoftAwbvc
	n5G1ppGDRToXiYviwcDjiWGB7pepu9EbOf2c2q7lgtwtgEAYlAgR9tR7X62PTwdtLQJ8krtVIXxdV
	EXzK46xB0oWNY0bMCs3aN924pcGBYTxjvfV8pNJmUVERCxKTdiF9gzwuTRpqW/U6BZgLtH/9AVYXU
	zBLVu3a6Q==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1golvq-0001K1-VU; Wed, 30 Jan 2019 09:13:19 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id E68F920289CC5; Wed, 30 Jan 2019 10:13:16 +0100 (CET)
Date: Wed, 30 Jan 2019 10:13:16 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: akpm@linux-foundation.org, dan.carpenter@oracle.com,
	andrea.parri@amarulasolutions.com, shli@kernel.org,
	ying.huang@intel.com, dave.hansen@linux.intel.com,
	sfr@canb.auug.org.au, osandov@fb.com, tj@kernel.org,
	ak@linux.intel.com, linux-mm@kvack.org,
	kernel-janitors@vger.kernel.org, paulmck@linux.ibm.com,
	stern@rowland.harvard.edu, will.deacon@arm.com
Subject: Re: [PATCH] mm, swap: bounds check swap_info accesses to avoid NULL
 derefs
Message-ID: <20190130091316.GC2278@hirez.programming.kicks-ass.net>
References: <20190114222529.43zay6r242ipw5jb@ca-dmjordan1.us.oracle.com>
 <20190115002305.15402-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190115002305.15402-1-daniel.m.jordan@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 14, 2019 at 07:23:05PM -0500, Daniel Jordan wrote:
> Dan Carpenter reports a potential NULL dereference in
> get_swap_page_of_type:
> 
>   Smatch complains that the NULL checks on "si" aren't consistent.  This
>   seems like a real bug because we have not ensured that the type is
>   valid and so "si" can be NULL.
> 
> Add the missing check for NULL, taking care to use a read barrier to
> ensure CPU1 observes CPU0's updates in the correct order:
> 
>         CPU0                           CPU1
>         alloc_swap_info()              if (type >= nr_swapfiles)
>           swap_info[type] = p              /* handle invalid entry */
>           smp_wmb()                    smp_rmb()
>           ++nr_swapfiles               p = swap_info[type]
> 
> Without smp_rmb, CPU1 might observe CPU0's write to nr_swapfiles before
> CPU0's write to swap_info[type] and read NULL from swap_info[type].
> 
> Ying Huang noticed that other places don't order these reads properly.
> Introduce swap_type_to_swap_info to encourage correct usage.
> 
> Use READ_ONCE and WRITE_ONCE to follow the Linux Kernel Memory Model
> (see tools/memory-model/Documentation/explanation.txt).
> 
> This ordering need not be enforced in places where swap_lock is held
> (e.g. si_swapinfo) because swap_lock serializes updates to nr_swapfiles
> and the swap_info array.
> 
> This is a theoretical problem, no actual reports of it exist.
> 
> Fixes: ec8acf20afb8 ("swap: add per-partition lock for swapfile")
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>

A few comments below, but:

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

> +static struct swap_info_struct *swap_type_to_swap_info(int type)
> +{
> +	if (type >= READ_ONCE(nr_swapfiles))
> +		return NULL;
> +
> +	smp_rmb();	/* Pairs with smp_wmb in alloc_swap_info. */
> +	return READ_ONCE(swap_info[type]);
> +}

> @@ -2799,9 +2810,9 @@ static void *swap_start(struct seq_file *swap, loff_t *pos)
>  	if (!l)
>  		return SEQ_START_TOKEN;
>  
> -	for (type = 0; type < nr_swapfiles; type++) {
> +	for (type = 0; type < READ_ONCE(nr_swapfiles); type++) {
>  		smp_rmb();	/* read nr_swapfiles before swap_info[type] */
> -		si = swap_info[type];
> +		si = READ_ONCE(swap_info[type]);
>  		if (!(si->flags & SWP_USED) || !si->swap_map)
>  			continue;
>  		if (!--l)
> @@ -2821,9 +2832,9 @@ static void *swap_next(struct seq_file *swap, void *v, loff_t *pos)
>  	else
>  		type = si->type + 1;
>  
> -	for (; type < nr_swapfiles; type++) {
> +	for (; type < READ_ONCE(nr_swapfiles); type++) {
>  		smp_rmb();	/* read nr_swapfiles before swap_info[type] */
> -		si = swap_info[type];
> +		si = READ_ONCE(swap_info[type]);
>  		if (!(si->flags & SWP_USED) || !si->swap_map)
>  			continue;
>  		++*pos;

You could write those like:

	for (; (si = swap_type_to_swap_info(type)); type++)

> @@ -2930,14 +2941,14 @@ static struct swap_info_struct *alloc_swap_info(void)
>  	}
>  	if (type >= nr_swapfiles) {
>  		p->type = type;
> -		swap_info[type] = p;
> +		WRITE_ONCE(swap_info[type], p);
>  		/*
>  		 * Write swap_info[type] before nr_swapfiles, in case a
>  		 * racing procfs swap_start() or swap_next() is reading them.
>  		 * (We never shrink nr_swapfiles, we never free this entry.)
>  		 */
>  		smp_wmb();
> -		nr_swapfiles++;
> +		WRITE_ONCE(nr_swapfiles, nr_swapfiles + 1);
>  	} else {
>  		kvfree(p);
>  		p = swap_info[type];

It is also possible to write this with smp_load_acquire() /
smp_store_release(). ARM64/RISC-V might benefit from that, OTOH ARM
won't like that much.

Dunno what would be better.

