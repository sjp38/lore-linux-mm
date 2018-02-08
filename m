Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 16E506B0007
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 23:07:24 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id u194so2736515qka.20
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 20:07:24 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j13si3158325qtk.322.2018.02.07.20.07.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 20:07:23 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w184479E009205
	for <linux-mm@kvack.org>; Wed, 7 Feb 2018 23:07:22 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2g0dm3u3ja-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 07 Feb 2018 23:07:21 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 8 Feb 2018 04:07:19 -0000
Subject: Re: [PATCH] mm/migrate: Rename various page allocation helper
 functions
References: <20180204065816.6885-1-khandual@linux.vnet.ibm.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 8 Feb 2018 09:37:12 +0530
MIME-Version: 1.0
In-Reply-To: <20180204065816.6885-1-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <5458c2c9-3534-c00d-7abf-3315debbf896@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, mhocko@suse.com, hughd@google.com

On 02/04/2018 12:28 PM, Anshuman Khandual wrote:
> Allocation helper functions for migrate_pages() remmain scattered with
> similar names making them really confusing. Rename these functions based
> on type of the intended migration. Function alloc_misplaced_dst_page()
> remains unchanged as its highly specialized. The renamed functions are
> listed below. Functionality of migration remains unchanged.
> 
> 1. alloc_migrate_target -> new_page_alloc
> 2. new_node_page -> new_page_alloc_othernode
> 3. new_page -> new_page_alloc_keepnode
> 4. alloc_new_node_page -> new_page_alloc_node
> 5. new_page -> new_page_alloc_mempolicy

Hello Michal/Hugh,

Does the renaming good enough or we should just not rename these.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
