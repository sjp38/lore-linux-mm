Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 62A166B0036
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 10:46:33 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id b15so772915eek.6
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 07:46:31 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id w48si3039892eel.356.2014.04.08.07.46.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Apr 2014 07:46:30 -0700 (PDT)
Message-ID: <53440A5D.6050301@zytor.com>
Date: Tue, 08 Apr 2014 07:40:29 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/5] Use an alternative to _PAGE_PROTNONE for _PAGE_NUMA
 v2
References: <1396962570-18762-1-git-send-email-mgorman@suse.de>
In-Reply-To: <1396962570-18762-1-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux-X86 <x86@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>David Vrabel <david.vrabel@citrix.com>

On 04/08/2014 06:09 AM, Mel Gorman wrote:
> Using unused physical bits is something that will break eventually.
> 
> Changelog since V1
> o Reuse software-bits
> o Use paravirt ops when modifying PTEs in the NUMA helpers
> 
> Aliasing _PAGE_NUMA and _PAGE_PROTNONE had some convenient properties but
> it ultimately gave Xen a headache and pisses almost everybody off that
> looks closely at it. Two discussions on "why this makes sense" is one
> discussion too many so rather than having a third so here is this series.
> This series reuses the PTE bits that are available to the programmer.
> This adds some contraints on how and when automatic NUMA balancing can be
> enabled but it should go away again when Xen stops using _PAGE_IOMAP.
> 
> The series also converts the NUMA helpers to use paravirt-friendly operations
> but it needs a Tested-by from the Xen and powerpc people.
> 

It is proably simpler to just base this patchset on top of David
Vrabel's which actually *does* remove _PAGE_IOMAP.

David, is your patchset going to be pushed in this merge window as expected?

That being said, these bits are precious, and if this ends up being a
case where "only Xen needs another bit" once again then Xen should
expect to get kicked to the curb at a moment's notice.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
