Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B14D8C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 10:26:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5DDEE20700
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 10:26:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="UhwgKwT+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5DDEE20700
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5BF16B0007; Wed, 27 Mar 2019 06:26:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE2486B0008; Wed, 27 Mar 2019 06:26:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C83DD6B000A; Wed, 27 Mar 2019 06:26:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id A3DD66B0007
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 06:26:12 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id q127so5404898qkd.2
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 03:26:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=VcAQbbXDBqTw84B+zk/fFVeuAnEQor5PVMnQNwxDWss=;
        b=IgWoFDIE/9kYiDL4J/GoV6duw8F5yFnC61A9Chs2g3wfwIxdFZsYMXKrd3pgS8gWKq
         EFgaRUxJXj6SBZZvrG3i5OnuhhGzoAYOuC46n11SlsQcTepuwRfhI8LyN/fJEs/8+VSW
         luBWvR+Nr9HtFUiQXeDJxqX7u7PhBSnt8iEMxN3ds3GQBd8p/j0oYGfGuIP2I+cpnmXo
         AHjAwEHQrckm/zqC4VSIWxSD6UmdMIgvMLZnlsLd+CccaZtw21RUK/HtLpVS4M0lHGK3
         39dYntZNvW3imOyjDBxCZJ36qzQ+FU5+KvQ5oMBdSKAwZwn+4LWc3HQjA6s4ALr1pKx1
         6UXQ==
X-Gm-Message-State: APjAAAWAwB1usKYpO3kNgu+RyI2mYmYH3AvzhgAh56qigCnNR2h9U6Zx
	WDD/NVYtLNm4ukam2/kmcZbJfsJmC63YnL+l2LYGUubsnHCC0m6dCi2r5idd+DqklHqDtM47E2w
	4iKPbEwmRymPJxCWSSAwZCppeo6QRpGRiaP+1g8x/zfu8L7rH6vZtGkM4U8eRmBsIKA==
X-Received: by 2002:a37:b2c5:: with SMTP id b188mr26825841qkf.120.1553682372335;
        Wed, 27 Mar 2019 03:26:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxa5duEXiXonOBsA2/8ngtGSrFRnUQHwflLiO2w5ZbIWpU2KuOl+pvnn5UgLVikt5CjhShP
X-Received: by 2002:a37:b2c5:: with SMTP id b188mr26825808qkf.120.1553682371580;
        Wed, 27 Mar 2019 03:26:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553682371; cv=none;
        d=google.com; s=arc-20160816;
        b=W4OXL9fHmSrwRcN2MJsjLh+nBpkpn+4ZEa6wuZ0Pc6hsLstFxr0QU+pWbL5pYpHlSw
         LpVSi9Z0OZA16mwj4/llP7ZqacYJomWW+SK3x2dpmCimIzcudJpea0eFmAiecQT2F9Ag
         1bq9Kl2mPCNJZy3+MeKYRcUP6QrSq1Zz+xvgHbCCZYSW16fTySdP/ry9R8JFhKeGldog
         zA48ftjFayf8lpAFKeZMR+2XwOgQFSD7XZN6+PF/iMywAY1MD/ivZQI9P1pt1/MY5H3B
         v5lPjYI7ohvQx5jfY6iODyOdnbQro6hKoADDU7TDzzLGK1YLOWUbxTCbLTULNazRBAuO
         zeBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=VcAQbbXDBqTw84B+zk/fFVeuAnEQor5PVMnQNwxDWss=;
        b=QOZ6W+roFFNi7xOnTl/SxymjudmPtVYASuqWPXNG9Yi4w8Uo1eLesDUr5wsh8pH+Ro
         dRGc5LjsYBscp0tB2gisHFFLh1+YAOO0KQ2BOpVm5yq1X07xEkET1e8XWCF6+q6xlHkF
         RETRgH8Dv+mAZ3wizKOTouGK3wBHnz015r58uypzxqHPE5RnWT0hbgTHek4kOMbEYKLK
         zcmvN++FPxaJvs8joe8HcENsp00NRHZntJPZJr3B4wPfKNFIDPhsVUlN+rJnlMbp2PMj
         e2msLZw+3efXsNR2H78SwWHyh2hHiqfLOceWWTrf/Qe6auutDGnLvSgovVnkD2KQcxEE
         PXdg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=UhwgKwT+;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id v3si303780qkc.114.2019.03.27.03.26.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 03:26:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=UhwgKwT+;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2RADnu4043952;
	Wed, 27 Mar 2019 10:26:10 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=VcAQbbXDBqTw84B+zk/fFVeuAnEQor5PVMnQNwxDWss=;
 b=UhwgKwT+elL7PbO6otWVV9GJzz3Q9ltcXMUC6Cf3ioGRjVBFGcnvLXlcuhUCjuFZB+MQ
 YB2TcIERHKXLaC1JgFHC2k8MWxW6nZueL4/RzPPt9Eoih4yVmxbhCr2GCmgtSIPfLjEA
 lTunQBwIqbEd0+z9bPet0xzW5V6aj4Nx0NFZXLk7lxTfgEFIyQc2TvGUmWu8Zrpl44Jh
 fRrtntiTv2YCgBPKT/LdV+QReAclg9X/2Y4wjVd0Fn7kTTXKFkhLFdPjn/wLPogrv8Zj
 mosjket86+TbqZGY2rZxdMmSHpjWucadXUJdJE71QhXk11rwjjfm7D/lVhLTeRrPEE98 ew== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2130.oracle.com with ESMTP id 2re6g0ymwe-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 27 Mar 2019 10:26:09 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x2RAQ9BS009230
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 27 Mar 2019 10:26:09 GMT
Received: from abhmp0013.oracle.com (abhmp0013.oracle.com [141.146.116.19])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x2RAQ8EE005484;
	Wed, 27 Mar 2019 10:26:08 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 27 Mar 2019 03:26:08 -0700
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.8\))
Subject: Re: CONFIG_DEBUG_VIRTUAL breaks boot on x86-32
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <dca61136-db66-a89e-e79d-679ee2281d8d@linux.ee>
Date: Wed, 27 Mar 2019 04:26:07 -0600
Cc: Ralph Campbell <rcampbell@nvidia.com>, LKML <linux-kernel@vger.kernel.org>,
        linux-mm@kvack.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <4AF9E4BD-58F0-4D12-A495-6192978790B6@oracle.com>
References: <4d5ee3b0-6d47-a8df-a6b3-54b0fba66ed7@linux.ee>
 <A1B7F481-4BF6-4441-8019-AE088F8A8939@oracle.com>
 <f39477da-a1ef-e31e-a72d-8ea1d5755234@nvidia.com>
 <dca61136-db66-a89e-e79d-679ee2281d8d@linux.ee>
To: Meelis Roos <mroos@linux.ee>
X-Mailer: Apple Mail (2.3445.104.8)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9207 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903270074
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000123, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


The dmesg output you posted confirms that max_low_pfn is indeed 0x373fe, =
and it appears
that the value of phys_mem being checked mat be 0x3f401ff1, which =
translates to pfn 0x3f401,
at least if what's still in registers can be believed.

Since that is indeed greater than max_low_pfn, VIRTUAL_BUG_ON triggers:

    VIRTUAL_BUG_ON((phys_addr >> PAGE_SHIFT) > max_low_pfn);

Looking at the call stack of

    copy_strings_0x220
        __check_object_size+0xef

that looks to translate to this sequence:

copy_from_user(kaddr+offset, str, bytes_to_copy)
    check_copy_size(kaddr+offset, bytes_to_copy, FALSE)
        check_object_size(kaddr+offset, bytes_to_copy, FALSE)
            __check_object_size(kaddr+offset, bytes_to_copy, FALSE)
                check_heap_object(kaddr+offset, bytes_to_copy, FALSE)
                    virt_to_head_page(kaddr+offset)
                        virt_to_page(kaddr+offset)
                            pfn_to_page(kaddr+offset)
                                __pa(kaddr+offset)
                                    __phys_addr(kaddr+offset)

so it appears the address is "too high" for low memory at that point.




                                   =20


