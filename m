Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAF5BC282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 23:31:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 756DF206B8
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 23:31:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="hI8t2IGi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 756DF206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE0ED6B026F; Tue,  4 Jun 2019 19:30:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B917D6B0270; Tue,  4 Jun 2019 19:30:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA7D16B0273; Tue,  4 Jun 2019 19:30:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 749036B026F
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 19:30:59 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id i3so14920508plb.8
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 16:30:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:to:cc:from:subject:message-id
         :date:user-agent:mime-version:content-language
         :content-transfer-encoding;
        bh=PYnlYwcrqismRpkktUNEE7wpHvUCY2x+J4QeRuh9P6A=;
        b=drO6JljlOqfPQx6S9S1uVyc8AYzK/pWAlKGsB6kkilVEZ/KsII3Wh716hHZ4eSK4Tj
         It5wVL4Uf+OgfzZvcx0WHFHC5Xs2M6FmpNC9JOhcocw9VdWWygpzBtFI+dxoNbI6W8ca
         rvsuNJZljSVnzwf9oAKGJQhPm1wlU5P7YEBYuoFHN5WYwzF10/6s4fbJ5EuD1mJkBtl7
         EiMh1gj2SYDG4EDmtAqggQaOgmq27XDHRkPxY+WsSxBsQ7uYg67Su5Fy9rWvVfeaTzv+
         Bg3DbO8jb50sry9St4VsZVzwrRCZn8JanozvS+2qlJpm0NuZ+zL2IRdPuhoA0Tb7/Vg0
         U9DQ==
X-Gm-Message-State: APjAAAXr/Z8KGufvVFdblYHL9GJhzYyEJbBet/bgpoar/G5lVLThIpF6
	AmwkNFkFf6T1Ol6CvQfllg93pYny39EnFLKUvi/rJrzGYOOPUP7YclaQzvmdU78M+dnpdvxbHAV
	4h/mWaDpVHEJVfQ5gZyntjIWndCOcRn3Fy6Q+RTLgFtN60iLMy6LKaWlwIhmUZw6LQA==
X-Received: by 2002:a17:902:860c:: with SMTP id f12mr39826556plo.127.1559691058764;
        Tue, 04 Jun 2019 16:30:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxmG6iLqZS/yZENSYdeZuJLk0NSntYF3BfPE9YGYXjKbUTUfG3Y3npV0GvNMUjAYyVyS/JN
X-Received: by 2002:a17:902:860c:: with SMTP id f12mr39826494plo.127.1559691057739;
        Tue, 04 Jun 2019 16:30:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559691057; cv=none;
        d=google.com; s=arc-20160816;
        b=H4rC8p35N0buO3iFRDY8UYJpYbBYi2Slw2DErVjztn6mN6712XUwFXAkwyQs2lv+ZZ
         4chmcCzd+EY+0l1/EwDIF0t+1USOIVCcN/yfx9qX1b5jldjmeqHMBPEfDxSGug1k2a4U
         atC4KYAuGf5QxVhtBX9xzERJ8W9Xx89PUp4X+80QVMiUF60+P2U1wwjFGp7U3ol1XXPd
         L3nC6sfW6UMvUvQqJGH16+CrK4+pgbbUXJf0a+tMLyaDQq37ITifhmxc/5EdPB16yb1f
         pQSf5CUp4y0NWp8YIEHAC6nuH2MKGY6pZiexV7o3gclm3qb7ALa3tOK6ZsE6yAgCFo9S
         ZxSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:mime-version:user-agent
         :date:message-id:subject:from:cc:to:dkim-signature;
        bh=PYnlYwcrqismRpkktUNEE7wpHvUCY2x+J4QeRuh9P6A=;
        b=FIPxOtvG59GDMF61QiKf2g8hRc6KiVJrU+UBXetIIE7sFBjhb5qCMBrDOTdsZEtcZG
         pchM/LoxiEGQjUXkINrUP4mSTvXWVEvtIAqS8i4H5o0tHK7TUIsDIXJuWiUCKdZmhJXK
         S+KCX5F1exX20EDWOl2fPqM1U4p98/KiWy9Q2VkjHeSTyYU4/CMI4uL41WGsnDd6hrbN
         AJgFvm5ftLVlI/SKJGdygvYx8wha7G0xrwapLpuCw8jMwk348nbVHYKGJFdMsvIq3EFm
         +kHF3OhOR/zKagPEPm8JzYjPgWJgHDsf9M+9Qh+lYZwkxgqF8JPLdI1S6mpEOR/mlaxr
         XrFw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=hI8t2IGi;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id a4si23839262pls.189.2019.06.04.16.30.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 16:30:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=hI8t2IGi;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x54NSfYV119967;
	Tue, 4 Jun 2019 23:30:52 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=to : cc : from :
 subject : message-id : date : mime-version : content-type :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=PYnlYwcrqismRpkktUNEE7wpHvUCY2x+J4QeRuh9P6A=;
 b=hI8t2IGipGArSITl/hZ8ilGOQA3SwfM5OFN5CTLViC6D7NnOh8xBuFffelsP3dEI+RMH
 Hdb/7hAU/AjL4ogfjWmXKJ5wJKtn4x7jxQK8G0NAZQKLUlQdM128/bGuyEVtgB3xZ/De
 G6zPw1OrSFKlAVP7XoMFbXi0hBeSswBSWOaAuuSHbFz9yLoTnKRKnJ/3muZD8rT8Vfxa
 jOtDdPEnrPKmhjWQnjVzxw2c7BoSqKr8zeCUpyyZ3onUtqGKnTrNfKmWpYRvS0tR34mK
 LsDzzKYDR3xGHuLMvbF1ag5wQAJ1biwk+nU2UxHV8MemR0+UxtjsYEYF8nA6YJDSSon6 yQ== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2sugstfy9q-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 04 Jun 2019 23:30:52 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x54NUbbL004697;
	Tue, 4 Jun 2019 23:30:51 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3030.oracle.com with ESMTP id 2swnhbvg30-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 04 Jun 2019 23:30:51 +0000
Received: from abhmp0022.oracle.com (abhmp0022.oracle.com [141.146.116.28])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x54NUm5x010464;
	Tue, 4 Jun 2019 23:30:48 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 04 Jun 2019 16:30:48 -0700
To: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: question: should_compact_retry limit
Message-ID: <6377c199-2b9e-e30d-a068-c304d8a3f706@oracle.com>
Date: Tue, 4 Jun 2019 16:30:47 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9278 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906040149
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9278 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906040149
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

While looking at some really long hugetlb page allocation times, I noticed
instances where should_compact_retry() was returning true more often that
I expected.  In one allocation attempt, it returned true 765668 times in a
row.  To me, this was unexpected because of the following:

#define MAX_COMPACT_RETRIES 16
int max_retries = MAX_COMPACT_RETRIES;

However, if should_compact_retry() returns true via the following path we
do not increase the retry count.

	/*
	 * make sure the compaction wasn't deferred or didn't bail out early
	 * due to locks contention before we declare that we should give up.
	 * But do not retry if the given zonelist is not suitable for
	 * compaction.
	 */
	if (compaction_withdrawn(compact_result)) {
		ret = compaction_zonelist_suitable(ac, order, alloc_flags);
		goto out;
	}

Just curious, is this intentional?
-- 
Mike Kravetz

