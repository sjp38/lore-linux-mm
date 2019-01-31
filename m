Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5199BC282D7
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 02:00:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E850620989
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 02:00:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="UHZAVqrl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E850620989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B62E8E0002; Wed, 30 Jan 2019 21:00:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 83C6C8E0001; Wed, 30 Jan 2019 21:00:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 705B48E0002; Wed, 30 Jan 2019 21:00:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 43E8D8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 21:00:38 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id p21so1416443iog.0
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 18:00:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=5GAvjSYlUai5MvC8EReIb369vIiSklD8lXWzq4CBSR4=;
        b=qhMJNOkQF8Kj7gbsUbYWFRmifW378Y5zwv1pggvofr9AlQKmnKAoEZyEEtKo0ax6MH
         OsYQlFvATf09aV0aNrsvlJa3hGTtmUwnaOz67AQVb/0GIAQfw02/P/NVi2DdsAl+iZXW
         8ZkTb8Cg3Ov+vqSwU6ELTdQUix/TeBEK3Eq7u30eEsHiZYLz7ytmr5jqQvyjrwHPnAcY
         hqoADvzhlYmdQYv3iLviTiZMVTJYir5/0H4fYdC8R9ud1NzUpmZ2XxbRc2N36rUrcu9A
         UBPa5OA88fPoT2tbj9fTMhydYFuhkrpld8pEvIk8ySjWRukl9tQmasGelqpYkzCGkyYg
         rlKw==
X-Gm-Message-State: AJcUukcHbXtMnBPzHL+hjMi6mnZP8iGogUMDxPucY1Z3gtYKst6WXPCL
	UySm6d0lqPgu/karKguF+DCX0UO7cNAnhshqUxgzWh1ksGwdgVzbHFzclgg9COryFxUJWOt69cQ
	X0VY5YYheT7GaayXIEJ6Tcd4cyssqQnLwxC40ae/x3IfPdpkbLnxYHATYyW5LDgCw/Q==
X-Received: by 2002:a24:1d4a:: with SMTP id 71mr9891715itj.62.1548900038007;
        Wed, 30 Jan 2019 18:00:38 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6R/4ZY1Nki7a53kkKxyCqaR/PhO0ytyIoZPBSE4RZyYGiiIyewivBMid8qFaq9YQneEtnl
X-Received: by 2002:a24:1d4a:: with SMTP id 71mr9891697itj.62.1548900037306;
        Wed, 30 Jan 2019 18:00:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548900037; cv=none;
        d=google.com; s=arc-20160816;
        b=B7skToQ99LCija7HjoyRHMY6Xp0BDDh0pFFk0HKMPXHsJLJp5KnYsPqmpFb09nqsnJ
         jAfPYG6FD+hNNono8gOb4UaQCJptGRzLBMbdwEXJhgHFlYI/zTKHUYXqPFIg8cFovxhG
         uKzQK/bLg+UC5Sa+O5KZEIEIfa/eC/ZNNC/01CSK8GWfiSXeyTzZWA4xsTGQ17BLsdXF
         KNkqzFm0A8+KoGpbWu0WWQ8qxAqTCrN8uJ60tn4d8YJlZ/D4CAiRPTYP9f7GlgmSXsvW
         PbG5RRATOcMc5OGuw9vk6USeiOqr9DPgVa08Qy40wWy/3XYxkbCfIp4adJpQrEdW4Xav
         W+mA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=5GAvjSYlUai5MvC8EReIb369vIiSklD8lXWzq4CBSR4=;
        b=PTZA46M8cAjz5YoACmwADuyxHpAb9y46E9SfGZQvD5blsf6hARsbiF1fWoYOy3fTH/
         vREi0vojreqlGPvlIMEc2oFhFjKXiSU/PStHAlOnu0C7hsMwbEYD70Z91UJMUAYSxgn2
         d8upJn+GQp+8gdYGo/tr/wY3Q7P4TW74hEMTLQONhxDy2Ap9zukFt7QTQ7GW6+sG1/qI
         mQL4hsjO6b+Sc1AXgSU+h9aCZLQADHLUOb99dW8yZZHTxHLWgjLO3slYlPl9GEVLYbMw
         7iZmghSdbKqmF0aKHBKD65VAiGjUxW8xBQzUBV+8PWberTdma0a349hxrY1m4DftGkir
         oHOg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=UHZAVqrl;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id u133si2188686ita.5.2019.01.30.18.00.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 18:00:37 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=UHZAVqrl;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0V1s52k188913;
	Thu, 31 Jan 2019 02:00:15 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=5GAvjSYlUai5MvC8EReIb369vIiSklD8lXWzq4CBSR4=;
 b=UHZAVqrl+vdwGBjXdtOZKUcwPSVGQ1JGjjaBnzDapMgO2RUSJ7b1mAxErYnl59kCZ7D0
 sgEXv0uTcEhLG9fk4HpUake7menYE7vexn2y0DK2KwAT8cRrc8JtdbGzceWvCmmj1ep+
 uFrYW03jiyxgcV8ZeG5OcSZTSR/216uwnUIv5OBfJJKZfVfc7DwK7I74rVZx/pfPMC7D
 T4YCNl4nU6XDRRIyNidnDOknK4rW1pwUylvkYEK1RXIStt8bSipZpSUfAZWZ5gaifLxq
 k2LXmTi61EkTfRH5MQLRc9ArC8JosO5vK73xQFyXEguomwt23vA6AMISxeF+SqZdPkn0 sQ== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2130.oracle.com with ESMTP id 2q8d2ee5k5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 31 Jan 2019 02:00:15 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x0V20AXb003098
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 31 Jan 2019 02:00:10 GMT
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x0V209Oo021287;
	Thu, 31 Jan 2019 02:00:09 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 30 Jan 2019 18:00:08 -0800
Date: Wed, 30 Jan 2019 21:00:20 -0500
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, akpm@linux-foundation.org,
        dan.carpenter@oracle.com, andrea.parri@amarulasolutions.com,
        shli@kernel.org, ying.huang@intel.com, dave.hansen@linux.intel.com,
        sfr@canb.auug.org.au, osandov@fb.com, tj@kernel.org,
        ak@linux.intel.com, linux-mm@kvack.org,
        kernel-janitors@vger.kernel.org, paulmck@linux.ibm.com,
        stern@rowland.harvard.edu, will.deacon@arm.com
Subject: Re: [PATCH] mm, swap: bounds check swap_info accesses to avoid NULL
 derefs
Message-ID: <20190131020020.h25czxccz74c4b7f@ca-dmjordan1.us.oracle.com>
References: <20190114222529.43zay6r242ipw5jb@ca-dmjordan1.us.oracle.com>
 <20190115002305.15402-1-daniel.m.jordan@oracle.com>
 <20190130091316.GC2278@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190130091316.GC2278@hirez.programming.kicks-ass.net>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9152 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1901310013
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000005, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 10:13:16AM +0100, Peter Zijlstra wrote:
> On Mon, Jan 14, 2019 at 07:23:05PM -0500, Daniel Jordan wrote:
> 
> A few comments below, but:
> 
> Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

Thanks.

> > @@ -2799,9 +2810,9 @@ static void *swap_start(struct seq_file *swap, loff_t *pos)
> >  	if (!l)
> >  		return SEQ_START_TOKEN;
> >  
> > -	for (type = 0; type < nr_swapfiles; type++) {
> > +	for (type = 0; type < READ_ONCE(nr_swapfiles); type++) {
> >  		smp_rmb();	/* read nr_swapfiles before swap_info[type] */
> > -		si = swap_info[type];
> > +		si = READ_ONCE(swap_info[type]);
> >  		if (!(si->flags & SWP_USED) || !si->swap_map)
> >  			continue;
> >  		if (!--l)
> > @@ -2821,9 +2832,9 @@ static void *swap_next(struct seq_file *swap, void *v, loff_t *pos)
> >  	else
> >  		type = si->type + 1;
> >  
> > -	for (; type < nr_swapfiles; type++) {
> > +	for (; type < READ_ONCE(nr_swapfiles); type++) {
> >  		smp_rmb();	/* read nr_swapfiles before swap_info[type] */
> > -		si = swap_info[type];
> > +		si = READ_ONCE(swap_info[type]);
> >  		if (!(si->flags & SWP_USED) || !si->swap_map)
> >  			continue;
> >  		++*pos;
> 
> You could write those like:
> 
> 	for (; (si = swap_type_to_swap_info(type)); type++)

That's clever, and way better than the ugly iterator macro I wrote and then
deleted in disgust.

> > @@ -2930,14 +2941,14 @@ static struct swap_info_struct *alloc_swap_info(void)
> >  	}
> >  	if (type >= nr_swapfiles) {
> >  		p->type = type;
> > -		swap_info[type] = p;
> > +		WRITE_ONCE(swap_info[type], p);
> >  		/*
> >  		 * Write swap_info[type] before nr_swapfiles, in case a
> >  		 * racing procfs swap_start() or swap_next() is reading them.
> >  		 * (We never shrink nr_swapfiles, we never free this entry.)
> >  		 */
> >  		smp_wmb();
> > -		nr_swapfiles++;
> > +		WRITE_ONCE(nr_swapfiles, nr_swapfiles + 1);
> >  	} else {
> >  		kvfree(p);
> >  		p = swap_info[type];
> 
> It is also possible to write this with smp_load_acquire() /
> smp_store_release(). ARM64/RISC-V might benefit from that, OTOH ARM
> won't like that much.
> 
> Dunno what would be better.

I just left it as-is for now.

