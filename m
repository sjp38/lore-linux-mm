Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4F6926B03B1
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 09:46:01 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u77so2478205wrb.6
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 06:46:01 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a64si3666389wrc.296.2017.04.19.06.45.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 06:46:00 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3JDd52R044975
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 09:45:58 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 29x744x8h9-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 09:45:58 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 19 Apr 2017 14:45:56 +0100
Subject: Re: [RFC 2/4] Deactivate mmap_sem assert
References: <cover.1492595897.git.ldufour@linux.vnet.ibm.com>
 <582009a3f9459de3d8def1e76db46e815ea6153c.1492595897.git.ldufour@linux.vnet.ibm.com>
 <20170419123051.GA5730@worktop>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 19 Apr 2017 15:45:50 +0200
MIME-Version: 1.0
In-Reply-To: <20170419123051.GA5730@worktop>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <e6397c6c-6718-a0f3-0d72-7ad85760fdea@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>, akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, haren@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, Paul.McKenney@us.ibm.com, linux-kernel@vger.kernel.org

On 19/04/2017 14:30, Peter Zijlstra wrote:
> On Wed, Apr 19, 2017 at 02:18:25PM +0200, Laurent Dufour wrote:
>> When mmap_sem will be moved to a range lock, some assertion done in
>> the code are no more valid, like the one ensuring mmap_sem is held.
>>
> 
> Why are they no longer valid?

I didn't explain that very well..

When using a range lock we can't check that the lock is simply held, but
if the range we are interesting on is locked or not.

As I mentioned this patch will have to be reverted / reviewed once the
range lock is providing dedicated APIs, but some check might be
difficult to adapt to a range.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
