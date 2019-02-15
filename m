Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3401C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 20:39:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6CD49222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 20:39:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="wv6bEB26"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6CD49222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7C138E0003; Fri, 15 Feb 2019 15:39:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2BD28E0001; Fri, 15 Feb 2019 15:39:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D40C98E0003; Fri, 15 Feb 2019 15:39:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id A1BB48E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 15:39:19 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id x132so6477529ybx.22
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 12:39:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=rNtnO7rrhauRz+civhMrk0zTJ+CPDxwnD/u/os2j5wE=;
        b=MQnLcHdmdcd5Yyj75+A42O4O1LLTvnHcHqK4VBv6A00psUBO6pYnl216MGAcAR8Pnt
         HjALsQGgjyHAtZY8zhH7UuQEimfonDpzJVEVww2OFSS8vrBRsJLrh9Oez7+5mM4MoJQ0
         chOTWm45Fw2taabSRW32qKIQ5D3U99i8KZgslc/XxYx0dWVpUjoc76hIlLIre48IXLRv
         arPUpMemsqbpJovZzPKjvQ5VqiGMC6BJI4U6HSCiAkiCHTS4GDtCNL1SAHHyNKzFBqTB
         YxbK0o6vYHYKZajVSrw1aRs41go1+qXs1TU/WUdICDtJh0XAKXAs266LWEH0ghLkgO5R
         dFUg==
X-Gm-Message-State: AHQUAubISCTdhINkFp5+GU1nUnT2AeGQujVFo5EApqr9RwGyAVQoTbG9
	4f3CFAOb4gIfMZIFfgnMyVVEKwZx9os5rnGLeNbOPi4QkAEUvzWDp6OBqrhkVa2UQufyTZQP3qS
	ifJeJ2akUvganydj7TxA/pTbFe6oadL3psaWQ1gnz+2hBo7BWfnFyu+cbWtSAiV75iw==
X-Received: by 2002:a25:8544:: with SMTP id f4mr9681206ybn.484.1550263159255;
        Fri, 15 Feb 2019 12:39:19 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaPGnQYM1IeY5qjK0uR9HKFyeSGQVXd9+CnjeX8hc104PzJGmO5TvA2CMMnb+ZEPCEK6buM
X-Received: by 2002:a25:8544:: with SMTP id f4mr9681172ybn.484.1550263158682;
        Fri, 15 Feb 2019 12:39:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550263158; cv=none;
        d=google.com; s=arc-20160816;
        b=PVOfhZHsPvCblttHlitkkC/ZEMI7hgrXmixzFORNvXGT4q1anVSAgXq4c8KbtOFN8z
         MLssU8zFeXdG3h94xSIxdoW2qho4eSPDCC8x8YZznXM1kxbGBz7N2XUcyXenCdVwcWva
         f7Xs4imjpcSqh61AyEwpITylgBXQtjOWUqvMpzIJAEQ9hb3hmWqIt/+9uj5thnYN2VYU
         1ipKiEHEjqW9homfNHiz3YQxHzpPBJQNypyViejkz+dA2+Ij1lOATyfnjF8itOtSmkHb
         J529atbgUjCeuMIOXMiyu6cIrg8GXbjCK2vnYb1aRjFeMTi0bDc9wzSSg3pCcdoTtQaD
         oEWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=rNtnO7rrhauRz+civhMrk0zTJ+CPDxwnD/u/os2j5wE=;
        b=EZ4Q5tSY2ndrAizuZpjliIhVHIk+a1cF2gOR1zbKfF3TIJYjsOyqyCoNGGQkTHNXRT
         doghY9edCpVQ3++Zr32eDX+UqIJGHxd8aTbNm1QEQMtDyGnOuPrZNEI9/YEh+3fmyoUJ
         EkBiwQ91Fcuz/xk2HrzvzDU6EMT73ers32dXzSlrcVzF2NOxMExhOA1tq+PMHFz0f2I9
         Twa7TiXnHDfiBA4tmNfQN8s9qOdCy//IXA+clmDUhHIgFemdtVhfUiSj2jpGti2A5/Ed
         4VKPPpq1WwquRl8HPdcKrLTfQxMVEnN7tUubr0k8PkFnN0QTvzXEPCN/NIpBTOigh2tq
         ph0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=wv6bEB26;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 134si3651077ybc.79.2019.02.15.12.39.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 12:39:18 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=wv6bEB26;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1FKdGJ7062143;
	Fri, 15 Feb 2019 20:39:16 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=rNtnO7rrhauRz+civhMrk0zTJ+CPDxwnD/u/os2j5wE=;
 b=wv6bEB26lL2CSNHY6O6O/J5Yb4U9YrV7plIBrbZAIALvEiingOLKroZ2Pn4BtR49u8Kn
 8BCIpW3j8o6263qqbqQ6OKZw74WuH3Hm7W8TQ35zIRUA5voJ5hP6YYfKRTg8SluMnKJd
 bD7vxsMseRLf+z6QknR3QN7m/zLs5KHKrro0mfvALFl6D+Ii6qUgsc8+aDQYsW3r/yTC
 3DKVBUyKeNoEtw73kpb/o7RKXd/ZmnyROx7pdLg4EllbJdtdFeekuhLQw9yOMQOMEBrF
 xJeQomlaC+BR+xm2V/Bqi5Ytld1f/nv3kDYcVgDcR3B0XYJrEZ/AlUi77GGD5Xltp3Ji 2w== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2120.oracle.com with ESMTP id 2qhreeg05s-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 15 Feb 2019 20:39:16 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1FKd7Wa005035
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 15 Feb 2019 20:39:07 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1FKd6pF008310;
	Fri, 15 Feb 2019 20:39:06 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 15 Feb 2019 20:39:05 +0000
Date: Fri, 15 Feb 2019 15:39:27 -0500
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, daniel.m.jordan@oracle.com, mhocko@suse.com,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 4/4] mm: Generalize putback scan functions
Message-ID: <20190215203926.ldpfniqwpn7rtqif@ca-dmjordan1.us.oracle.com>
References: <155014039859.28944.1726860521114076369.stgit@localhost.localdomain>
 <155014053725.28944.7960592286711533914.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155014053725.28944.7960592286711533914.stgit@localhost.localdomain>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9168 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=851 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902150136
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 01:35:37PM +0300, Kirill Tkhai wrote:
> +static unsigned noinline_for_stack move_pages_to_lru(struct lruvec *lruvec,
> +						     struct list_head *list)
>  {
>  	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
> +	int nr_pages, nr_moved = 0;
>  	LIST_HEAD(pages_to_free);
> +	struct page *page;
> +	enum lru_list lru;
>  
> -	/*
> -	 * Put back any unfreeable pages.
> -	 */
> -	while (!list_empty(page_list)) {
> -		struct page *page = lru_to_page(page_list);
> -		int lru;
> -
> +	while (!list_empty(list)) {
> +		page = lru_to_page(list);
>  		VM_BUG_ON_PAGE(PageLRU(page), page);
> -		list_del(&page->lru);
>  		if (unlikely(!page_evictable(page))) {
> +			list_del_init(&page->lru);

Why change to list_del_init?  It's more special than list_del but doesn't seem
needed since the page is list_add()ed later.

That postprocess script from patch 1 seems kinda broken before this series, and
still is.  Not that it should block this change.  Out of curiosity did you get
it to run?

