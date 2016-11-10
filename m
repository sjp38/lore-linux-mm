Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5D4716B0275
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 03:39:07 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id y68so100357355pfb.6
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 00:39:07 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d5si3618905pgj.17.2016.11.10.00.39.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Nov 2016 00:39:06 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAA8d2Bs133865
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 03:39:06 -0500
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com [125.16.236.1])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26me7w1jxx-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 03:39:05 -0500
Received: from localhost
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 10 Nov 2016 14:08:47 +0530
Received: from d28relay06.in.ibm.com (d28relay06.in.ibm.com [9.184.220.150])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 18B4BE0045
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 14:08:51 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay06.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAA8cj4Q25166050
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 14:08:45 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAA8cgGR008853
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 14:08:44 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 08/12] mm: soft-dirty: keep soft-dirty bits over thp
 migration
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-9-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Thu, 10 Nov 2016 14:08:38 +0530
MIME-Version: 1.0
In-Reply-To: <1478561517-4317-9-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <5824320E.4060202@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On 11/08/2016 05:01 AM, Naoya Horiguchi wrote:
> Soft dirty bit is designed to keep tracked over page migration. This patch

Small nit here. s/tracked/track/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
