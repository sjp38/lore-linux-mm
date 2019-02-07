Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4648BC282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 14:18:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8E182147C
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 14:18:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="nHjqM+7E"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8E182147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 56A718E002F; Thu,  7 Feb 2019 09:18:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 519DD8E0002; Thu,  7 Feb 2019 09:18:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 409AE8E002F; Thu,  7 Feb 2019 09:18:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 17F798E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 09:18:32 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id w15so30236ita.1
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 06:18:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=smiKLs+cXc5LMx4HvLOBDz1jT3Yqh3XIgxIM6aPMX8Y=;
        b=FsEWQIHFlx0yeH9SQW19Gz0MKgb4IUIcdJjgbI+0fPXQ2iOPvY6QwLgnJJGSuT26EX
         v+W1IfQeW7w9Q5eMi54eBgCipxl7q2nmAFOJb9ruhn3Gi5HWPGy0IjeQTovaLOd/oU2O
         elCG4EjiHGu8xRCX7h9aaV4tKOFqY84E6P37pIhntbe4FPazbhYy+V+hskT0rLu5xB41
         OPrZgJHwCzPoqB/ZZ2zclV9PPDkUXN8mhX7dY/bbV8FFOPiP0KRl8kL4Es0hdq4zTTEn
         Xvgt9jErOiLsQW4essb0mRKBpd9PEpV/koC+nDMFhwW7BbrrxWfK0pWXugARLu2kHxC+
         CzXA==
X-Gm-Message-State: AHQUAuYmpxopevz2ylA+sSywC7/R9wGrc9I0KHD4hlOFmwdKt4eJIDPt
	bgIsnBsX212ZcWAHbLj8OBZwgY8ISSjSmaNnHFSbLELreEuM1TXOZ+q5Wt05ORjcNiy+yJmSAmX
	lqNThhNeSnBUPE29xJ8ZXUxiuLT5mn5uYIgVaGGsivxv1F2WQ7CEzBpFzY5ueWl//Qg==
X-Received: by 2002:a24:5608:: with SMTP id o8mr4927221itb.35.1549549111755;
        Thu, 07 Feb 2019 06:18:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZogHuV2sf4ArUNUWjlMgUkhKrgBTdQMGqWJG/23Z+zmtViWt8MOQsJ4SQBEmyScVPPOBZp
X-Received: by 2002:a24:5608:: with SMTP id o8mr4927174itb.35.1549549110958;
        Thu, 07 Feb 2019 06:18:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549549110; cv=none;
        d=google.com; s=arc-20160816;
        b=NESRFcX3ShpkkPXyWUkSbXVIwJI4EJRXcz2SQ5rR6Xlf0tFpYpDWG1kmcKEgmij140
         ZL+ErKbSGx1En+7inZ3buqUAUumL+obwndmmPlbtcHhPMnnjmwsRb6bHVohEEF5ONRyJ
         pDEwb74qvssksEfPRu7yPTj0H6MQ7W+2+62RFDr+ArcUgZQHNJqoO5IFT1lEhEVjkqGZ
         JVpRRi7k/tPDcch8WnLBK3fLX8LJfr6O7S2yCQ+7DAaX667bT2GLnbVMTS8JmKAyXYKp
         QbxzXl+0iNe7Zopow1JYfc+CvMOqTKDZpHnp8f7FXXO0gfXifKK3jQKxaOM9WSwQrgmb
         uxnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=smiKLs+cXc5LMx4HvLOBDz1jT3Yqh3XIgxIM6aPMX8Y=;
        b=jWrhx2s+B1aMRPTbpaDVUTWF3fVlZywLEy+ARC7LEi9dQsdzBkpAFLFqBn5RLrt6iH
         dxxMvVHj8jtugXPEO7ykP+w5htLnvvdG5188PR7L+Eejs7momi6Ogm0Ybl/RMcRXFEko
         DeRzJ6+EiSVhrVCZzOZLXmC6shVWkGMi9HEmrhcSyZd2P3B7HrsDf/3g6hzdkoIBDhh1
         b8wV5O5/pHJa2753wFJRvBfFsOmSjM5LoZpsgZgW1wSXWrg4OCmuKKVFHFtWEkEkBCpN
         U3/UVj1m7QfRQVy9SqoHYiTrqn/y+1j1Chxf/UhoedY/dSDAzRzhBHhd02YoJDzVxKq8
         pk4A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=nHjqM+7E;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id d15si921959ioc.120.2019.02.07.06.18.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 06:18:30 -0800 (PST)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=nHjqM+7E;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x17EA1vn164179;
	Thu, 7 Feb 2019 14:18:25 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=smiKLs+cXc5LMx4HvLOBDz1jT3Yqh3XIgxIM6aPMX8Y=;
 b=nHjqM+7EBghCc0M5C1L4yRW+G7kyU0pZdnZtFod0NT7BriXLvk75UosXH4TICpfh8hjX
 xKQmmOJ63QJCxW5OAAkTZjNRkJeCk6B1NAvuRJVCV8l2yuG0WBbeIEWs7+wKH/zs6mI9
 C24Y7JiVYYyRPxmE8wbLOVFgsX+es6/MztpUllJaiqSWXMZSZyIOOKrF1i+qHjotQj9r
 I+41EGbEe+6BH0tisLj+Td4fVU1VeXMzYK325GJ5auIJTQwCL77hkbeSnRktcRTMSNLA
 aFwRxxgDIhA/KSckGVOyD5G3G+UcQyWWq5gU85jCYKIHRDoEoUTzUw7pcVkHsfJw5eUt ag== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2120.oracle.com with ESMTP id 2qd98nf4wx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 07 Feb 2019 14:18:24 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x17EIIS6006468
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 7 Feb 2019 14:18:19 GMT
Received: from abhmp0022.oracle.com (abhmp0022.oracle.com [141.146.116.28])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x17EIHCc026834;
	Thu, 7 Feb 2019 14:18:17 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 07 Feb 2019 14:18:17 +0000
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.2\))
Subject: Re: [PATCH] mm/swap.c: workaround for_each_cpu() bug on UP kernel.
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <1549533189-9177-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Date: Thu, 7 Feb 2019 07:18:15 -0700
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Chris Metcalf <chris.d.metcalf@gmail.com>,
        Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org,
        Guenter Roeck <linux@roeck-us.net>
Content-Transfer-Encoding: quoted-printable
Message-Id: <1F007F77-805D-43D6-81F6-816E836BF11E@oracle.com>
References: <1549533189-9177-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
X-Mailer: Apple Mail (2.3445.104.2)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9159 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902070110
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Would you mind adding a comment explaining this?

That way if, for some reason, the patch isn't reverted in a timely =
manner, anyone
stumbling upon the code knows why it's done the way it is without having =
to track
down this mail thread.

Reviewed by: William Kucharski <william.kucharski@oracle.com>=20

> On Feb 7, 2019, at 2:53 AM, Tetsuo Handa =
<penguin-kernel@I-love.SAKURA.ne.jp> wrote:
>=20
> Since for_each_cpu(cpu, mask) added by commit 2d3854a37e8b767a =
("cpumask:
> introduce new API, without changing anything") did not evaluate the =
mask
> argument if NR_CPUS =3D=3D 1 due to CONFIG_SMP=3Dn, =
lru_add_drain_all() is
> hitting WARN_ON() at __flush_work() added by commit 4d43d395fed12463
> ("workqueue: Try to catch flush_work() without INIT_WORK().")
> by unconditionally calling flush_work() [1].
>=20
> We should fix for_each_cpu() etc. but we need enough grace period for
> allowing people to test and fix unexpected behaviors including build
> failures. Therefore, this patch temporarily duplicates flush_work() =
for
> NR_CPUS =3D=3D 1 case. This patch will be reverted after =
for_each_cpu() etc.
> are fixed.
>=20
> [1] =
https://lkml.kernel.org/r/18a30387-6aa5-6123-e67c-57579ecc3f38@roeck-us.ne=
t
>=20
> Reported-by: Guenter Roeck <linux@roeck-us.net>
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
> mm/swap.c | 5 +++++
> 1 file changed, 5 insertions(+)
>=20
> diff --git a/mm/swap.c b/mm/swap.c
> index 4929bc1..e5e8e15 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -694,11 +694,16 @@ void lru_add_drain_all(void)
> 			INIT_WORK(work, lru_add_drain_per_cpu);
> 			queue_work_on(cpu, mm_percpu_wq, work);
> 			cpumask_set_cpu(cpu, &has_work);
> +#if NR_CPUS =3D=3D 1
> +			flush_work(work);
> +#endif
> 		}
> 	}
>=20
> +#if NR_CPUS !=3D 1
> 	for_each_cpu(cpu, &has_work)
> 		flush_work(&per_cpu(lru_add_drain_work, cpu));
> +#endif
>=20
> 	mutex_unlock(&lock);
> }
> --=20
> 1.8.3.1
>=20

