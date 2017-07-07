Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 344196B02C3
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 07:05:03 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v88so7209659wrb.1
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 04:05:03 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y128si2690444wmg.15.2017.07.07.04.05.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jul 2017 04:05:01 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v67B4v7n118212
	for <linux-mm@kvack.org>; Fri, 7 Jul 2017 07:05:00 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bj2whn37v-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 07 Jul 2017 07:04:59 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 7 Jul 2017 21:04:56 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v67B3d777012748
	for <linux-mm@kvack.org>; Fri, 7 Jul 2017 21:03:39 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v67B3dbN022582
	for <linux-mm@kvack.org>; Fri, 7 Jul 2017 21:03:39 +1000
Subject: Re: [RFC PATCH 0/1] mm/mremap: add MREMAP_MIRROR flag
References: <1499357846-7481-1-git-send-email-mike.kravetz@oracle.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 7 Jul 2017 16:33:36 +0530
MIME-Version: 1.0
In-Reply-To: <1499357846-7481-1-git-send-email-mike.kravetz@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <0f935c5a-2580-c95a-4ea5-c25e796dad03@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On 07/06/2017 09:47 PM, Mike Kravetz wrote:
> The mremap system call has the ability to 'mirror' parts of an existing
> mapping.  To do so, it creates a new mapping that maps the same pages as
> the original mapping, just at a different virtual address.  This
> functionality has existed since at least the 2.6 kernel [1].  A comment
> was added to the code to help preserve this feature.

In mremap() implementation move_vma() attempts to do do_unmap() after
move_page_tables(). do_unmap() on the original VMA bails out because
the requested length being 0. Hence both the original VMA and the new
VMA remains after the page table migration. Seems like this whole
mirror function is by coincidence or it has been designed that way ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
