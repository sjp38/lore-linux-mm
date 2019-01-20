Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id A123E8E0001
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 12:09:30 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id b16so18150061qtc.22
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 09:09:30 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p14si1886752qvp.222.2019.01.20.09.09.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Jan 2019 09:09:29 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0KH9ImZ130381
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 12:09:29 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2q4j2y8ehq-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 12:09:28 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 20 Jan 2019 17:09:27 -0000
Date: Sun, 20 Jan 2019 19:09:20 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH 0/2] mm/mmap.c: Remove some redundancy in
 arch_get_unmapped_area_topdown()
References: <cover.1547966629.git.nullptr.cpp@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1547966629.git.nullptr.cpp@gmail.com>
Message-Id: <20190120170919.GB28141@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Fan <nullptr.cpp@gmail.com>
Cc: akpm@linux-foundation.org, will.deacon@arm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

On Sun, Jan 20, 2019 at 09:12:26AM +0100, Yang Fan wrote:
> This patchset remove some redundancy in function 
> arch_get_unmapped_area_topdown().
> 
> [PATCH 1/2] mm/mmap.c: Remove redundant variable 'addr' in 
> arch_get_unmapped_area_topdown()
> [PATCH 2/2] mm/mmap.c: Remove redundant const qualifier of the no-pointer 
> parameters
> 
> Yang Fan (2):
>   mm/mmap.c: Remove redundant variable 'addr' in
>     arch_get_unmapped_area_topdown()
>   mm/mmap.c: Remove redundant const qualifier of the no-pointer
>     parameters

I think it would be better to merge these patches into one.
For the merged patch feel free to add

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
 
>  mm/mmap.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> -- 
> 2.17.1
> 

-- 
Sincerely yours,
Mike.
