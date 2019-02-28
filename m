Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB5A3C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 12:53:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 97D2A2133D
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 12:53:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="MzWmVYRi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97D2A2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A69C8E0003; Thu, 28 Feb 2019 07:53:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 456028E0001; Thu, 28 Feb 2019 07:53:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36DD18E0003; Thu, 28 Feb 2019 07:53:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0CB5C8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 07:53:47 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id 127so8241289itk.5
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 04:53:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=po1j0KR6Nm5uwMVtLQBfkhGgL9CUys0U0tbhsXrVkfA=;
        b=FIfMzjLrZbj39kgXox8Nwvt089YKI9DoQPk9TBhJjzFGp8aYD7+BD7dyczooN/mIvv
         BMX7d+1HXo4OAIUqGA1iA3aZhEK22amfRIoMSQSL0n8eisj0Aki10r5cPDbHZjZz3raV
         zUiSThu6WoBKXb3tBzkqds2uR6w1p1pdrs0Fhza3Q5UQL69Z1jvibzSIgaP7lSm8drc0
         /t/VNoJaUbFBM2w1+5kutlvtMUuvxdjA6ZKuDUTOdHU4xzrv2BMy7I+zHFCdetGMAF8v
         nbrRclyoOUmG6JpUUs7ZxXmz9KjoH/jiI/MWNQ/qH+VfRnSg598zx/0DaE9fAOi9of17
         9iDQ==
X-Gm-Message-State: APjAAAVzdMgqi6nuNcbMGpsufK8UMwbu22cRXFZ4yyQPEShswzo7oJ/7
	DRsxM/Y5oOr0cvohrDeDLEMsyU4Qmdkeb0mYt5L25lNCBzypW51uGel1TUoVFaKot/dP7iCgrFV
	xmgYFReQ0bFrMbpvkWBPPdlgZhd2z9t8LvIlPmXJnuBlBWzj6qzAsLN4RYnCjXpCkaw==
X-Received: by 2002:a5d:9750:: with SMTP id c16mr5199121ioo.300.1551358426777;
        Thu, 28 Feb 2019 04:53:46 -0800 (PST)
X-Google-Smtp-Source: APXvYqzw2sg39Heanq5QwzMg4DZ+1NEqx+qL22KpTGWcb1J3/5OXJ6Ye8ddlTjkMInO356VkTmT8
X-Received: by 2002:a5d:9750:: with SMTP id c16mr5199088ioo.300.1551358425812;
        Thu, 28 Feb 2019 04:53:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551358425; cv=none;
        d=google.com; s=arc-20160816;
        b=vWlb/GZdYuptbRfiTi/Dyu1FIp1sTJfnts/M1JfYKSmhGiLr2NiPVUidw7a3CS+PQx
         9fxIpPwOvhjCnlBLp9mH4gDfIbU+w9+W+6FfElt14Y8pt30A78dB+JhOkhBwxlm0TYyg
         4fJsPGmFhe1FwjCbIefQ8vGW+ddo818HpeqgtZt4AlCotQ0pn910UFVpuvj8xRuauffc
         Yzk5vTLKNTHFeSdYPXXpnUSiKDm0+XV3apwK0s59E4WrzqoIlDwkdizAd308CLnmU8k+
         UHIOyRGN+VW3/JgzsSKHlqOU9N6q9HIBQM+a0qkLadwZ1CC28qA8yF97uPFJdjk7d5TY
         EoVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=po1j0KR6Nm5uwMVtLQBfkhGgL9CUys0U0tbhsXrVkfA=;
        b=VmtCADresTXjpYhx+ghIU9dBSh54CND7esIlzGQw/vqmKB/oAOz3HaUv0L7+wyfHuO
         8MevohhrUaGYD6IL3hL7VbA1LcLcyn871LkabfrEMcSfpFg1W0siEFbmSb77TJ+2VciC
         VW7tFgukE5j+b7/Q0j+LP1WubLOngZDN9wGAY91wK22aBJ9dFBv1b3GFZxoaaOmy0iwI
         Hafg1OaotLKp9fgI7FSvVnAmngDqaCyo6OA9+6kW9xAEGfCdAIN8qJT8XGVY1T8fb+jJ
         PSDR4zVlj+6QwQG7Q2vfBFBEEAajlIMd7SySQa568rJx7u+ZCxs7f19eSVHA4ZnEmtNK
         XYOw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=MzWmVYRi;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id i39si8748741jac.25.2019.02.28.04.53.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 04:53:45 -0800 (PST)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=MzWmVYRi;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1SCrOID024718;
	Thu, 28 Feb 2019 12:53:42 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=po1j0KR6Nm5uwMVtLQBfkhGgL9CUys0U0tbhsXrVkfA=;
 b=MzWmVYRiBNZL6OcOVaXsbG5quyRc59s7Y6Tvf/uedlIRVDM18oCZDX3SNrxepYg0vrEg
 fYsITvmGnd8z+tlkxGpmY4Xk0KhJkDszLmRIvSQnso+gjUsnCp41ip8+vjYvhrIllD78
 9Z3ZXPeRRdwsl49Ha5+dYHC1qEA/hZYumcKBAGlP+StR8/fOurovOl8oRPiguss9rKYB
 vsFicvcATiTBr2DrtE4yybve2E8S5MjmFZ98GBfnVZrYRLrkUPeWSQvI1tfCGl7XgNg3
 4s2xN57ZxGRgkJ/v0Fq1ZwnLdBIG6W0njK/J4MIogGT9272XsEKfA2hPwrljOd2Ng0pt 5Q== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2130.oracle.com with ESMTP id 2qtwkuguak-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Feb 2019 12:53:42 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1SCrfsI029788
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Feb 2019 12:53:41 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1SCrd6r030348;
	Thu, 28 Feb 2019 12:53:40 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 28 Feb 2019 04:53:39 -0800
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.2\))
Subject: Re: [PATCH v2 2/4] mm: remove zone_lru_lock() function access
 ->lru_lock directly
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190228083329.31892-2-aryabinin@virtuozzo.com>
Date: Thu, 28 Feb 2019 05:53:37 -0700
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>,
        Rik van Riel <riel@surriel.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>,
        Mel Gorman <mgorman@techsingularity.net>
Content-Transfer-Encoding: quoted-printable
Message-Id: <7AF5AEF9-FF0A-41C1-834A-4C33EBD0CA09@oracle.com>
References: <20190228083329.31892-1-aryabinin@virtuozzo.com>
 <20190228083329.31892-2-aryabinin@virtuozzo.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
X-Mailer: Apple Mail (2.3445.104.2)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9180 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902280090
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Feb 28, 2019, at 1:33 AM, Andrey Ryabinin <aryabinin@virtuozzo.com> =
wrote:

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a9852ed7b97f..2d081a32c6a8 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1614,8 +1614,8 @@ static __always_inline void =
update_lru_sizes(struct lruvec *lruvec,
>=20
> }
>=20
> -/*
> - * zone_lru_lock is heavily contended.  Some of the functions that
> +/**

Nit: Remove the extra asterisk here; the line should then revert to =
being unchanged from
the original.

