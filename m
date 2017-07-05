Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4401E6B0313
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 06:00:39 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id q87so119156553pfk.15
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 03:00:39 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 64si18615392plk.286.2017.07.05.03.00.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 03:00:38 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v659x0uU132113
	for <linux-mm@kvack.org>; Wed, 5 Jul 2017 06:00:37 -0400
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bgvyatj7g-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Jul 2017 06:00:36 -0400
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 5 Jul 2017 20:00:34 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v65A0WnX62783512
	for <linux-mm@kvack.org>; Wed, 5 Jul 2017 20:00:32 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v65A0USL006675
	for <linux-mm@kvack.org>; Wed, 5 Jul 2017 20:00:31 +1000
Subject: Re: [PATCH] mm: vmpressure: simplify pressure ratio calculation
References: <1498889619-3933-1-git-send-email-zbestahu@aliyun.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 5 Jul 2017 15:30:26 +0530
MIME-Version: 1.0
In-Reply-To: <1498889619-3933-1-git-send-email-zbestahu@aliyun.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <7e3f0d4c-b211-791c-d9e2-760f6f05757e@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zbestahu@aliyun.com, akpm@linux-foundation.org, minchan@kernel.org, mhocko@suse.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yue Hu <huyue2@coolpad.com>

On 07/01/2017 11:43 AM, zbestahu@aliyun.com wrote:
> From: Yue Hu <huyue2@coolpad.com>
> 
> The patch removes the needless scale in existing caluation, it
> makes the calculation more simple and more effective.
> 

Could you please explain how the new calculation is better
than the old one ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
