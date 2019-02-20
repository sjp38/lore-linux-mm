Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51845C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 13:18:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CD1320855
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 13:18:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="4yN4rfLs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CD1320855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C8ADF8E0014; Wed, 20 Feb 2019 08:18:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C13068E0002; Wed, 20 Feb 2019 08:18:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB4788E0014; Wed, 20 Feb 2019 08:18:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6FAC88E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 08:18:54 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id x134so18709129pfd.18
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 05:18:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=Y7DcWWRY60AZNcq/ZNtKYL+KAnYE/zZmQ1+Tla5ZDNw=;
        b=ilG9+7Yz2D5GGUiizhtlhGXund1V9Duqf6atgoU5fYDEYAQW3Kycw5K+C6u676kpWQ
         9mRIDEQLDHAJxjoV+wy4wfdCVC1fUfg9NR9cmwpQcN+vPrRpcu63l2El+0+gEyjH5In4
         5w3FzKRrXLUvZ7JouWuldypa5zAxVfhwi+CH8ersZRMRljT1Iyly+KUx4lGOyRlTXvDd
         hVN4XzYPm6myqFluKjyAyPCVhJ4FNkZzVi4PPgcaGIX+0acQxKq2pwwfXZTgP7IhR0UW
         sROWA0Wav/cMDTCnG8yupMy5HxGvVFFwsWxow/A/CJuu5Rqva+zbC/IP2u3D7r4hHOXN
         AQQQ==
X-Gm-Message-State: AHQUAubp99yhfp4PO0EsXbd4J2rjAE5nNTO7PyWdN1I9Dqg0Tceb5Ytp
	TDn9THf2OTogwvLsuwWCvNzj6S5fol0+6q4dzD4awi4Lgt1JSntFb9EGJNYEP+CZbY6EkrwK3c3
	+r+Dpf7krg9K+5DDMcUvsR3DXXoO1CT0/Xnhr9GpwTD45QTzsOafW4OfED802ycGpiA==
X-Received: by 2002:a62:f5c8:: with SMTP id b69mr29210346pfm.128.1550668734138;
        Wed, 20 Feb 2019 05:18:54 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZhGN9U9zdQ6Pzg0KIp17/zxFejOrSC4hTGSp88o0Mqbe2rrvxTBbJo2B87Cmxi/ALe8eGJ
X-Received: by 2002:a62:f5c8:: with SMTP id b69mr29210289pfm.128.1550668733308;
        Wed, 20 Feb 2019 05:18:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550668733; cv=none;
        d=google.com; s=arc-20160816;
        b=obEkHJl8qGdL79ThlMX0xL9CRsaaG/h/6s8IlABOK52a5W7qCXdM4w1GBxmRKpMElF
         BUmnDEr/Ty9t5mJykBB8PKgcPxrOSToxsRcUs/Lf3qmL0QC90Nl4yk1dahWSYuMIO8j+
         9lthpmkaa+vPOO0hE0kTcRTkdVVnBMyp7QkbY46/xulWBdBPlAWhGmtT+SMGP+jZS3ZZ
         DOdSsilNc00ibow+MxmJpLmcjeJEmKEzI+xVhn2kiZon3NwSNvlcODk2xrnreHu8aH9b
         UlsCvq69suBVAz4A+VO1RoOVfqh9vaEe0VPe1rvKsHqyBAuVLKZDVG2hZHguM0l+Uw1X
         A3Qg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=Y7DcWWRY60AZNcq/ZNtKYL+KAnYE/zZmQ1+Tla5ZDNw=;
        b=fWV4RJpquRghjejetd0AFdfOi36oW3sTeXZf3meL2AdVWtX8V2i4sIeK+53nCdhJsz
         dqChoIsb6ngx3+9oLe6pUyDZiTx9YLTHaXTwa1FKs+dQE8PmBrA71pAaz3XDzZo9YmDv
         gMod80l13X69WDgSsR7uwkrX8CUu70lw7mX+OOFf83vjAbzb/+dwKxX9RsVu7ZAYyqLL
         qmxtmufn5XBtysh/4o8SRo8i6uGy0XgZq2Ja1ynvDvfsBV99FQdrWkzd3d1Fbf7/G+/z
         WgZ1uiCt3U87e+bvvyyVq0e0ccZSu+Z6AbcOT+UbI/FXlwuep+HO0AuhP2apQKrH+gu2
         tA2w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=4yN4rfLs;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id c131si2620740pga.358.2019.02.20.05.18.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 05:18:53 -0800 (PST)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=4yN4rfLs;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1KDIpTt099379;
	Wed, 20 Feb 2019 13:18:51 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=Y7DcWWRY60AZNcq/ZNtKYL+KAnYE/zZmQ1+Tla5ZDNw=;
 b=4yN4rfLs5f2b3gTrHZ7RU+TzPeKIjVqGddBB3NfHzVaT8ja7BtVBwVh1Hq7QPFDJY75g
 CKHIg47hXAhAyPMfQsKSAGf2Bx/alkNk5hvvUfQAp8z49l8zHlwcGv5f9TYQaSL6Q8EM
 2V43ir5DtiXZHy8rXA9nL67R95umRll2OWx4wKtrmnTvkYPx/eUrYt8kV3Wvf8sjsuvw
 9M4ta9yaMJMiMXwt2S+ZLblUb+O2I4aQkuiUUcvI0olWgWHESO2pyNmpjwObeSeMYd3s
 +pV+oIeUjKsLM1Z01B4k2+Sm6aoNPWDNqvciwmD70wZXHABAANRruxDHm39Q/KHs8hF4 JQ== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2130.oracle.com with ESMTP id 2qp9xu1fqs-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 20 Feb 2019 13:18:51 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1KDImPf016366
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 20 Feb 2019 13:18:48 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1KDImlm029396;
	Wed, 20 Feb 2019 13:18:48 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 20 Feb 2019 05:18:48 -0800
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.2\))
Subject: Re: [LSF/MM TOPIC ][LSF/MM ATTEND] Read-only Mapping of Program Text
 using Large THP Pages
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190220121016.GZ4525@dhcp22.suse.cz>
Date: Wed, 20 Feb 2019 06:18:47 -0700
Cc: lsf-pc@lists.linux-foundation.org, Linux-MM <linux-mm@kvack.org>,
        linux-fsdevel@vger.kernel.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <E419EE42-B9DC-4612-8B40-5AEBB9CCDD93@oracle.com>
References: <379F21DD-006F-4E33-9BD5-F81F9BA75C10@oracle.com>
 <20190220121016.GZ4525@dhcp22.suse.cz>
To: Michal Hocko <mhocko@kernel.org>
X-Mailer: Apple Mail (2.3445.104.2)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9172 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902200097
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Feb 20, 2019, at 5:10 AM, Michal Hocko <mhocko@kernel.org> wrote:
>=20
> On Wed 20-02-19 04:17:13, William Kucharski wrote:
>> For the past year or so I have been working on further developing my =
original
>> prototype support of mapping read-only program text using large THP =
pages.
>=20
> Song Liu has already proposed THP on FS topic already [1]
>=20
> [1] =
http://lkml.kernel.org/r/77A00946-D70D-469D-963D-4C4EA20AE4FA@fb.com
> and I assume this is essentially leading to the same discussion, =
right?
> So we can merge this requests.

Different approaches but the same basic issue, yes.

