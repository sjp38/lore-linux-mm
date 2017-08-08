Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1D63B6B02F4
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 09:34:21 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id k190so34715682pge.9
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 06:34:21 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i72si898201pfj.386.2017.08.08.06.34.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 06:34:20 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v78DXNPV118270
	for <linux-mm@kvack.org>; Tue, 8 Aug 2017 09:34:19 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2c7cvwpwdd-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 Aug 2017 09:34:18 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 8 Aug 2017 14:34:11 +0100
Subject: Re: [RFC v5 05/11] mm: fix lock dependency against
 mapping->i_mmap_rwsem
References: <1497635555-25679-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1497635555-25679-6-git-send-email-ldufour@linux.vnet.ibm.com>
 <564749a2-a729-b927-7707-1cad897c418a@linux.vnet.ibm.com>
 <78d903c4-6e9f-e049-de60-6d1ccb45ff92@linux.vnet.ibm.com>
 <20170808131557.iyczqs4wzqanx35p@hirez.programming.kicks-ass.net>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Tue, 8 Aug 2017 15:34:05 +0200
MIME-Version: 1.0
In-Reply-To: <20170808131557.iyczqs4wzqanx35p@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: fr
Content-Transfer-Encoding: 7bit
Message-Id: <3c727d58-a47f-57a7-13a4-a2827c53940e@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>

On 08/08/2017 15:15, Peter Zijlstra wrote:
> On Tue, Aug 08, 2017 at 02:20:23PM +0200, Laurent Dufour wrote:
>> This is an option, but the previous one was signed by Peter, and I'd prefer
>> to keep his unchanged and add this new one to fix that.
>> Again this is to ease the review.
> 
> You can always add something like:
> 
> [ldufour: fixed lockdep complaint]
> 
> Before your SoB.

Yes, that's what I'm doing right now, and I'll push a new series based on
4.13-rc4 asap.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
