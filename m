Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 705A4C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 11:09:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24C46257D2
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 11:09:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="u4F0Vrc/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24C46257D2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D0596B0010; Thu, 30 May 2019 07:09:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 981996B026B; Thu, 30 May 2019 07:09:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 848916B026C; Thu, 30 May 2019 07:09:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 645806B0010
	for <linux-mm@kvack.org>; Thu, 30 May 2019 07:09:38 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id n24so4387339ioo.23
        for <linux-mm@kvack.org>; Thu, 30 May 2019 04:09:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=YCfDGCrbkbS0YzG5aLJic/fCahkN+gvlIX71eGLwvvQ=;
        b=laDFJjoWnEsODAY1Ov+iTD4cCo8ZQpO5h03okieBlaJ4Es+2NVivufoSWkEg8eSF70
         DYVLN4Bvv8TqFgthGVxf+w6Vz65JhDivt61fb905T+CX88kjYfv5Jk4ZIYFbXb6uX9Ad
         kzUb62/mQfkSRrkzVeVpyTbPpN0ePKDijc3bQ8zmFMGYtqhTDNBR6Ix7mXGD8eZT9qGG
         Zz7Pjxyrjm54srpN4XHdq4qD2VCtt6FSBtHKlTvInoIv93lYN04/xPT7HxIuoQVz+fUw
         2Uhq2O0J8D4O3UD5OzJypy2BzIK/mcojlA3ZraJLsDrnRF4DApjrfk7gCDN0OzL8d4hc
         ixzQ==
X-Gm-Message-State: APjAAAW9mMmR82jcGDYBdUx3hXglcJ7SjNJp+eOC4jzAask/XItI6BxG
	SHwcAu/ymMU//ySo8entyCsAqqh+yUZLDnWqDSaJfa14PuOCY+vv2VeaQ/s3j+j0ZOqUVal782R
	lNipRIgl7M/bYZ3zHQIx4Pn6ZsW/QFolzFoqKRBiImLXA+By9+hwdSnUaovm1Otb3Vg==
X-Received: by 2002:a05:6602:2296:: with SMTP id d22mr2136560iod.209.1559214578180;
        Thu, 30 May 2019 04:09:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyc6xLTzO/DYaoj4SaDGb/3z/wLFKTNFDTITozUy5wgOpI2QT0cthPHY90VtZ4fggxrbR7k
X-Received: by 2002:a05:6602:2296:: with SMTP id d22mr2136510iod.209.1559214577217;
        Thu, 30 May 2019 04:09:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559214577; cv=none;
        d=google.com; s=arc-20160816;
        b=p4DfqYALDcIkXZIiuBP2lZSplL/UBKua5iyJDkVWLIRetokZnS4JGI1WIW/Ye16QgZ
         qlRsrJ++MO5ImCm+XN/cSjie9hDSFKG1wMfeP4NLwwhDIxwzYYfaGR1c0obDrhbWHekW
         L7kjVA8kid5qVS6zaog0FoAtsk1qx3rVekfGLA1H7z3wdJLgPw4BOFfU05EcSFlyi4VN
         X1wED2BepK/5jlx4qbqpE3RxXk19lZH7TeK6oAzJ+eNCzrotV7k1k6UTqKpGeI/58JIB
         KgWnBi8H5uzxKrjUH/249hXeQszRf/GyEh1QyBmkSkChDCwDzUPDLlvPUsxfdPVvH79h
         CkpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=YCfDGCrbkbS0YzG5aLJic/fCahkN+gvlIX71eGLwvvQ=;
        b=khxUkUicEHRLbgt59OfYxjTWmSjOguojUvlMgb3Zt/LzFBhXCNcp3ecsm2wxCg8o9O
         Q7JauyLnnFNx7LIz4i+6VgIpthO70g6Wzvl1tqU3UJJnIH3taBtbj5hAZsm96OteMKsn
         m1QnKQx2E9ZuAHuSBnwxK98ilULaxbIqNcK7AwtgeRx6AySnHr026JDWdYeppu4lweKm
         HFkrz1guOI62SpVPZKIGxrYFuS2gFSsMm37SI/ijHCsHO7d8krijKpjf7w4jrD8KPolz
         KQA6CaRUhbmMiNc0wRa/PIDGhKkuT9Xdh2bqc1ejufnwaNf5YrS7Fskoj2ss3hN9Tlcs
         /C9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="u4F0Vrc/";
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id v3si1652122iot.133.2019.05.30.04.09.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 04:09:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="u4F0Vrc/";
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4UB8pSx193271;
	Thu, 30 May 2019 11:08:51 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=YCfDGCrbkbS0YzG5aLJic/fCahkN+gvlIX71eGLwvvQ=;
 b=u4F0Vrc/ic1PGIu0LqZqq8jbY5MJOpHhRMgBPVAZ8jxeIyYCupZPqo32+6EVKnq32Ufx
 gIBRlsxR7JUKj035DCe6EoN57oV+xmXDQl5X0NcMUp9cexxEcuS/EpvsUha0LTLnBvKQ
 /emUELgWHhZ96/z2L7+IloQ5afZT32gZT0F6eE0N9aWmY1ukfQJ9xqkLjwmu0Gypn+uC
 LeVyaN47Io/P6TqxhYel8yGbNrsDrE1XUBJ9DaLMmQhJQAHOuZg1jKfBU9DGP0XoyB5d
 F/SqFMAd9Q1cWD1RKBu+NY9PuOGBlYeJCkdZp2J8TAEofrjUx+/luOLPCWWc2ELXXIAG Zg== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2spw4tqd0w-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 30 May 2019 11:08:51 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4UB8Pwq175460;
	Thu, 30 May 2019 11:08:50 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3020.oracle.com with ESMTP id 2sqh748cxn-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 30 May 2019 11:08:50 +0000
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4UB8kmd004283;
	Thu, 30 May 2019 11:08:46 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 30 May 2019 04:08:45 -0700
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: [PATCH uprobe, thp 3/4] uprobe: support huge page by only
 splitting the pmd
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190529212049.2413886-4-songliubraving@fb.com>
Date: Thu, 30 May 2019 05:08:43 -0600
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
        namit@vmware.com, Peter Zijlstra <peterz@infradead.org>,
        oleg@redhat.com, Steven Rostedt <rostedt@goodmis.org>,
        mhiramat@kernel.org, Matthew Wilcox <matthew.wilcox@oracle.com>,
        kirill.shutemov@linux.intel.com, kernel-team@fb.com,
        Chad Mynhier <chad.mynhier@oracle.com>, mike.kravetz@oracle.com
Content-Transfer-Encoding: 7bit
Message-Id: <6D76CB61-CF13-4610-A883-0C25ECC5CFB7@oracle.com>
References: <20190529212049.2413886-1-songliubraving@fb.com>
 <20190529212049.2413886-4-songliubraving@fb.com>
To: Song Liu <songliubraving@fb.com>
X-Mailer: Apple Mail (2.3445.104.11)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9272 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905300085
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9272 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905300085
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000044, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Is there any reason to worry about supporting PUD-sized uprobe pages if
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD is defined? I would prefer
not to bake in the assumption that "huge" means PMD-sized and more than
it already is.

For example, if CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD is configured,
mm_address_trans_huge() should either make the call to pud_trans_huge()
if appropriate, or a VM_BUG_ON_PAGE should be added in case the routine
is ever called with one.

Otherwise it looks pretty reasonable to me.

    -- Bill

