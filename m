Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 65CC66B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 01:22:28 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id o14so17916593wrf.6
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 22:22:28 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s29si913707eds.510.2017.11.26.22.22.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Nov 2017 22:22:27 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vAR6JYFg086700
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 01:22:26 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2eg8tr1xrf-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 01:22:25 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 27 Nov 2017 06:22:23 -0000
Subject: Re: [PATCH resend] mm/page_alloc: fix comment is __get_free_pages
References: <1511594447-3836-1-git-send-email-chenjiankang1@huawei.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 27 Nov 2017 11:52:15 +0530
MIME-Version: 1.0
In-Reply-To: <1511594447-3836-1-git-send-email-chenjiankang1@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <efd101d8-04af-9f6c-d0fa-8bde784b103c@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JianKang Chen <chenjiankang1@huawei.com>, akpm@linux-foundation.org, mhocko@suse.com, mgorman@techsingularity.net, hillf.zj@alibaba-inc.com
Cc: hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xieyisheng1@huawei.com, guohanjun@huawei.com, wangkefeng.wang@huawei.com

On 11/25/2017 12:50 PM, JianKang Chen wrote:
> From: Jiankang Chen <chenjiankang1@huawei.com>
> 
> __get_free_pages will return an 64bit address in 64bit System
> like arm64 or x86_64. And this comment really confuse new bigenner of
> mm.

Normally its not 64 bit virtual address though CPU architecture supports
64 bits. But yes, specifying it as general virtual address without number
of bits is better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
