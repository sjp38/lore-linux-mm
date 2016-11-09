Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5DF996B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 05:33:26 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 144so70343476pfv.5
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 02:33:26 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m10si234732paw.24.2016.11.09.02.33.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Nov 2016 02:33:25 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA9ASqr9002975
	for <linux-mm@kvack.org>; Wed, 9 Nov 2016 05:33:24 -0500
Received: from e28smtp08.in.ibm.com (e28smtp08.in.ibm.com [125.16.236.8])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26kybx0rbb-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 09 Nov 2016 05:33:24 -0500
Received: from localhost
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 9 Nov 2016 16:03:21 +0530
Received: from d28relay06.in.ibm.com (d28relay06.in.ibm.com [9.184.220.150])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 8D15EE0045
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 16:03:24 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay06.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uA9AXJwf7405756
	for <linux-mm@kvack.org>; Wed, 9 Nov 2016 16:03:19 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uA9AXGTM000399
	for <linux-mm@kvack.org>; Wed, 9 Nov 2016 16:03:19 +0530
Subject: Re: [PATCH v2 00/12] mm: page migration enhancement for thp
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 9 Nov 2016 16:03:04 +0530
MIME-Version: 1.0
In-Reply-To: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <5822FB60.5040905@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On 11/08/2016 05:01 AM, Naoya Horiguchi wrote:
> Hi everyone,
> 
> I've updated thp migration patches for v4.9-rc2-mmotm-2016-10-27-18-27
> with feedbacks for ver.1.
> 
> General description (no change since ver.1)
> ===========================================
> 
> This patchset enhances page migration functionality to handle thp migration
> for various page migration's callers:
>  - mbind(2)
>  - move_pages(2)
>  - migrate_pages(2)
>  - cgroup/cpuset migration
>  - memory hotremove
>  - soft offline
> 
> The main benefit is that we can avoid unnecessary thp splits, which helps us
> avoid performance decrease when your applications handles NUMA optimization on
> their own.
> 
> The implementation is similar to that of normal page migration, the key point
> is that we modify a pmd to a pmd migration entry in swap-entry like format.

Will it be better to have new THP_MIGRATE_SUCCESS and THP_MIGRATE_FAIL
VM events to capture how many times the migration worked without first
splitting the huge page and how many time it did not work ? Also do you
have a test case which demonstrates this THP migration and kind of shows
its better than the present split and move method ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
