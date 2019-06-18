Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B65EEC31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 17:33:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73313205F4
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 17:33:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="lJjmI7tB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73313205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28AF16B0005; Tue, 18 Jun 2019 13:33:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23B588E0002; Tue, 18 Jun 2019 13:33:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1298E8E0001; Tue, 18 Jun 2019 13:33:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id E5D496B0005
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 13:33:22 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id e39so13084774qte.8
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 10:33:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=A/pDYyQdkl9FaixeSmyGWxOfU59IEYoWIfih+uEmTeI=;
        b=FEu4aipLzb3dAZd6JblUYyLV71fC3Bk7JhI2oXnU3kXhE1mntnW5c9iXjGFqvZUxfy
         tjQhG419s/C7jZbC2S2Tk7syh8GUcB+p8QU6CdD08Jy1kj7VohjN+GnFG3xhqJScXT2q
         Eu8YTB8/xVJAo1EhTyV/tUyPwv06RRCZehCnm7AB9E44NcwMXTdCT1kV0XFGEVz6ko1p
         UE9B6qyJeDSYZ94xmxklWz19/eU+TQ6NqadblEjpTQY9/y6ZVmw8fKaDxIvcSc7lTD7N
         TLSAzA9lESkE3iB4jkZ/oWFFlZpPPY5+kuxCZ98Ak80JWjJDTA/ZQ6g2qFxjeviQIN8O
         B8AQ==
X-Gm-Message-State: APjAAAX6Y+EBE3nzmcGGJ7Dgw9mm1eMqnH9iiG6zMHU2C1CrkwajxKN3
	/WEzgJlLyh/XLNrB1UQrl2wHbCl36OVxChV6mvqpSwf5sDpAkNsTmC9pOaDDOSHU4l8FjyepG6U
	flCLlAr8S862t2dD0RgSVzV6uUMG4uWH+ziVn9tWBAVKQPyz6EavOvrsmTNgTVynyJw==
X-Received: by 2002:a0c:99d5:: with SMTP id y21mr28428754qve.106.1560879202729;
        Tue, 18 Jun 2019 10:33:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwEONOoMZgDLRDNbp6pUuQjU3l4z7TkgSMqBjc3YD+hn1PTJbrxxxkxS7l4W73AnJ7dgprW
X-Received: by 2002:a0c:99d5:: with SMTP id y21mr28428693qve.106.1560879202135;
        Tue, 18 Jun 2019 10:33:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560879202; cv=none;
        d=google.com; s=arc-20160816;
        b=qAtqeGoZ9/Q5zLMlZTP4tQ3SJi11aXCaN7Xtm9pA3BSOmkRSaOCH8RdLNFJH7l7Eu6
         qr6id1fCv/Qp4tDv/oYCi3CkfehwEP37+5umOI5DWCaJ7QF9SmSvhF/fL+tVD3n0IHeI
         ko3nDn2Ii+DQYZG8VTgfdDQB61rexNSYbZaoSMWSleNAeECoXSF4yrxgNov7ZWupKTnG
         HmnSoxbgpwc+mVZYYuG6KDWPRvzpaRHcu5Va9W3zuaxgaYvFvQ+qVeZ9xW22fYPSgJ8n
         y386Ytmx0tAseYGFASM63q0kkERtngDk9n+Rf9AqlFjXb3NiU+eliO+KAiKhoA56n0AZ
         PhyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=A/pDYyQdkl9FaixeSmyGWxOfU59IEYoWIfih+uEmTeI=;
        b=i845d1vVf4a5ho7TuTrSerb1IbvuKWMT/MoBjYKc1PCyw995jtGi7t4yZH9ur2YRJ0
         u87mPFTRdy8SA5P5NcgU1+h4Kq/lAkptI2dUpbuelKaYVWepBAoQprrwFib+etaF3LUr
         f6axU2ufx7uveW1VFIEDYEh1qPosTZSoCDaw3OcawSeTwH4pz0c9Rkc+6WMneVNct+EA
         4qHnLCdH1fDpNZqhtcFh9tQ263CgqRj42C0I+MeIl49Nef9BJYl7qb09U2PS59L8FFQd
         yilIPDFHuMwgjjELn163zZhS9Dmq/6/iCcNL5of079NQDxwdsCin0thhd2Xhjll8PB2l
         Quvw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=lJjmI7tB;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 5si764897qtr.262.2019.06.18.10.33.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 10:33:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=lJjmI7tB;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5IHTFVh075820;
	Tue, 18 Jun 2019 17:33:07 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=A/pDYyQdkl9FaixeSmyGWxOfU59IEYoWIfih+uEmTeI=;
 b=lJjmI7tBEaYn1cbGnRysa5fMWQO81kczzRYs84lCEtDKkpNI2x3l058vM7adE2wa52LG
 WIStoIGsXKuH61i4DA2E/5/1C3rLqo9QcTrYGOmRPlIz4qSuS9Fk9zKzNPv6vIBHuVAh
 xVbNHKt1uTL7jIWmc1UO1ZNRgiOMyQCrgD/BN/7yOR8EhBb+AQFJl0xrVF7HDpf3YZJE
 jEPQxnnVUfbCSvdlk82HKwBkYLET98Tljv+mTQJtdlgxtlwuv7Imw3WdfZP5MV8R2huH
 vYapILMyj0J313xxK08FESqKkBwKJRWblaLiLoRfx5FuxdivjgPLgSoW6k/C9UerBFi6 DA== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2120.oracle.com with ESMTP id 2t4saqdvdx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 18 Jun 2019 17:33:06 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5IHVZKn162872;
	Tue, 18 Jun 2019 17:33:06 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3030.oracle.com with ESMTP id 2t59gdysch-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 18 Jun 2019 17:33:06 +0000
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5IHX3FN027699;
	Tue, 18 Jun 2019 17:33:04 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 18 Jun 2019 10:33:03 -0700
Subject: Re: [PATCH v3 1/2] mm: soft-offline: return -EBUSY if
 set_hwpoison_free_buddy_page() fails
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Michal Hocko <mhocko@kernel.org>, xishi.qiuxishi@alibaba-inc.com,
        "Chen, Jerry T" <jerry.t.chen@intel.com>,
        "Zhuo, Qiuxu"
 <qiuxu.zhuo@intel.com>, linux-kernel@vger.kernel.org,
        Anshuman Khandual <anshuman.khandual@arm.com>
References: <1560761476-4651-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1560761476-4651-2-git-send-email-n-horiguchi@ah.jp.nec.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <d40a3ebe-6b4c-b723-2750-6aa743816349@oracle.com>
Date: Tue, 18 Jun 2019 10:33:02 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <1560761476-4651-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9292 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906180139
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9292 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906180140
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/17/19 1:51 AM, Naoya Horiguchi wrote:
> The pass/fail of soft offline should be judged by checking whether the
> raw error page was finally contained or not (i.e. the result of
> set_hwpoison_free_buddy_page()), but current code do not work like that.
> So this patch is suggesting to fix it.
> 
> Without this fix, there are cases where madvise(MADV_SOFT_OFFLINE) may
> not offline the original page and will not return an error.  It might
> lead us to misjudge the test result when set_hwpoison_free_buddy_page()
> actually fails.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks for the updates,

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

-- 
Mike Kravetz

