Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2611C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 22:12:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D9472146F
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 22:12:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="AGTSA/Xj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D9472146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDEC56B0269; Thu, 11 Apr 2019 18:12:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C8F166B026A; Thu, 11 Apr 2019 18:12:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA56D6B026B; Thu, 11 Apr 2019 18:12:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 991D46B0269
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 18:12:51 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id r21so6112236iod.12
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 15:12:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=VdvttgJMgi7y1biuAcRc/Ir8rfp3LIcUFLMa+DzZmPc=;
        b=BL2P/rpDbxY8jv3oaJFOiqpQiVK23bxZOL7/OwN0cN3WWq+vFou2SG5PVYnQdPNPgP
         42Pe+SYENB0XRzlHOPyePu0uinNLomEOX+8wfU+xLTagNVzgteF4+2jKMx3dGVkik0o2
         Bus8izRGiqTUmoQHYfv1FLm8wkIoznJy9qt6b9tu60n0Jn9prr+yqILh8q+bnJc7Xurm
         IcBoMZYJM8bP1JM049cBgTGpsY1fNYh3HysBRdYdWYpaDokoQo2nFGjAPiuhIEUmUQ/K
         12j+2Vuqt95P6OghY9xUNWq3SsReDeuwRDU4bmrFTSZOTVDHLKQgSQ4G/b6vSdQjHTM9
         qzLQ==
X-Gm-Message-State: APjAAAWZij0f0ibSXTXNy1lIGKZ0pSVFElILZczKJ+W87135GGRZKmCJ
	+Vae5DxS6RPNTRarnBKXPbO381owgeaQy4bKHMeJaUiPKEK66gMmFCQ1cZYGwJzsA5ObIVxlZRt
	vRORlCjmze6XuVnIB2DWwJAd07mMryTxs7kwNTkHYWlXIriE+70nA7zcwkPXWPlpibQ==
X-Received: by 2002:a24:ad0:: with SMTP id 199mr10457237itw.125.1555020771272;
        Thu, 11 Apr 2019 15:12:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDZnW3cw8jtrKqoPJkq3aXg5pGJ08E7qxkmXW6+BGzI6Zuk54K7E0VoyCW6Efg+tH5bYHV
X-Received: by 2002:a24:ad0:: with SMTP id 199mr10457169itw.125.1555020770550;
        Thu, 11 Apr 2019 15:12:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555020770; cv=none;
        d=google.com; s=arc-20160816;
        b=NEHo6SCxIiro6aNN8r3cGz82LSW6XzFCKmjbOfaAs0hvkLhI84Fi3eE4x39Bf8fr/k
         TfrDMddcTkoR2IskqSG081JkBP6Nfwctngkcl7WGQ/x4jPgO1IEJU5/oPkY4o51JHL9Q
         bgEcJ3knKa8bKX0Ltcwcb/eFr5DfgBcW8B95ZSMnDOluA5J19mRi8o3s+fIG93tEoKkP
         Hxh/Z7kSFoGdLtWoJCQIcaKNhvF5vtoN0R69mR2zuptL+i7ESZ05R3A9ls7koHCOwaBy
         v6A2zc/unuwc7bNHmtYZ4BAXPHCmmyF7wsfAxT4OTV3LrAijbjA5V8HneltgGPV7b58c
         qLzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=VdvttgJMgi7y1biuAcRc/Ir8rfp3LIcUFLMa+DzZmPc=;
        b=k4pCc9mLYYB42qBqGVq//qN7j7WdudLwRRQqD56kaZ6Mi+BNIfroFVXTCQCcdWsmMr
         JTZsbCzNGklUgn9rp0olm4TuCbVU1pXMyPkmr4PjY1UQhqRY5ofz90/1yvdwtvwkF3Vd
         4hzSJvCEIz5G9Z1eRtr5zQMxAbBJdJEnEH2HvMSZItfpDUGFpzfjRuDInKqksrmecOIk
         8hfSDJT7UQR+qr07Y+3/GiJPwt6tNtfD+IDQXlVzCscWwP1nW1P3NKEY0vCst73aL7S8
         14wF1Be/I0xTdc5DKpKFS7Jq1NaUrhq7kbzEODnP0lGvD6vRBEEz7L6sEeWYJdWgSlX7
         XdyA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="AGTSA/Xj";
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id 129si21999184jai.75.2019.04.11.15.12.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 15:12:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="AGTSA/Xj";
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3BLrpgY057632;
	Thu, 11 Apr 2019 22:12:47 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=VdvttgJMgi7y1biuAcRc/Ir8rfp3LIcUFLMa+DzZmPc=;
 b=AGTSA/XjMxDbPhN9y6K65txnTEY72U776+CCrxESpVxd0KJUTLaXyueLt9j/xJ1tYXAh
 iN1tW39ot6Ya2hm0wn3WVLOLWBbHGZMNhlTeLtWsVXUG2VkQSJwhnfc4fOUSzPzOnE0i
 lTvtJBSVp0TorOosKe/pBwJR4IdZ3XplBLjGVa4Ao15eN55/McrmvBXLNZKxG0451W21
 bAHU9AmbE/AXvgPrffo+zJNQLbQ3+lDSET3r9orwYNueB95NRwebJ1NpR4SBbRFjMCWg
 zQwJfVD3a8gbi4zhXIxm4y50RhUm9nEMA39Q+Oo9qEUOKjdeo3T/HNKp4QxNIJC+ZUnb og== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2130.oracle.com with ESMTP id 2rphmeupf6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Apr 2019 22:12:47 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3BMBweH083206;
	Thu, 11 Apr 2019 22:12:46 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3020.oracle.com with ESMTP id 2rtd848u6u-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Apr 2019 22:12:46 +0000
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x3BMCfet021761;
	Thu, 11 Apr 2019 22:12:42 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 11 Apr 2019 15:12:41 -0700
Date: Thu, 11 Apr 2019 18:13:10 -0400
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, hannes@cmpxchg.org,
        dave@stgolabs.net, linux-mm@kvack.org
Subject: Re: [PATCH] mm: Simplify shrink_inactive_list()
Message-ID: <20190411221310.sz5jtsb563wlaj3v@ca-dmjordan1.us.oracle.com>
References: <155490878845.17489.11907324308110282086.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155490878845.17489.11907324308110282086.stgit@localhost.localdomain>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9224 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=887
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904110140
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9224 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=910 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904110140
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 10, 2019 at 06:07:04PM +0300, Kirill Tkhai wrote:
> @@ -1934,17 +1935,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
>  	reclaim_stat->recent_scanned[file] += nr_taken;
>  
> -	if (current_is_kswapd()) {
> -		if (global_reclaim(sc))
> -			__count_vm_events(PGSCAN_KSWAPD, nr_scanned);
> -		count_memcg_events(lruvec_memcg(lruvec), PGSCAN_KSWAPD,
> -				   nr_scanned);
> -	} else {
> -		if (global_reclaim(sc))
> -			__count_vm_events(PGSCAN_DIRECT, nr_scanned);
> -		count_memcg_events(lruvec_memcg(lruvec), PGSCAN_DIRECT,
> -				   nr_scanned);
> -	}
> +	if (global_reclaim(sc))
> +		__count_vm_events(PGSCAN_KSWAPD + is_direct, nr_scanned);
> +	__count_memcg_events(lruvec_memcg(lruvec), PGSCAN_KSWAPD + is_direct,
> +			     nr_scanned);

Nice to avoid duplication like this, but now it takes looking at
vm_event_item.h to understand that (PGSCAN_KSWAPD + is_direct) might mean
PGSCAN_DIRECT.

What about this pattern for each block instead, which makes the stat used
explicit and avoids the header change?

       stat = current_is_kswapd() ? PG*_KSWAPD : PG*_DIRECT;

