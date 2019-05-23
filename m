Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 819F6C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 17:56:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4634D2186A
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 17:56:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="MYeBTUtb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4634D2186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D482A6B0294; Thu, 23 May 2019 13:56:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CFA496B0296; Thu, 23 May 2019 13:56:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBFD66B0297; Thu, 23 May 2019 13:56:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9438B6B0294
	for <linux-mm@kvack.org>; Thu, 23 May 2019 13:56:14 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id l193so6086315ita.8
        for <linux-mm@kvack.org>; Thu, 23 May 2019 10:56:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=A2pZI4s+u9hh7wmH1Va7oBclGfZ6CKgBYYy1XL31LE8=;
        b=JOERUzC95RRrTzyOLGHV8QjuPCZ5kmHDlm4E8f5Z1RkyiD1qL/QTaIOABEcQag7t4o
         +c8TBf8t8owVCKiVo9q/TSawfnvN2/A4dVxn/3eKjxwxTnqFsnt25xIexvOCqiofzYAW
         D+79fjXR+k/F4SlGh8ZcNkPYu63Q1Waea20wWNxoyPMYdw4kxTJrgdWBS3tX3Joi66Xt
         tIpGGbOB3A6e6pRMwGN6BL5tULk8eyv/d6/PhoS/GUJy1SpgCHNReYTcNkZ2nIYKqjpG
         cPMBiCFmTMxsYLJtzy2p0IG320a603VsliirT2m9Ikk3W3mvQEsUreJSJ5zwdvmBrS2g
         JrDQ==
X-Gm-Message-State: APjAAAWwO+U6JaoFisY8QoNotCSTX8uZwPFZfSBIw99d+XPuMY+pPAPe
	D1ItCYtJeubTMH7OcD2ratWN3WtUOfjCDdx+cwnmCYdZvXqG5s7bnaP5nnmu96Rwt5NrrXmFxZf
	qVQe6kL7YOC9ZwP88TAIF6layb3SElkuUsGp75FtoXE2ujOhpQTlT6015rLTjylKE8w==
X-Received: by 2002:a24:5f52:: with SMTP id r79mr14397612itb.178.1558634174205;
        Thu, 23 May 2019 10:56:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz7g9Kt2OMShstc2qEzsZOasbWyBsdyIyWCngcrOoIHgGVtNsyitksq8oJoLho8+A3Mkwr/
X-Received: by 2002:a24:5f52:: with SMTP id r79mr14397573itb.178.1558634173584;
        Thu, 23 May 2019 10:56:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558634173; cv=none;
        d=google.com; s=arc-20160816;
        b=iMoZ7uFs2litBZyVC62gzND7fiEAGrkWIs2nzJKaTu9m3ugNY+JgFKFyCULndHg57I
         iD7sHn5GrHzxMu1nGWKF35TmVfrLaE4e4kH3ibyhKvQ/pGuTZZFSlAySGSNWehjyP5DQ
         imNnRGNzAe/Lg7KjZlhIBR7o60n5JWXdvqWc3VhqvbPxUpua9G1UtJWK9yiXSVqlQMSr
         F4TZw0MZRrhrLkm/orahLG+plWg7Z9hOUnh4+jFwTTfl12Mqojm4Tq9/ML8G37wQra0o
         br0e2XT4UXY2NuPm/OYQIYAm37d+hndChcfsg1BnE8Dw4v+MVsw6D1FJ6Ywd86g5NuxH
         6yBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=A2pZI4s+u9hh7wmH1Va7oBclGfZ6CKgBYYy1XL31LE8=;
        b=vnjXryMyd9sgwF3Aa6j9lpKY5lQFFqulVb1wiHOkQ0BXmcWMeYG29osADtskrk28An
         fcpwyW4CJbvtG3Jv4XAsj/ad7KeY7C3AHKnuSm+eBYWutkTPfThZRPYnI+xTGWFJh4wG
         sXarlophKMyNU8MDbmb8Xc4e+1UfCVh7X00ymBQ08bkwjB8SdIhDMS7umCY6sZnPQH/m
         waxUCmnbQtgOiNJK1kdllWzVBcDYd7yDaLJ2WT0jvjc8j54cLNLUVu22ivHlHE5VYPcH
         TcQiweoEpS839g9tpQCKKPoabke6BOwsSNnfSUkACry1AtvmjBW/yVcRj51OhekAfzMN
         8NNA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=MYeBTUtb;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 72si87206itk.58.2019.05.23.10.56.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 10:56:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=MYeBTUtb;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4NHclqt183413;
	Thu, 23 May 2019 17:56:12 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=A2pZI4s+u9hh7wmH1Va7oBclGfZ6CKgBYYy1XL31LE8=;
 b=MYeBTUtb3WYk2cnLAFzorBpTcsDFq3ePYvOCimalM4wunqwDICDcyZeTNjKMhJaDe7AN
 z1EZTFs097G60qWy343QsIOsnljevpdI2teKrZUxECpkTNllVKwvjyEnB3w47w1coMoS
 KArK1fc0CbeMkPCVg1zLYdxglLLR1c0Y/JhGYBwBHnj/Qt3dLCDpjIOSL4rVwUu7ibGG
 dRVw73s+V7tSpQeywv0kqWv8w75vDSWqYGtBgVby8L2eDLD3x4hRWTPHdNBoewHqQHLu
 rnhyUcD1Cw+Dof3S3q1ZHYHY2jKPw/OEoyANxCV8H2ImiM+zdQiBNhE+WO/PkvJfP6T9 +A== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2130.oracle.com with ESMTP id 2smsk5m4sc-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 23 May 2019 17:56:12 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4NHt75B153484;
	Thu, 23 May 2019 17:56:11 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3030.oracle.com with ESMTP id 2smshfd6r1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 23 May 2019 17:56:11 +0000
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4NHuATO026922;
	Thu, 23 May 2019 17:56:11 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 23 May 2019 17:56:10 +0000
Subject: Re: [PATCH] hmm: Suppress compilation warnings when
 CONFIG_HUGETLB_PAGE is not set
To: Jason Gunthorpe <jgg@mellanox.com>,
        Andrew Morton <akpm@linux-foundation.org>
Cc: Jerome Glisse <jglisse@redhat.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>
References: <20190522195151.GA23955@ziepe.ca>
 <20190522132322.15605c8b344f46b31ea8233b@linux-foundation.org>
 <20190522235102.GA15370@mellanox.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <07f97bf3-cc38-6016-b9fc-1dc4efa5a190@oracle.com>
Date: Thu, 23 May 2019 10:56:09 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190522235102.GA15370@mellanox.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9265 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905230119
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9265 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905230119
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/22/19 4:51 PM, Jason Gunthorpe wrote:
> On Wed, May 22, 2019 at 01:23:22PM -0700, Andrew Morton wrote:
>>
>> Also fair enough.  But why the heck is huge_page_shift() a macro?  We
>> keep doing that and it bites so often :(
> 
> Let's fix it, with the below? (compile tested)
> 
> Note __alloc_bootmem_huge_page was returning null but the signature
> was unsigned int.
> 
> From b5e2ff3c88e6962d0e8297c87af855e6fe1a584e Mon Sep 17 00:00:00 2001
> From: Jason Gunthorpe <jgg@mellanox.com>
> Date: Wed, 22 May 2019 20:45:59 -0300
> Subject: [PATCH] mm: Make !CONFIG_HUGE_PAGE wrappers into static inlines
> 
> Instead of using defines, which looses type safety and provokes unused
> variable warnings from gcc, put the constants into static inlines.
> 
> Suggested-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>

Thanks for doing this Jason.

I do not see any issues unless there is some weird arch specific usage which
would be caught by zero day testing.

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

-- 
Mike Kravetz

