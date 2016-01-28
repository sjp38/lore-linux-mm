Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4B9696B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 10:05:26 -0500 (EST)
Received: by mail-yk0-f180.google.com with SMTP id a85so33578169ykb.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 07:05:26 -0800 (PST)
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com. [125.16.236.6])
        by mx.google.com with ESMTPS id s6si4299946ywb.241.2016.01.28.07.05.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 28 Jan 2016 07:05:25 -0800 (PST)
Received: from localhost
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 28 Jan 2016 20:35:21 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0SF5EqB14811586
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 20:35:14 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0SF5DqR022007
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 20:35:13 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [LSF/MM ATTEND] Huge Page Futures
In-Reply-To: <56A580F8.4060301@oracle.com>
References: <56A580F8.4060301@oracle.com>
Date: Thu, 28 Jan 2016 20:35:06 +0530
Message-ID: <87bn85ycbh.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

Mike Kravetz <mike.kravetz@oracle.com> writes:

> In a search of the archives, it appears huge page support in one form or
> another has been a discussion topic in almost every LSF/MM gathering. Based
> on patches submitted this past year, huge pages is still an area of active
> development.  And, it appears this level of activity will  continue in the
> coming year.
>
> I propose a "Huge Page Futures" session to discuss large works in progress
> as well as work people are considering for 2016.  Areas of discussion would
> minimally include:
>
> - Krill Shutemov's THP new refcounting code and the push for huge page
>   support in the page cache.

I am also interested in this discussion. We had some nice challenge
w.r.t to powerpc implementation of THP.

>
> - Matt Wilcox's huge page support in DAX enabled filesystems, but perhaps
>   more interesting is the desire for supporting PUD pages.  This seems to
>   beg the question of supporting transparent PUD pages elsewhere.
>

I am also looking at switching powerpc hugetlbfs to GENERAL_HUGETLB. To
support 16GB pages I would need hugepage at PUD/PGD. Can you elaborate
why supporting huge PUD page is a challenge ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
