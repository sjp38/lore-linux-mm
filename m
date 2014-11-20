Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 01EEF6B0069
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 16:50:37 -0500 (EST)
Received: by mail-qc0-f174.google.com with SMTP id c9so2838200qcz.33
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 13:50:36 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id r10si4154912qat.106.2014.11.20.13.50.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 20 Nov 2014 13:50:36 -0800 (PST)
Message-ID: <546E6221.5000409@oracle.com>
Date: Thu, 20 Nov 2014 16:50:25 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/10] Replace _PAGE_NUMA with PAGE_NONE protections v2
References: <1416478790-27522-1-git-send-email-mgorman@suse.de>
In-Reply-To: <1416478790-27522-1-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 11/20/2014 05:19 AM, Mel Gorman wrote:
> V1 failed while running under kvm-tools very quickly and a second report
> indicated that it happens on bare metal as well. This version survived
> an overnight run of trinity running under kvm-tools here but verification
> from Sasha would be appreciated.

Hi Mel,

I tried giving it a spin, but it won't apply at all on the latest -mm
tree:

$ git am -3 numa/*
Applying: mm: numa: Do not dereference pmd outside of the lock during NUMA hinting fault
Applying: mm: Add p[te|md] protnone helpers for use by NUMA balancing
Applying: mm: Convert p[te|md]_numa users to p[te|md]_protnone_numa
fatal: sha1 information is lacking or useless (mm/huge_memory.c).
Repository lacks necessary blobs to fall back on 3-way merge.
Cannot fall back to three-way merge.

Did I miss a prerequisite?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
