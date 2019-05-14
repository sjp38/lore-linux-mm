Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64749C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 11:56:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 173CA20879
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 11:56:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="JMdp8P8j"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 173CA20879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E3E06B0006; Tue, 14 May 2019 07:56:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 994CA6B0007; Tue, 14 May 2019 07:56:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 883056B0008; Tue, 14 May 2019 07:56:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 66A846B0006
	for <linux-mm@kvack.org>; Tue, 14 May 2019 07:56:06 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id h189so12216987ioa.13
        for <linux-mm@kvack.org>; Tue, 14 May 2019 04:56:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=2h7qN20uj1mfv3QLUgyx27DHKcW4BdPIEEbu7qYuSi8=;
        b=Brwf7iLOE0q4XC6uGli6QW++Jtzcd/2M+WijkxPCUlXNUW7dJy46zQxLdhPV1s6F+R
         LyMhMyb4mvLtN9bov0Hl18oQzxFSsYolQkNnaK8cqLjMgJBNQaEq9VM257BmL+vpsi4Z
         Gw06igOFRLKLRZpxLqy8YdYuFVBDL6nmDYr6z7LDp/FP11x1SSCTBiX8dU0VMdS7U0o9
         ZNDJ54Nb5h5zf6rHa42s1NVIBBagVaHVLMWtVSb1DR46JWikU5X/v5Zh9pv2iZ6IiVff
         VIvlS/+CSxPMNjELRdONKfS8jBnliTOFCh7jcFt4Iw/ny1UgG2T4dp44cRVzM8gZul7B
         y/PQ==
X-Gm-Message-State: APjAAAVQs65LbGiVG69dQykVZe/U+SJ9pLOd7wQf389rXo6bUcTWKQn+
	5rf7ZJNk+ZIQ6Q2/lhM0o5wAGsv/Q9YNoi0/Qegf7/VOEI0l43/Pl7+ih5RzD4pU4R1EffRG5Tf
	myTnGyn09gi0680ryhBrOvXOvF/PgYbaL85cQ7wH8mCyal2uPOt4HMlH9HnjBWWpQUw==
X-Received: by 2002:a24:5a51:: with SMTP id v78mr3353725ita.49.1557834966205;
        Tue, 14 May 2019 04:56:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyDY1gi/sOgaC5PZoFFUdgYNAMTZFt0A/TCKYof/VBEYW14FO6nGJKmkMt3kxnf9rFYrUQE
X-Received: by 2002:a24:5a51:: with SMTP id v78mr3353683ita.49.1557834965571;
        Tue, 14 May 2019 04:56:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557834965; cv=none;
        d=google.com; s=arc-20160816;
        b=DbTuFTAYDfx11vZ/6cXdwI86z24kDyURHvfuw3NjE7bxSylqX2HoXeAMUBrDaYxRVn
         AAkRHN66bqQb/SNI4dMFpsJk7ER3DTLz3ifStrGX6iJ4Sv6Ksu2YghZLHySUk9285YLM
         TakJlNUH++1kYm/EkVugTCxo94FC17HR+VzckfSGCBl86q44dsGI6aPAQE5tEYL/WMHr
         PCfTjn/AejVnXPmO34XeRYcvuxcxJON/c7rqE8oKeXHA4rDQAKVpNhfYIVjQ8gCabTn5
         Ze6CXXn2q54MA90kkZcbhWN8YQmdE82cqOAlPPjX0DDe0gGHBvDbc5jUG768EHnoiw3e
         QZqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=2h7qN20uj1mfv3QLUgyx27DHKcW4BdPIEEbu7qYuSi8=;
        b=bM00i9xIRcNedEayc3QFu9Y+5jrw8J3hhwHTeuY7f/ZG0mvwzWvLKA0Dsv+r0yHa0g
         e0cAVXO+xo35Tfyse7JyG5Yw84hLtCUmErU7Bpd7fbF/8SJ+EsqnE2cKVdH0a2fqML0i
         mT8nie5+S1SWosrNCL5X1mGTvNJ/FhGiZ7WdB2TbXNQRuShcy8wNDkkHGJtCeA05Okz7
         0LrCx83zAPd5/Ia474oJCqiwYeGAitUtgCvYMJJ/DwrmosciQi6M26i+Wj/dHgOMKtP1
         qFgOIl3942sFb5fhKE0Xy9He5DUN/N71l61l0iEIdaPYMX7aB+nNLBTN+KjorUGhtBEX
         riEA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=JMdp8P8j;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id y81si9148813iof.0.2019.05.14.04.56.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 04:56:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=JMdp8P8j;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4EBtdC0025694;
	Tue, 14 May 2019 11:55:50 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=2h7qN20uj1mfv3QLUgyx27DHKcW4BdPIEEbu7qYuSi8=;
 b=JMdp8P8jsf5h94rLazmh6AlI/FTxzyBSN6n77ZT6tAtRLi5hZhUfWV4KFaQ1paZbCJew
 dau+s0+Bl7pUwVTJEFoL8xiR4bf2WQjWWkmToNnPdc9/SZEWxVX7Y9wHDfwFxgxNvA40
 4uqHCJGCxeu2J+HrvSKJhGjvh0y2iXAjg80ICRU/9V90LsOgO7rQkf+iQJzQQds20FMS
 oEtb9tTJZe5VMe7po0VDokhjghqDuFOdu0e/yLvNxLPri9JXjEWqMQ4hSOA+mnBbZcYH
 o6MKzuq2mEvhJgw1Z+1rsuVmNdQAk4l48D6Ga6eMU9z9UZnm/HU+gBYe9SVXezatP6Lq yQ== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2130.oracle.com with ESMTP id 2sdnttnc47-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 11:55:50 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4EBqB32051268;
	Tue, 14 May 2019 11:53:50 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3030.oracle.com with ESMTP id 2sf3cn71jn-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 11:53:50 +0000
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4EBrlLv029327;
	Tue, 14 May 2019 11:53:48 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 14 May 2019 04:53:47 -0700
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: [PATCH] mm: Introduce page_size()
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <eb4db346-fe5f-5b3e-1a7b-d92aee03332c@virtuozzo.com>
Date: Tue, 14 May 2019 05:53:46 -0600
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <3C1C665D-0C89-4C3D-A6B1-5ED83B26EEB1@oracle.com>
References: <20190510181242.24580-1-willy@infradead.org>
 <eb4db346-fe5f-5b3e-1a7b-d92aee03332c@virtuozzo.com>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
X-Mailer: Apple Mail (2.3445.104.11)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=773
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905140087
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=821 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905140088
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On May 13, 2019, at 6:43 AM, Kirill Tkhai <ktkhai@virtuozzo.com> =
wrote:
>=20
> Hi, Matthew,
>=20
> Maybe we should underline commented head page limitation with =
VM_BUG_ON()?
>=20
> Kirill

I like that idea as well; even if all the present callers are =
well-vetted, it's
inevitable someone will come along and call page_size() without reading =
the
head-only comment first.


