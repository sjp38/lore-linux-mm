Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BA46C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 16:52:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55D82218AC
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 16:52:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="p0V3MkQw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55D82218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DBD658E0002; Thu, 31 Jan 2019 11:52:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D43FD8E0001; Thu, 31 Jan 2019 11:52:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C0BBC8E0002; Thu, 31 Jan 2019 11:52:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8BAF98E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 11:52:04 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id t3so2102688ybo.15
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 08:52:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=96Zby0oLN4dn4XccAslysCBwFxo0rNHCR3wOe7W9OgQ=;
        b=pEsTH4h06uYJ32jlFDTKKPhbDiUhBfj8utcoxBjsQgo+EnK47MxwSFKBtAYczwry74
         AODZw3Hy82WnkKLLUsTBFPhqUweuRrIWLmuicmquHI2s/tVU4+lUMZoQ0bhM9qgdv7u5
         Mkvt8mOuzzxbBmU54+ihjy2y8CMSHwW+sHHpiespjUakjT/tWm4jCC8ldRN8v8AziJSv
         YG59MjIt2ap7mWhZbIpm9Hxuu647PJ5U2DtfCOTFfD/8rZZ9n+P6l7B8tkENi5YwFnVe
         9QLF2QgwA2xmnw1hyjyKaPu1iVwKwAPuVig1XPdjjZ0NNKO/d7wCxr2DyXoUeP3dmhh+
         qZlg==
X-Gm-Message-State: AJcUukeUjRee3ivVFDUx7tbV+9aZDgGA75pjmE6ltDtJmq7ESC+9HdXS
	wMpNHvrjjOniAds9CDtvHOSNZ9iP23jxPYNyGqxJeusdIOYswa5D3kFAadAmej8xE002mWS8t34
	htVoK+Q6Zk06yS/7LodORmsIiAm6h8OhWktQWvW5MJ17tJQBPvZ7M7akkWkA+hG9nZw==
X-Received: by 2002:a25:a408:: with SMTP id f8mr34262855ybi.281.1548953524176;
        Thu, 31 Jan 2019 08:52:04 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6QNetUj6XJka+z6EDtnmIg/t9rgjicX7pIC6W4mZcZwXe7cw90ySLXPtToFKVmlTWwvXH2
X-Received: by 2002:a25:a408:: with SMTP id f8mr34262805ybi.281.1548953523246;
        Thu, 31 Jan 2019 08:52:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548953522; cv=none;
        d=google.com; s=arc-20160816;
        b=W+5Iyhk0J7hACzlV6DGGpTao4eZnh+OzFOMOKLK2PkEQCEYUsCm4TRQAdV1hgquICd
         4zarL3NaH1ea8TnFMKMfVx/CHugA49F/4PDXw+ICkFxnv3CYAlrfHCxL8vL6o934q4d9
         5zc3tPwlT3XSUuW7l+3q1r0WidItvttBI77vA/2sEFueem7d2piuMFFl0bxVTeRLxMG7
         kEGQEa4lclEBHytXuebENmhqPk68GDAayGT0PdsOR6aVi40j8VO6kYOBJrrc8kAXgIMv
         v+nDqTEN4kj8Hm4o7pTaj9Tu8/5ov1fW+8cVFqfJm6WXOk35LRqB9PTkOc4TXl+PtJK4
         wk5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=96Zby0oLN4dn4XccAslysCBwFxo0rNHCR3wOe7W9OgQ=;
        b=wNksrxnhEDRnwQNpFjfw3OUxB51DEITeefaKG6bV18Z0mAeLXZHYCol/b+3rhD4bXe
         dYwldR3qwkpRuZYGiUajzqej3nDvSk/qPhSc+fRDK1QmgFOLUdBgieOc92QS2hYe/4Z4
         ZQIxf+xg/f9v//yKi2HkibO68wrXqbo1j3i1KPCL65yyw3GfWcTU7/6A8F3C43Frn6tN
         cg9+DhrphW8RceSW+HYEQGdQ2YSFtsZJPJaxJT0gdn6LK5n8z3R+65cvYg00pTX3Q9wN
         WDwbU9yPxxfux8pNrN5xgr8kABh1AjKht85QaccsJPYIGs0Kvj3SQy8R3FwO0Ax3Xlk0
         417Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=p0V3MkQw;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id l207si2964620ybl.303.2019.01.31.08.52.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 08:52:02 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=p0V3MkQw;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0VGmwv4134823;
	Thu, 31 Jan 2019 16:52:01 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=96Zby0oLN4dn4XccAslysCBwFxo0rNHCR3wOe7W9OgQ=;
 b=p0V3MkQww/jirHzgdFHt5ZjfM4+HCLEnjHmE9DvM+MsgfjgErWjI/eJHoi4xSxF1gSg1
 DBonrh8dbPnsjX9/NfQ7bCxWv8+ixe3bwVyiDKyi4pgZAcHbyEyFEsrn9sKSHkREUYY6
 MUo82dRpAvROLQIXykNkqxJdws+v5rMElE5z5vMcCMIcDl/IRx9vEMxuW882qcAZJm3f
 /vLdQl+rJ30w6YIEgsNrvm9gcIG5ABFThw3kbQ67gIuN5wEhwLRKXOR8sG13OO7wdW4s
 w2Ijset2uTBr+1kMGBRFenbY0ZEngEGe8X+IWO/09uFoXtgYEHjcrYNwfX6ASPAW3zQo YA== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2120.oracle.com with ESMTP id 2q8g6rhvjr-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 31 Jan 2019 16:52:00 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x0VGpxWm010269
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 31 Jan 2019 16:52:00 GMT
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x0VGpuTi020831;
	Thu, 31 Jan 2019 16:51:56 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 31 Jan 2019 08:51:56 -0800
Date: Thu, 31 Jan 2019 11:52:15 -0500
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, hannes@cmpxchg.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: Do not allocate duplicate stack variables in
 shrink_page_list()
Message-ID: <20190131165215.i3iotkg64iz5ithp@ca-dmjordan1.us.oracle.com>
References: <154894900030.5211.12104993874109647641.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154894900030.5211.12104993874109647641.stgit@localhost.localdomain>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9152 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1901310129
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 06:37:02PM +0300, Kirill Tkhai wrote:
> On path shrink_inactive_list() ---> shrink_page_list()
> we allocate stack variables for the statistics twice.
> This is completely useless, and this just consumes stack
> much more, then we really need.
> 
> The patch kills duplicate stack variables from shrink_page_list(),
> and this reduce stack usage and object file size significantly:
> 
> Stack usage:
> Before: vmscan.c:1122:22:shrink_page_list	648	static
> After:  vmscan.c:1122:22:shrink_page_list	616	static
> 
> Size of vmscan.o:
>          text	   data	    bss	    dec	    hex	filename
> Before: 56866	   4720	    128	  61714	   f112	mm/vmscan.o
> After:  56770	   4720	    128	  61618	   f0b2	mm/vmscan.o
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> ---
>  mm/vmscan.c |   44 ++++++++++++++------------------------------
>  1 file changed, 14 insertions(+), 30 deletions(-)


> @@ -1534,6 +1517,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
>  		.priority = DEF_PRIORITY,
>  		.may_unmap = 1,
>  	};
> +	struct reclaim_stat dummy_stat;
>  	unsigned long ret;
>  	struct page *page, *next;
>  	LIST_HEAD(clean_pages);
> @@ -1547,7 +1531,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
>  	}
>  
>  	ret = shrink_page_list(&clean_pages, zone->zone_pgdat, &sc,
> -			TTU_IGNORE_ACCESS, NULL, true);
> +			TTU_IGNORE_ACCESS, &dummy_stat, true);
>  	list_splice(&clean_pages, page_list);
>  	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE, -ret);
>  	return ret;

Stack usage stays the same coming from reclaim_clean_pages_from_list, with a
dummy variable added back after many were taken away in 3c710c1ad11b ("mm,
vmscan: extract shrink_page_list...").

But overall seems like a win to me.  You can add

Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>

