Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 098AEC169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 22:48:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7AE3218D9
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 22:48:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Z6Q+q2TG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7AE3218D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 563C68E0107; Wed,  6 Feb 2019 17:48:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4EA2A8E0103; Wed,  6 Feb 2019 17:48:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B4088E0107; Wed,  6 Feb 2019 17:48:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E54B38E0103
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 17:48:24 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id v16so3038127plo.17
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 14:48:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=6oeYaHpL97KRHrw/SUIRK15B/EH29MQg6WqKzUHlWuw=;
        b=bDXqmwwbM7fm5xfEi3Rip8YEQUIye0OOHcekr2fM53UEWBxug6AyJlJCism/xZIWH4
         uObKTCvO04Dk86oK9woMFJKuTVL8NDMC0FS1XkwsoxvP5VvCyojYO5lp6vXGw08XKqjY
         l29QP4aV6lmTIjKRqYYKn36uoMzAo/aKCQw/+rUW8kDsjqUaRvlDgX/KYa7imjLBnG77
         4zH2OFFkSOfEoN/pv0A/7Ih/apqBSi5H7F/bK7dMmINITSJQkmjhQbOSNLH+7ZuIpngT
         wtV5156atHek982bnDAfOMeZt0xPyXW8kaE+2oZRiw4y45s90+xrPOY3TLgfc9pvMTsZ
         ARbA==
X-Gm-Message-State: AHQUAuYIjfhBPvExvqFJgKxx72oAA2+E7ZuRIwZBYGdRwTeCrwY3sWkD
	qdXuN+Qo0JZhs9sy0PqgLa9Jv/oVaAZBTJLiX0jifIH8dgx3J6sugv6cFtpOU3pzfjrqr5RcIr0
	IcbUjASCOyK26+/JwMedUR26grYcgQ/EdcpprCLDJufuKpnK9DHUo78SPDGmP5x16YA==
X-Received: by 2002:aa7:808a:: with SMTP id v10mr754731pff.8.1549493304563;
        Wed, 06 Feb 2019 14:48:24 -0800 (PST)
X-Google-Smtp-Source: AHgI3IafeWxJCDGDV5cppBOwFV49SghtSTYU91MS7GC/OaDdgRtIcdJpX5VMYz2UjtJ+ItJNW1DX
X-Received: by 2002:aa7:808a:: with SMTP id v10mr754704pff.8.1549493303973;
        Wed, 06 Feb 2019 14:48:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549493303; cv=none;
        d=google.com; s=arc-20160816;
        b=jgT7KlU1nk2E0iRFU/FmChlDYWS0wMCkxUZHczUuRwFS1p32kbDE/4yrYm3YVRsPIi
         dZR7a/YeYVeTfpWKq4chGRtzAIG7MmoqYCskSzzmpZGfVD81T8YdcFLe/8vG6mc1qjMu
         DfeAIYXi/9Krws0AKXz52aB6cwR5RRvIRUy4qU6jLJ+DZn0cDNqpG/IhhBsbSjebTg7+
         rFD+7JAPwgNWSh6yrcdTnaT2Mrkq47nKXw5lV/TEIA4Gzq/x2CaRixyh3Ng5n/ie136i
         Zn5xwyTyHe2MkS+Ctz708bP8aG6yV3EG2zUjvaPPxf1lcSVxH1T0oJCG93JXWD2laRFR
         vlbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=6oeYaHpL97KRHrw/SUIRK15B/EH29MQg6WqKzUHlWuw=;
        b=Kysl5jtGicchP1+ObWn8Hq0KNvMAh5dlQXjagJVfmJlN6ARevmUh1IxatvJz7mqPz+
         CoRVH88kSYY7YcohRJUwm2a+yuuh++tJuQMrwtuZ5pcEg67hcekz+hqTYPJINozEXvVU
         1Ue1hLGJA+YWaxbKycx8uSJvaS3DwT/1sM0RlW+qGM3nurYdfp48jzjtudcU1Cx7I814
         Ni3/HVfZ17FncVDi9hRHNTysFhMcWDwVFFPwq1mV8TPp7hq223H1SHou6yxTn+OMAC3m
         e9V5eOc4UI3HWo7vhs3vANunx4YiCiHI6ef3t6w3Gf3k1Gjm8K0iYyUt4zVxik9UXxsA
         dwGg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Z6Q+q2TG;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id z69si6386293pgz.152.2019.02.06.14.48.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 14:48:23 -0800 (PST)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Z6Q+q2TG;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x16Mi9CI051603;
	Wed, 6 Feb 2019 22:48:19 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=6oeYaHpL97KRHrw/SUIRK15B/EH29MQg6WqKzUHlWuw=;
 b=Z6Q+q2TG9uLsn4fm3bdpD2BJ0wxKL25DCd6F9R8YnZfsv9r8XvUHjOsaDu/de1jJ/810
 xUDlzTfXc2sOMfXb68i5VMjIVzd+lbX0QXDq/sHdyuQ2neP6nWc1EaYrK+O5mCgse4wF
 r20FKNGRqQgc60l2mAaIsg6dDCVtGI2ruR5YuHoLyaD1wI8Ooh3iSf+VTPVU4gseVzU8
 R+3Yp9OYFS/ma+blxT6y6mBE2Ntqh6GK8+fmOCIzeW5nUoRax3Z50NfssDoIWZ54zfK8
 8S+2IvWi2XwCxs/5vl7Tps9ICRRbUmOcnEe4zZZYUYssdWfeFSlzevC7ejapvmqpIsZj pQ== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2130.oracle.com with ESMTP id 2qd9arkwbx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 06 Feb 2019 22:48:19 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x16MmCFC013237
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 6 Feb 2019 22:48:12 GMT
Received: from abhmp0007.oracle.com (abhmp0007.oracle.com [141.146.116.13])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x16MmAMu019058;
	Wed, 6 Feb 2019 22:48:11 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 06 Feb 2019 14:48:10 -0800
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.2\))
Subject: Re: [PATCH v2 0/3] slub: Do trivial comments fixes
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190205040521.GB30744@eros.localdomain>
Date: Wed, 6 Feb 2019 15:48:09 -0700
Cc: Andrew Morton <akpm@linux-foundation.org>,
        "Tobin C. Harding" <tobin@kernel.org>,
        Pekka Enberg <penberg@kernel.org>,
        David Rientjes <rientjes@google.com>,
        Joonsoo Kim <iamjoonsoo.kim@lge.com>,
        Christopher Lameter <cl@linux.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Content-Transfer-Encoding: 7bit
Message-Id: <70B0A145-EAED-40A1-9C3C-2792EC3A5C24@oracle.com>
References: <20190204005713.9463-1-tobin@kernel.org>
 <20190204150410.f6975adaddfeb638c9f21580@linux-foundation.org>
 <20190205040521.GB30744@eros.localdomain>
To: "Tobin C. Harding" <me@tobin.cc>
X-Mailer: Apple Mail (2.3445.104.2)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9159 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=632 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902060170
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


If you need it:

Reviewed-by: William Kucharski <william.kucharski@oracle.com>

