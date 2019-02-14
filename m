Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC61BC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 11:18:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 830F2222B6
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 11:18:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="w1WCXLd3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 830F2222B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0FA198E0002; Thu, 14 Feb 2019 06:18:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 081D38E0001; Thu, 14 Feb 2019 06:18:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB0A28E0002; Thu, 14 Feb 2019 06:18:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id B77568E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 06:18:43 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id q185so3386849ywf.8
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 03:18:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=pxT21No+zAo92Lt8izw0UGg1JN7hZwHAao7k9nslps4=;
        b=WS2P+ha4kVLsUeW/jDT8pbAizX4jCuOpypJclBXhv5c0+BtEVaCMwcAt4501PQPySU
         eLBwxpvoTmiSVUxtBsI/CBqIgmynkVPvh8bJgBPta6MKBWTCgEaoepyPh66z2DOpyDDt
         ZXHKHX42t1TTZYxIXXwPREc7gTxgEPQsoTj7PLBDQfvfYrAr0F8A+SbR2LGmrO51fyc8
         GZgAXRml1RoRsixYA3sHLrNH74N0vMcMVL4ms3Cr7jXJ/z13I//GN1xFtWoFpCpumFdG
         nnxvZuy07sagv1rXOYLSKyjtAeIzNvPNCFTHCxQZYmb5S0gTQkTxoEmhgNh4Im5wYgzQ
         65Lw==
X-Gm-Message-State: AHQUAuYwopo3oXQLxRT8EBaW1H/NwdkOlGFVtc//dJVov9GrbUJFkMCs
	3q6B1SXapHjkKrXIWu+NihbjpZsoUKMleOH6Bxy1cixSYOGAEWsv77p6mxSOFGy0QvwggRAFIeM
	4r7QMfuF9QboiMXg5Kx+VMiVVLwrzBubsF1GraNAYfZy4fqwTaOsngv2Ijd52kR5E3A==
X-Received: by 2002:a81:1fd4:: with SMTP id f203mr2440043ywf.422.1550143123380;
        Thu, 14 Feb 2019 03:18:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ/htQ5BNEPoGQzDGV4ABlfGe16IgAiYCwotrzgOCeZ+2ySUXmnEHosErdzbE0QUsXl5fGh
X-Received: by 2002:a81:1fd4:: with SMTP id f203mr2439995ywf.422.1550143122578;
        Thu, 14 Feb 2019 03:18:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550143122; cv=none;
        d=google.com; s=arc-20160816;
        b=Dn4wUej9HaXy+up+ET16pHcpRwkr7+bdfOjCy6I2JP86fpaD9okryaq+5iVO10OPbQ
         GgadM/7PqDzkxC13GGUuaFZDm2C2JMJnrzxNct/GvzgO5NlwrpgqbQgCTFg0Rrz08YJY
         6lNjYkqpqVRuIN0pkKFDhWQBbsabI8hF8SB0hmbFJnHFaUSoqBACmYZiK9ohynXgPcGx
         OTmWq0Xx5Bv6VCuk+d1iv+mukoRFzi0Ahu7J/HSe5wS+SPrSHWGKNMFQnLHClP3D/rDQ
         pSsGEm7enheVjdcksx9yIAuL7gibL1z1+g6gMIHRtcUFEcmw6pjT0wpZh7gUnMSVmPjm
         sbJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=pxT21No+zAo92Lt8izw0UGg1JN7hZwHAao7k9nslps4=;
        b=C/j46eWMxuNDtHJI2oiqJmzHRpa7nVgbwu+BqmpwoakNjWmUytJqXb503Yl5U+o8Ea
         NdO2qTWvcLaUFSUyao7LTSbXjL/8ELrjsW+kyfLfboKc7yRzNvuxSS77K+YxyTwV4gwH
         rg/XrQbOXT2Bvd67p8XAccHMUlwospOq9LkesMqyH3+Pw4XJGnGbmn/MlCu465Og1Wks
         NpXufZN3zmaNo3CMb74R8rD+2fURpNNPy9mNEraY+GTrIpzg0uRkP2y/77/pz40xVc9v
         lTKsrM1VAaWeMeVAYvpASCD/WYIBpEGsUaaQTBdrubIbWkLotQllVfBBouAkULsbdaip
         xUsw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=w1WCXLd3;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id l13si1229635ywm.209.2019.02.14.03.18.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 03:18:42 -0800 (PST)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=w1WCXLd3;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1EBE9IS013286;
	Thu, 14 Feb 2019 11:18:30 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=pxT21No+zAo92Lt8izw0UGg1JN7hZwHAao7k9nslps4=;
 b=w1WCXLd3IIOE4a8WApeNxTUjUJ8gFSeYZv7b8jsilBPlNaFTpx3qeeKAScZH5H990BBN
 KeC3QOcrrGIj+kX1FiBTB2KZyzqXnHWrpETeX2anz+y6KId5Ct+KxYegUXj2bG/aVVyG
 7yqw6uNj8yWGnCauyZKabrZ0RK1aPqI8gyqNj981q9JOODzUeOBSSUWcZwIDIdo0meJa
 vXUSQaSAAkytALtAN9KXxQUaAdNfxYEa1ZsTSl613Dc0RtrB85v18e/kmcXsU/leynpD
 8nZRpyy73ABFsF/rLGnMt5uetm30dtN+WEMGmOXh35GURDYbNNcLwrTXXA1/mYoKKNey qQ== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2120.oracle.com with ESMTP id 2qhree7ehq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 11:18:30 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1EBITwE029134
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 11:18:29 GMT
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1EBIQ7a026969;
	Thu, 14 Feb 2019 11:18:26 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 14 Feb 2019 03:18:26 -0800
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.2\))
Subject: Re: [PATCH] mm/shmem: make find_get_pages_range() work for huge page
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190212235743.GB95899@google.com>
Date: Thu, 14 Feb 2019 04:18:24 -0700
Cc: Matthew Wilcox <willy@infradead.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Amir Goldstein <amir73il@gmail.com>,
        Dave Chinner <david@fromorbit.com>,
        "Darrick J . Wong" <darrick.wong@oracle.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Souptick Joarder <jrdr.linux@gmail.com>,
        Hugh Dickins <hughd@google.com>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
Content-Transfer-Encoding: 7bit
Message-Id: <404C0A0A-F145-4622-B3EB-492D0FFB7CB6@oracle.com>
References: <20190110030838.84446-1-yuzhao@google.com>
 <A7BE64E0-8F88-46AC-A330-E1AB23A50073@oracle.com>
 <20190212235743.GB95899@google.com>
To: Yu Zhao <yuzhao@google.com>
X-Mailer: Apple Mail (2.3445.104.2)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9166 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=859 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902140082
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000057, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Feb 12, 2019, at 4:57 PM, Yu Zhao <yuzhao@google.com> wrote:
> 
> It seems to me it's pefectly fine to use fields of xas directly,
> and it's being done this way throughout the file.

Fair enough.

Reviewed-by: William Kucharski <william.kucharski@oracle.com>

