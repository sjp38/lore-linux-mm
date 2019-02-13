Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04257C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 19:20:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7CD3222D0
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 19:20:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="xpvLh6vW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7CD3222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54F6C8E0002; Wed, 13 Feb 2019 14:20:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FDF58E0001; Wed, 13 Feb 2019 14:20:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C65C8E0002; Wed, 13 Feb 2019 14:20:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 158208E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 14:20:01 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id t18so5672895itk.2
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 11:20:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=HcY3F6GG2jLp6WPTaAp0m8PyF3UbgW15wL3YqdVa5sg=;
        b=dwh1SWAR0wN0MFDIXzKPHeSF71yGvKeru88m2y7L6OI2vpjLMHis7go9EvoGqi7dy2
         llWm2edkJDreRl9xmbw46GD1YBnq8d/j56Pl2/muuedTaCY1pb+z/ZBzcp2TCSRSqwHd
         ZSUXFDUemp+SuSQX7w//Z/2NbzrQzx0ajKfKyjyFMAKHtr1V0QGiUkaqP2L5hBarAd/R
         /hgcVw6KGF9cwiel5XLkeluJGmXVNw7Fb1QIpJZaJB7A156ismrseyy9QkjUPI+5vFwn
         sI/lN30gfQIjQVds/8PDH61CIeWomToSJniflau1dHPwPB7FHiqiF/YdiZn7NL0eyQbc
         0hdw==
X-Gm-Message-State: AHQUAuYtkAfxXt3W30hYX/7tdKCaPmFCUmLJrMacPsCKAeaRw370cXuZ
	ILywFOhgx+BRlhwa0fUHtSCGivLz/cvw3Jr2a9iMBwTaYX+0MXCLHqoL/cEosOOAIONo+CbmAtl
	/43c31uxnMq3dq3Xhs5RUgSdsz/aPQ4kd/DDt6MEBJoIliHqX0RiKJiymD3CZwETDng==
X-Received: by 2002:a24:7b48:: with SMTP id q69mr1246540itc.31.1550085600846;
        Wed, 13 Feb 2019 11:20:00 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib5P5iwXi63AJXMuHF9iL7xTpGqz6QKmvlOAUgWG+K+YQu9eMwgrQyTDtXH5iwgrKzi7pPJ
X-Received: by 2002:a24:7b48:: with SMTP id q69mr1246502itc.31.1550085600050;
        Wed, 13 Feb 2019 11:20:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550085600; cv=none;
        d=google.com; s=arc-20160816;
        b=azKi0et32jwMZ+SrjKZU24CtcxpjavPr+GaflP5qALszpuqEEmdqS4M1RLRPcPZbnk
         6z1aI9t1FvwbkC+3TVC76jZHuW3Ex6kfD1WaR7bSafoEo+wK+pgM5lWj6WywkfjE+l9g
         NnJ7LspU4FVDP//T4sovMry0RVIPuQHRkD/Te25gV00vZIBF3LGmmc/xzYZRoZI4w3Vw
         A6uEiV6bJsjstIW0CyuTK49NyVmg2KbP0LYbANIFnEKeJtwJiIiiyIcUYP1I55wFWZjX
         IeFvR43olAL6GB+FlMIB6QBowXikbwQ2ILE+KkeLWrMhSYJ/qIk3Ns73qmgaVSYltdPt
         dI1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=HcY3F6GG2jLp6WPTaAp0m8PyF3UbgW15wL3YqdVa5sg=;
        b=ehJPT1aMlyHuKqmsUrvNOpaf6zuS+NZR895eXDYPhcC5Gh/TwORjlw6x2Pl/5aSJVR
         x5ceCnajFy/TfX4Dy+WCQYXD4UDHBo3A4Z/8BartB6y7kIlrDcCeDs1yzFvS9x0P3kcM
         XgNP0kQGOptJ2/IQeRD9a2+hJrIJb8dNzpydkBWnYbTYVh/JvXqxWpKEBaMQ+gM419p/
         JWHgMMnWD5SZ6TZ5ZvvoD101EVNYg7G3lIEqUxMuIpK7aXkRvy5Mkzfj8EqSoL/Jjk5b
         d3JWa6U9BPD9mKB8N16cXjeHjJ5+Gz4yqC5uVDdo9nvAbczoYNajLWBnnQLnCP4aiGq4
         RuuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=xpvLh6vW;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id g2si70795jag.2.2019.02.13.11.19.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 11:20:00 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=xpvLh6vW;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1DJ8pqS065606;
	Wed, 13 Feb 2019 19:19:58 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=HcY3F6GG2jLp6WPTaAp0m8PyF3UbgW15wL3YqdVa5sg=;
 b=xpvLh6vWHJRf2xA44b0va2eRiW4TBJ9RdXBFGivGbrjDr4VNyENkKKXFXbN3Aw2hTx4H
 OeFSTby08V4aBQelridQjNpRzw28pIfaPHJG8Wao9xntoMu4mAMXt3gid7XrEbl1qQNa
 2zUpbVuj+oDWo1qnYPohYlHlDvEJFRp/rtbduxiFMQw38qF84oKghct3OxM3q4H7cQEH
 19mlsErljaBFoKk+E9Wj52G9xPv6ylrIcNDxoodPoYSFRQ3VoGGprVfcdFeauLSJzhxg
 bWfbipna13cYCJG5tWJZMLeMUZcbl4Rp0YuGYdkSMezpQeCNrGNImaz6Q8UlkfE5UHat 1Q== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2qhree40va-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 13 Feb 2019 19:19:58 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1DJJpIK005039
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 13 Feb 2019 19:19:52 GMT
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1DJJoP9014197;
	Wed, 13 Feb 2019 19:19:51 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 13 Feb 2019 19:19:50 +0000
Date: Wed, 13 Feb 2019 14:20:11 -0500
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 4/4] mm: Generalize putback scan functions
Message-ID: <20190213192011.62vmk5wyvxufcn4k@ca-dmjordan1.us.oracle.com>
References: <154998432043.18704.10326447825287153712.stgit@localhost.localdomain>
 <154998445694.18704.16751838197928455484.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154998445694.18704.16751838197928455484.stgit@localhost.localdomain>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9166 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902130131
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000114, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 06:14:16PM +0300, Kirill Tkhai wrote:
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
> -		VM_BUG_ON_PAGE(PageLRU(page), page);
> -		list_del(&page->lru);
> +	while (!list_empty(list)) {
> +		page = lru_to_page(list);
>  		if (unlikely(!page_evictable(page))) {
> +			list_del_init(&page->lru);
>  			spin_unlock_irq(&pgdat->lru_lock);
>  			putback_lru_page(page);
>  			spin_lock_irq(&pgdat->lru_lock);
>  			continue;
>  		}
> -
>  		lruvec = mem_cgroup_page_lruvec(page, pgdat);
>  
> +		VM_BUG_ON_PAGE(PageLRU(page), page);

Nit, but moving the BUG down here weakens it a little bit since we miss
checking it if the page is unevictable.


Maybe worth pointing out in the changelog that the main difference from
combining these two functions is that we're now checking for !page_evictable
coming from shrink_active_list, which shouldn't change any behavior since that
path works with evictable pages only.

