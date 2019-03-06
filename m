Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6466BC43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 09:44:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13EE020661
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 09:44:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="i8JwL2yV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13EE020661
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A20DF8E0003; Wed,  6 Mar 2019 04:44:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9CD128E0002; Wed,  6 Mar 2019 04:44:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8BDC58E0003; Wed,  6 Mar 2019 04:44:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4866F8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 04:44:15 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id k198so11775037pgc.20
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 01:44:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=Ta2O7DF2/9sJVKubh+k6nXiTfVoZACDiA2PHCH49IPI=;
        b=O8JNkRFF842fvYgbD6JxumF3Up/usAhg8BxuV5EGAP0/25Mdw42YmTkHwP3r5K2Ith
         TGrBA08c1GFmtqGPDpCvJQ2H/M174i5dM0YKBgjogbOCf9PI51ilNlO0+xBta1PR6XkT
         S5x735Eb1Cl0zRRS3VbhRajK70EkpeH3eVGOQhOqn9j72BK98s2Xh/lfN9MVooQo9O5A
         yuKPj6LKWSCb3x1zROa++9m6J5Fsad8lGF1T9oNpeiMWiROqtAtxXMOCAiFNtihM+EUx
         WqzRbBDvTzr4LMDWKHvQicfylkmHoB/JLq3M//lflVoE0nFpP67umU/H6w4SHwKEJOer
         l1Sw==
X-Gm-Message-State: APjAAAVygJT6iQVqGDWEUXgfJpSouKgwqKsSyimpuRmSkvFHpwHM3+Wg
	T8kIA6zmEdNieBgx5okdcfXrcwi3CzSQh0dyUYcOFq2yVmNNcoq0bF45G+o23wkdc0Y3MYBvlVo
	E0/zjomNDfUGog16QkJxYl8CjUJDxIrXbZBL/FlCa7KqTkn3+Bxmc3vLBvkCmcSGisg==
X-Received: by 2002:a17:902:6b03:: with SMTP id o3mr6023267plk.126.1551865454914;
        Wed, 06 Mar 2019 01:44:14 -0800 (PST)
X-Google-Smtp-Source: APXvYqxpKtPLwSEsu0aOSxgi3KDL6IyQ8/aXMhN7a/MlkIAUJNu1nPgohT1EqE5YeVy+/z6Df0vY
X-Received: by 2002:a17:902:6b03:: with SMTP id o3mr6023185plk.126.1551865453851;
        Wed, 06 Mar 2019 01:44:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551865453; cv=none;
        d=google.com; s=arc-20160816;
        b=CaeZ6sQ0yrTdVDQSqNCE1krPSvba+agvzLM+pNoqKwhoAJ19KZAo6HRXjROOzpiyxu
         PBe9iYLQOWqGoHWtJkwr4c05WOs5DObOlKVzvqPuLHuik9RRg31Wa9WSa9TJXRXUOfOy
         1ApRdvb8JztAuEi8egyXE2kB/a5aNl4mkZFJDuP9r9Q4YjII3Z0Di5Bt5yP0NpRyPb+X
         T0KFIhCpjAjW+xAhlDX6xP85Qj/LZiAu9xmcv+w0zwBDkDoKEWCDX800K+lmE3RAlNYZ
         WxhFYTIPIqIoXEJ5bKDQ16YJtxxGU3D2DeGDBgsj3lJa7LsisIqPbaCRYaSZ1FsWs9M4
         BD8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=Ta2O7DF2/9sJVKubh+k6nXiTfVoZACDiA2PHCH49IPI=;
        b=nW7pe+stwZ2u5R7tAhy/YdzzOvwR03CfbQTlZ++pKuR0svGtDSuVcW3uPZ2gifqp1H
         otEs87bB/6w4vWjPNk7zd2UVpeRvbSw6Yaz+syIKBwqVqp7OmD6cYw8+Nfzr9SLuWo2+
         oI5jyUSmuoIOXzLk4GvprbwJATFboyYC3zT49oC+aRPMpw6ef7uZr/9oMEcZffc1ayp6
         i4/sN6UCau127bSuIgA1KgSgkefAGlN9XMDNAW04Z/98KCLiQ6YabFQ+Ii1Juhot/8OY
         4wN8S/7Ax1H6nkebG6OZePr6rs1/C+rQrVHZYLfORx7+FDeQAgcx6EiIv2LUaQB4/ALV
         gukA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=i8JwL2yV;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id n10si1071280pgk.36.2019.03.06.01.44.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 01:44:13 -0800 (PST)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=i8JwL2yV;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x269i5wd178554;
	Wed, 6 Mar 2019 09:44:09 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=Ta2O7DF2/9sJVKubh+k6nXiTfVoZACDiA2PHCH49IPI=;
 b=i8JwL2yVjtY3nbaJfOkHpuZZqqbEnDoZuL9jVH5TymH/qibTUUF760TmpB2LtVPk0AGH
 fIBrsOvPtWiyiV1tOqiSQslp3Zl5CaRF8ge0PT0BPI48moyolfqlQlFHwOROSu3GL1Rr
 kvxtOR09Ab5dz9smV9x/HjKT0s3ys3yOs4ffHxdCIGD/KUDW/dBXkLo5vYhBfXNe3Yzg
 bmxGuRNczS8MzmBmjqJ+1rYSTCbTk/NV88YuEoe8Ox7Hwi5F4MlgHyvzvnR9qxDnteUi
 1Q/+3wwZKDDBFk2JVdlAxZwKxOhV07j3nX9FOZc4nukP+Hm5CvLJk96k/8V/cwbU1zui fw== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2130.oracle.com with ESMTP id 2qyfbeb11p-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 06 Mar 2019 09:44:09 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x269i7cm018805
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 6 Mar 2019 09:44:08 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x269i6XL028425;
	Wed, 6 Mar 2019 09:44:06 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 06 Mar 2019 01:44:06 -0800
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.2\))
Subject: Re: [PATCH] mm/filemap: fix minor typo
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190304155240.19215-1-ldufour@linux.ibm.com>
Date: Wed, 6 Mar 2019 02:44:06 -0700
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        Matthew Wilcox <willy@infradead.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <D730117D-A44D-4380-8E58-E809A86BD245@oracle.com>
References: <20190304155240.19215-1-ldufour@linux.ibm.com>
To: Laurent Dufour <ldufour@linux.ibm.com>
X-Mailer: Apple Mail (2.3445.104.2)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9186 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903060067
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


> Cc: Matthew Wilcox <willy@infradead.org>
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
> ---
> mm/filemap.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/mm/filemap.c b/mm/filemap.c
> index cace3eb8069f..377cedaa3ae5 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1440,7 +1440,7 @@ pgoff_t page_cache_next_miss(struct =
address_space *mapping,
> EXPORT_SYMBOL(page_cache_next_miss);
>=20
> /**
> - * page_cache_prev_miss() - Find the next gap in the page cache.
> + * page_cache_prev_miss() - Find the previous gap in the page cache.
>  * @mapping: Mapping.
>  * @index: Index.
>  * @max_scan: Maximum range to search.
> --=20
> 2.21.0
>=20

Reviewed-by: William Kucharski <william.kucharski@oracle.com>

