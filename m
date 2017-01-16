Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 963B56B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 09:43:58 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y143so251939688pfb.6
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 06:43:58 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s6si20562245pfg.191.2017.01.16.06.43.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 06:43:57 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0GEhWbn109195
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 09:43:57 -0500
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0a-001b2d01.pphosted.com with ESMTP id 27ykn0k51d-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 09:43:56 -0500
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 17 Jan 2017 00:43:54 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id D70C32BB0055
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 01:43:50 +1100 (EST)
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0GEhoaL55115862
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 01:43:50 +1100
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0GEhokI026960
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 01:43:50 +1100
Subject: Re: [PATCH] mm: respect pre-allocated storage mapping for memmap
References: <1484573885-54353-1-git-send-email-zhongjiang@huawei.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 16 Jan 2017 20:13:38 +0530
MIME-Version: 1.0
In-Reply-To: <1484573885-54353-1-git-send-email-zhongjiang@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <efc34702-7921-a91c-3002-691f083001d5@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>, dan.j.williams@intel.com, hannes@cmpxchg.org, mhocko@suse.com
Cc: linux-mm@kvack.org

On 01/16/2017 07:08 PM, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
> 
> At present, we skip the reservation storage by the driver for
> the zone_dvice. but the free pages set aside for the memmap is
> ignored. And since the free pages is only used as the memmap,
> so we can also skip the corresponding pages.

But these free pages used for memmap mapping should also be accounted
inside the zone, no ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
