Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3106C6B0253
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 05:47:41 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id yr2so60704878wjc.4
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 02:47:41 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i128si12889313wmi.52.2017.01.30.02.47.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 02:47:39 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0UAi3Js146840
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 05:47:38 -0500
Received: from e28smtp05.in.ibm.com (e28smtp05.in.ibm.com [125.16.236.5])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28a09s8gmp-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 05:47:38 -0500
Received: from localhost
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 30 Jan 2017 16:17:35 +0530
Received: from d28av06.in.ibm.com (d28av06.in.ibm.com [9.184.220.48])
	by d28relay06.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0UAlWit23920828
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 16:17:32 +0530
Received: from d28av06.in.ibm.com (localhost [127.0.0.1])
	by d28av06.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0UAlUP9019646
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 16:17:32 +0530
Subject: Re: [PATCH v2 00/12] mm: page migration enhancement for thp
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 30 Jan 2017 16:17:27 +0530
MIME-Version: 1.0
In-Reply-To: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <b6f7dd5d-47aa-0ec2-b18a-bb4074ab2a2a@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>Zi Yan <zi.yan@cs.rutgers.edu>

On 11/08/2016 05:01 AM, Naoya Horiguchi wrote:
> Hi everyone,
> 
> I've updated thp migration patches for v4.9-rc2-mmotm-2016-10-27-18-27
> with feedbacks for ver.1.

Hello Noaya,

I have been working with Zi Yan on the parallel huge page migration series
(https://lkml.org/lkml/2016/11/22/457) and planning to post them on top of
this THP migration enhancement series. Hence we were wondering if you have
plans to post a new version of this series in near future ?

Regards
Anshuman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
