Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0DEE36B0033
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 00:02:16 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y77so7872438pfd.1
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 21:02:16 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r81si516469qka.300.2017.10.05.21.02.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Oct 2017 21:02:15 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v963xK4p012955
	for <linux-mm@kvack.org>; Fri, 6 Oct 2017 00:02:14 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2de08vwv5e-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 06 Oct 2017 00:02:13 -0400
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 6 Oct 2017 14:02:10 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v96427X343450548
	for <linux-mm@kvack.org>; Fri, 6 Oct 2017 15:02:07 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v96420a5027417
	for <linux-mm@kvack.org>; Fri, 6 Oct 2017 15:02:00 +1100
Subject: Re: [PATCHv2 1/2] mm: Introduce wrappers to access mm->nr_ptes
References: <20171005101442.49555-1-kirill.shutemov@linux.intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 6 Oct 2017 09:32:03 +0530
MIME-Version: 1.0
In-Reply-To: <20171005101442.49555-1-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <856babfe-fd38-0bd2-d8d2-64dfe6672da8@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Michal Hocko <mhocko@kernel.org>

On 10/05/2017 03:44 PM, Kirill A. Shutemov wrote:
> Let's add wrappers for ->nr_ptes with the same interface as for nr_pmd
> and nr_pud.
> 
> It's preparation for consolidation of page-table counters in mm_struct.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Hey Kirill,

This patch does not apply cleanly either on mainline or on the latest
mmotm branch mmotm-2017-10-03-17-08. Is there any other branch like
'linux next' you might have rebased these patches against ?

- Anshuman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
