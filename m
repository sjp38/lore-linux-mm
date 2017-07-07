Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 863516B0279
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 03:08:11 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id d18so24729809pfe.8
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 00:08:11 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id m67si1612031pfg.279.2017.07.07.00.08.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jul 2017 00:08:10 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id z6so3414655pfk.3
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 00:08:10 -0700 (PDT)
Message-ID: <1499411222.23251.5.camel@gmail.com>
Subject: Re: [RFC v5 01/11] mm: Dont assume page-table invariance during
 faults
From: Balbir Singh <bsingharora@gmail.com>
Date: Fri, 07 Jul 2017 17:07:02 +1000
In-Reply-To: <1497635555-25679-2-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1497635555-25679-1-git-send-email-ldufour@linux.vnet.ibm.com>
	 <1497635555-25679-2-git-send-email-ldufour@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>

On Fri, 2017-06-16 at 19:52 +0200, Laurent Dufour wrote:
> From: Peter Zijlstra <peterz@infradead.org>
> 
> One of the side effects of speculating on faults (without holding
> mmap_sem) is that we can race with free_pgtables() and therefore we
> cannot assume the page-tables will stick around.
> 
> Remove the relyance on the pte pointer.
             ^^ reliance

Looking at the changelog and the code the impact is not clear.
It looks like after this patch we always assume the pte is not
the same. What is the impact of this patch?

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
