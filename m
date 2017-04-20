Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B3AAC6B03C3
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 10:42:47 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b87so2908996wmi.14
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 07:42:47 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q134si9844978wme.161.2017.04.20.07.42.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Apr 2017 07:42:46 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3KEd9ZK181626
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 10:42:45 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 29xur4jt13-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 10:42:44 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 20 Apr 2017 15:42:42 +0100
Subject: Re: [RFC 4/4] Change mmap_sem to range lock
References: <cover.1492595897.git.ldufour@linux.vnet.ibm.com>
 <1492698500-24219-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170420143736.mvj6bpwsr4w3fjwk@hirez.programming.kicks-ass.net>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Thu, 20 Apr 2017 16:42:39 +0200
MIME-Version: 1.0
In-Reply-To: <20170420143736.mvj6bpwsr4w3fjwk@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <cb1c8fbb-8d1a-845a-2fdc-dfdb25b92bae@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>, akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, haren@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, Paul.McKenney@us.ibm.com, linux-kernel@vger.kernel.org

On 20/04/2017 16:37, Peter Zijlstra wrote:
> On Thu, Apr 20, 2017 at 04:28:20PM +0200, Laurent Dufour wrote:
>> [resent this patch which seems to have not reached the mailing lists]
> 
> Probably because its too big at ~180k ?

Probably, but this time it has reached linux-mm ... at least.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
