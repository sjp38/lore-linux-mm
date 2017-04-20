Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9AA316B03C1
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 10:39:41 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id z129so2902330wmb.23
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 07:39:41 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 136si9835415wms.126.2017.04.20.07.39.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Apr 2017 07:39:40 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3KEd8tL076611
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 10:39:39 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 29xxf9sscs-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 10:39:38 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 20 Apr 2017 15:39:36 +0100
Subject: Re: [RFC 0/4] Replace mmap_sem by a range lock
References: <cover.1492595897.git.ldufour@linux.vnet.ibm.com>
 <20170420133338.GC27790@bombadil.infradead.org>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Thu, 20 Apr 2017 16:39:32 +0200
MIME-Version: 1.0
In-Reply-To: <20170420133338.GC27790@bombadil.infradead.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <87628c87-d320-87e7-5076-b26432a72a0f@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>, akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, haren@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, Paul.McKenney@us.ibm.com, linux-kernel@vger.kernel.org

On 20/04/2017 15:33, Matthew Wilcox wrote:
> On Wed, Apr 19, 2017 at 02:18:23PM +0200, Laurent Dufour wrote:
>> Following the series pushed by Davidlohr Bueso based on the Jan Kara's
>> work [1] which introduces range locks, this series implements the
>> first step of the attempt to replace the mmap_sem by a range lock.
> 
> Have you previously documented attempts to replace the mmap_sem by an
> existing lock type before introducing a new (and frankly weird) lock?

No :/

> My initial question is "Why not use RCU for this?" -- the rxrpc code
> uses an rbtree protected by RCU.

I'm also working on forward-porting work done by Peter Zijlstra :

https://marc.info/?l=linux-mm&m=141384492326748

I'll send a series on top 4.10 soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
