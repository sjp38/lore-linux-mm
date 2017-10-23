Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id CBB316B0033
	for <linux-mm@kvack.org>; Sun, 22 Oct 2017 23:06:17 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id z50so14342356qtj.9
        for <linux-mm@kvack.org>; Sun, 22 Oct 2017 20:06:17 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 95si5619902qku.363.2017.10.22.20.06.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Oct 2017 20:06:16 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9N33vCb123374
	for <linux-mm@kvack.org>; Sun, 22 Oct 2017 23:06:15 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2drw0ckcpy-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 22 Oct 2017 23:06:15 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 23 Oct 2017 04:06:13 +0100
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v9N35uqG25493752
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 03:05:58 GMT
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v9N35uKx025189
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 14:05:56 +1100
Subject: Re: [PATCH V3] selftests/vm: Add tests validating mremap mirror
 functionality
References: <20171018055502.31752-1-khandual@linux.vnet.ibm.com>
 <472ed67c-7c14-29d3-ac22-e9340a05bc06@oracle.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 23 Oct 2017 08:35:54 +0530
MIME-Version: 1.0
In-Reply-To: <472ed67c-7c14-29d3-ac22-e9340a05bc06@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <958ed0c9-6c52-ce4e-e347-eb5d11e84e5f@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: mhocko@kernel.org, shuahkh@osg.samsung.com, Andrew Morton <akpm@linux-foundation.org>

On 10/20/2017 04:54 AM, Mike Kravetz wrote:
> On 10/17/2017 10:55 PM, Anshuman Khandual wrote:
>> This adds two tests to validate mirror functionality with mremap()
>> system call on shared and private anon mappings. After the commit
>> dba58d3b8c5 ("mm/mremap: fail map duplication attempts for private
>> mappings"), any attempt to mirror private anon mapping will fail.
>>
>> Suggested-by: Mike Kravetz <mike.kravetz@oracle.com>
>> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> The tests themselves look fine.  However, they are pretty simple and
> could very easily be combined into one 'mremap_mirror.c' file.  I
> would prefer that they be combined, but it is not a deal breaker.
> 
> Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
> 

Hello Andrew/Shuah,

Is this okay or should I resend this patch with both tests folded
into one test case file ?

- Anshuman


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
