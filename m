Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 550C3C7618F
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 22:54:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E57F721955
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 22:54:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="1iF0Hdnd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E57F721955
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 653F16B0005; Mon, 22 Jul 2019 18:54:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 605B06B0007; Mon, 22 Jul 2019 18:54:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A50C8E0001; Mon, 22 Jul 2019 18:54:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2394D6B0005
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 18:54:13 -0400 (EDT)
Received: by mail-ua1-f70.google.com with SMTP id d1so3917910uak.23
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 15:54:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=pRmdzS9FvbplPYn/pmuIE0u50BDdaNqnjGOZR5C4gAo=;
        b=OMsRiQz+BU3uWTUUQ4YCYrrQXNBFU96BaEBhFlCf8HeHejYVUYw3ORozBH4On9fvwE
         XpELEd6tgD24+NYufKjyUQxCKnN4+wItfS84F5nrbbGBhRSiTntbHjp8sH4fYSIFrVlk
         88AzLmnHWgP17CkXBb0Pq6UoGu1rl7EL4bmRMkmRv8c3IgRp41jpKnEaX2t0UnRCQKAw
         SENtRyY2dsVNwRtznEhZu7oqeLIg34/BjgVYZeioT7BRlwg3rrRLj5ei86CucW0C8/zb
         QSIoW5D8fysmsGdvNBe55mvH36aJg9GKVODJ0YGV/8VO85RfK2qNh6JhfYL5w/PWTMll
         70Eg==
X-Gm-Message-State: APjAAAVocgu/qHcggncGFTKesv0SdJWzYL3avfPd2NA2jSTXazhKOpV7
	GxftKsrYrq4N+FJle8uyBTJqTlEW/HCURNdRV6X6R7jai7e4TJMRZyb6nlXJgLuLgcGj4x70GAe
	ERoOV+iYzLy4+twOhoTmDgrkM2r+XHKlvSHb+SO7kZD9p55QmdMTNXnpeKIu02EVSaw==
X-Received: by 2002:ab0:5922:: with SMTP id n31mr43308240uad.103.1563836052842;
        Mon, 22 Jul 2019 15:54:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQlhUQzsahYoRip8USmxslw1yYkPmve4YR6R6vXj/bYWPzQ6rBWqGC5tK/P8SmDgTFm4uQ
X-Received: by 2002:ab0:5922:: with SMTP id n31mr43308217uad.103.1563836052019;
        Mon, 22 Jul 2019 15:54:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563836052; cv=none;
        d=google.com; s=arc-20160816;
        b=CHOS1G3sxJtW8zRhGOkPvi3/ud2r6m6jaIWtjQb+RsJwLd86AQBFumYQCC/024SjW6
         AJSrZXOutdgPVeiZigklvOraQEMqGZdeclfKsC+5xVLvYY+6kGMvkoljqr4TcRr3yG/n
         FbL9UzKD4bVC+Ts7biIGYp5/NFsUJ86c9LFSY74a4HrHZxSjPXyvs5AM63qo92vTIxLw
         YkRh0CZpmHkQAmlnk47SYw3XUSmqcenqJkOZwwn8GDTpsHfMR7jkSno2x8k0uRb61N4A
         7HMUEgL0ZSH/+DRhvf58Z6PL5xRJDVTSboNJcR13iMATgz2TDG6PbIIz6svR4GZ2IevL
         sw9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=pRmdzS9FvbplPYn/pmuIE0u50BDdaNqnjGOZR5C4gAo=;
        b=JiKPvScwOlx7uk7uWYlcJsPSS17TZLab8bRheTXywM/RmW7wZifXQCXqWwkmo1ut+7
         9tff5sEzEMo0Lr2NcsR6CHFsIYIvbKoxTXmi/nBYT3yl6xluvnqmKAdMbmh5qSPQRdBg
         q+cwR4UiU3iKGpad/GFDDW7ueM/+q+PUeIGLXYSDNa4qQfwNra6ea3D7xi1/9sU9DKbo
         CR2bjTZaFz20m81SWaYFY1bVTdki1yHT9ag0OaZaDmfLUTDtfbedap8omDi3wRW+jxZZ
         jWdOpYh0ZM8CHN8tj///iJUD82HUDzI7KILvTLHaGd4xBfucF3I+JC2iyM5hBPz4yswv
         vaHw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=1iF0Hdnd;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id v25si5401365ual.19.2019.07.22.15.54.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 15:54:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=1iF0Hdnd;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6MMhw3W162619;
	Mon, 22 Jul 2019 22:53:59 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=pRmdzS9FvbplPYn/pmuIE0u50BDdaNqnjGOZR5C4gAo=;
 b=1iF0HdndRnRKrJS+GukMAaRu3s7i4Spap6W4l1oi/2f+39+ekwiUZCbaeAe/utEgnTDb
 uyNEJQHuydqvviynMVPvoh/tuWJ6NXGDIkAIiQTruQ5LrdFwufOY+N5E9ftjjkHlkhEq
 tSiT8nBJpS3Cudp04hm5RzY/FK1/Ws6Q2N1qq8eX43Z/nzYzTdN8Wk4iUIvU/fWyiKw7
 Ih254PzPhFBTp10Us6HgO33iilGTztV3EiTtMte5VFXXLCpJ1SN/SNW0CJMlDQJKRjLT
 XXrapx0iCAd4efzNWfGisTOvgghjahk9Lw12nlMxTZ3LQUv7NDUOSEzNChBfSgGLuQuw cA== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2120.oracle.com with ESMTP id 2tutwpa6bu-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 22 Jul 2019 22:53:59 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6MMh27Q109480;
	Mon, 22 Jul 2019 22:53:59 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2tus0bstuf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 22 Jul 2019 22:53:59 +0000
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x6MMrsWk015176;
	Mon, 22 Jul 2019 22:53:55 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 22 Jul 2019 15:53:54 -0700
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 13.0 \(3566.0.1\))
Subject: Re: [PATCH 2/3] sgi-gru: Remove CONFIG_HUGETLB_PAGE ifdef
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190722175022.GB12278@bharath12345-Inspiron-5559>
Date: Mon, 22 Jul 2019 16:53:53 -0600
Cc: arnd@arndb.de, sivanich@sgi.com, gregkh@linuxfoundation.org,
        ira.weiny@intel.com, jhubbard@nvidia.com, jglisse@redhat.com,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <58D68134-E068-466C-AAD8-FA69596E8C26@oracle.com>
References: <1563724685-6540-1-git-send-email-linux.bhar@gmail.com>
 <1563724685-6540-3-git-send-email-linux.bhar@gmail.com>
 <1BA84A99-4EB5-4520-BFBD-CD60D5B7AED9@oracle.com>
 <20190722175022.GB12278@bharath12345-Inspiron-5559>
To: Bharath Vedartham <linux.bhar@gmail.com>
X-Mailer: Apple Mail (2.3566.0.1)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9326 signatures=668684
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1907220244
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9326 signatures=668684
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907220244
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jul 22, 2019, at 11:50 AM, Bharath Vedartham <linux.bhar@gmail.com> =
wrote:
>=20
>>=20
>>=20
>> In all likelihood, these questions are no-ops, and the optimizer may =
even make my questions completely moot, but I thought I might as well =
ask anyway.
>>=20
> That sounds reasonable. I am not really sure as to how much of=20
> an improvement it would be, the condition will be evaluated eitherways
> AFAIK? Eitherways, the ternary operator does not look good. I ll make =
a
> version 2 of this.

In THEORY the "unlikely" hints to the compiler that that leg of the "if" =
can be made the branch and jump leg, though in reality optimization is =
much more complex than that.

Still, the unlikely() call is also nicely self-documenting as to what =
the expected outcome is.

Reviewed-by: William Kucharski <william.kucharski@oracle.com>

