Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54EDBC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 11:35:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1205720851
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 11:35:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="y5OzlUMK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1205720851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A2B88E000A; Wed, 20 Feb 2019 06:35:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9528C8E0002; Wed, 20 Feb 2019 06:35:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8417F8E000A; Wed, 20 Feb 2019 06:35:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 583058E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 06:35:45 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id 43so22522558qtz.8
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 03:35:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=izfia1KiuXgUV8A8PGApopJeIHuPLnpjxsKgv4nNIEQ=;
        b=XZbYNeMNMW10Bx7hMvqW1MjGtKlW1vrL+EhR50P8BZl6T9C+AvjN2zxpMJDpL98P7P
         uWd4O7s4+b6n7BKPov5WSWhFT4aJkSUVCMj9UidYcJLqFibxlkniy5Mup18qmdHF2Q4Y
         mMVfq5J+NiQiufqupawpm0BTLdK1w96Q2qwFxlDULgsfQgo+izPJX6V2GvhI+UvGSCOn
         95yVP91G3ueMi1bH8LumaaQPJUgHksfgb5qgq1+5LANIV+DizH2bl3xYB40wGMl8EkxD
         6l8TqWautmikyK51yR+K9B86cOyXk5ol+rQBAu+PP+5z9dKMHhNJPztqc/3qm3qH3vds
         J4+A==
X-Gm-Message-State: AHQUAuZIMyY05xmklek82fxIODGBzNEMJUWM9MTo/+kQAv5gbxIKqmaV
	dSQqkiZDnkb17ER2EyjsPaeh4qY0NhrIBrRGqatoYG9mwltJPm/HncJaTtPu2FdRNE4J8dFRW2W
	u/pe/Vvclcn342eZyTEKP2nWTecd/5uzfC5akp7Cai1Hkw6O3SMlC8kXiWn2Mxldxgg==
X-Received: by 2002:a0c:b11a:: with SMTP id q26mr12797675qvc.212.1550662545009;
        Wed, 20 Feb 2019 03:35:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZBHcmdCBRCe6/sl5Iw5xOW1Fc1kP4lsoVvxMsanz3URwVJwtFlVirJ5VcSHFDk8PCJI/r6
X-Received: by 2002:a0c:b11a:: with SMTP id q26mr12797652qvc.212.1550662544450;
        Wed, 20 Feb 2019 03:35:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550662544; cv=none;
        d=google.com; s=arc-20160816;
        b=KkRJZBXj1p7g5fZr4PthoN8xC3rMPVaH6OXDkADccAez/vxfO/ytmffAUVVbdj5tAR
         6IspPu7j2ms3oPVn95gtsf9voWJLb8EywqGGU0HDT+HQrwzyh0wm/E5mzISX2BxRW/Gq
         wbSvubb4ziPJJsxJBByh5Qo5FZI8kySaVdlSfkO63kBOl5vSQD5PGwioO0l4aMXan9wI
         E1MCEy1SrgXq4WleMc+D1mRtoDG6RgjoOLsbnr12vG4Y6AlSV5dft1sxISqqtV0qI0Dc
         7GYsQtlsq4MUabGcEGU7/oIDp4d07QKzCk32T0nUI4lGD5wh46LtUfUSxe9ucFzBRRZc
         sbUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=izfia1KiuXgUV8A8PGApopJeIHuPLnpjxsKgv4nNIEQ=;
        b=duBwUj2Wnv+stu89u1SMZQsH9nm66MRUDYueVFj6VKgLMrS6p1z9pK1Y8pw/JESgqi
         pSCpRq56AMwHLmokJgOsbdh0pAGzrG4cvHO5ufDSR6pIpGD+TVbh05oq9fjg9PKmUJoa
         VP7pFsSHBhyBhRpNqnqkasXxO1BtvXxCzoOouJUNmZS2KDgncBiWODbQzATh32okO4cx
         MQFD7rIq4DPndWbVsKq1zoIrBu632tX7yon9iTMUMf7QEAY2l2HW29Y6F913BC9tmgqH
         U16Ldwda+jc5HCwJjP6xyUGuR2qdb/yEAoBdz6XRaY/pVhbTOuj616XQuHnRjO3GXGao
         mLmg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=y5OzlUMK;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id g7si8703473qkd.146.2019.02.20.03.35.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 03:35:44 -0800 (PST)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=y5OzlUMK;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1KBT3WJ014886;
	Wed, 20 Feb 2019 11:35:16 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=izfia1KiuXgUV8A8PGApopJeIHuPLnpjxsKgv4nNIEQ=;
 b=y5OzlUMKcL34moZoGjuZxugW6eYBGvN01DyzDcz5j4fe9Jfu6dIOTZjOLnBLrwI1d644
 5zbUk+/GzwSLsv2Ig6Ss4cTsjkbKT2oEn0vYXMXn1NEsasImkzTz4NQ10Sb1+ICr4Jjy
 e2uLSU8r//T7/Qq7owqDFpkBPXwoy8n0SrhG/RG28/s46bkFbDvuF+SQCeko4u43KPrZ
 CC4T/41kdMMVjY2m+p1fVr2HqP1gFaiI1ocSBKqNfxh4H56BIWPwGKHvrMx2o0dZU/7D
 h0BCVGKp9wyn7kCyCrX+tPX/8BjDhaUetryDaI9180HNnI9H0S2emmpOxn4jquOcWEvV OQ== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2130.oracle.com with ESMTP id 2qp81e95a8-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 20 Feb 2019 11:35:16 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1KBZESM026861
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 20 Feb 2019 11:35:15 GMT
Received: from abhmp0022.oracle.com (abhmp0022.oracle.com [141.146.116.28])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1KBZDKx017732;
	Wed, 20 Feb 2019 11:35:13 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 20 Feb 2019 03:35:13 -0800
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.2\))
Subject: Re: [PATCH 06/13] mm: pagewalk: Add 'depth' parameter to pte_hole
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190215170235.23360-7-steven.price@arm.com>
Date: Wed, 20 Feb 2019 04:35:11 -0700
Cc: Linux-MM <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>,
        Ard Biesheuvel <ard.biesheuvel@linaro.org>,
        Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        Ingo Molnar <mingo@redhat.com>, James Morse <james.morse@arm.com>,
        =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Will Deacon <will.deacon@arm.com>,
        "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>,
        "H. Peter Anvin" <hpa@zytor.com>, linux-arm-kernel@lists.infradead.org,
        linux-kernel <linux-kernel@vger.kernel.org>
Content-Transfer-Encoding: 7bit
Message-Id: <52690905-1755-46BD-940B-1EE4CEA5F795@oracle.com>
References: <20190215170235.23360-1-steven.price@arm.com>
 <20190215170235.23360-7-steven.price@arm.com>
To: Steven Price <Steven.Price@arm.com>
X-Mailer: Apple Mail (2.3445.104.2)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9172 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902200084
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Feb 15, 2019, at 10:02 AM, Steven Price <Steven.Price@arm.com> wrote:
> 
> The pte_hole() callback is called at multiple levels of the page tables.
> Code dumping the kernel page tables needs to know what at what depth
> the missing entry is. Add this is an extra parameter to pte_hole().
> When the depth isn't know (e.g. processing a vma) then -1 is passed.
> 
> Note that depth starts at 0 for a PGD so that PUD/PMD/PTE retain their
> natural numbers as levels 2/3/4.

Nit: Could you add a comment noting this for anyone wondering how to
calculate the level numbers in the future?

Thanks!

