Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id EE0846B0038
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 16:48:29 -0500 (EST)
Received: by mail-ie0-f177.google.com with SMTP id rd18so11972725iec.8
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 13:48:29 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id uu10si13526583igb.16.2014.12.02.13.48.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 02 Dec 2014 13:48:28 -0800 (PST)
Message-ID: <1417551115.27448.7.camel@kernel.crashing.org>
Subject: Re: [PATCH 03/10] mm: Convert p[te|md]_numa users to
 p[te|md]_protnone_numa
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 03 Dec 2014 07:11:55 +1100
In-Reply-To: <87k32ah5q3.fsf@linux.vnet.ibm.com>
References: <1416578268-19597-1-git-send-email-mgorman@suse.de>
	 <1416578268-19597-4-git-send-email-mgorman@suse.de>
	 <1417473762.7182.8.camel@kernel.crashing.org>
	 <87k32ah5q3.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Paul Mackerras <paulus@samba.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, 2014-12-02 at 12:57 +0530, Aneesh Kumar K.V wrote:
> Now, hash_preload can possibly insert an hpte in hash page table even if
> the access is not allowed by the pte permissions. But i guess even that
> is ok. because we will fault again, end-up calling hash_page_mm where we
> handle that part correctly.

I think we need a test case...

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
