Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8CEDE6B006E
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 04:31:53 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id y10so5973008wgg.41
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 01:31:50 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f19si11736372wiw.1.2014.11.21.01.31.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Nov 2014 01:31:49 -0800 (PST)
Date: Fri, 21 Nov 2014 09:31:41 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/10] Replace _PAGE_NUMA with PAGE_NONE protections v2
Message-ID: <20141121093141.GU2725@suse.de>
References: <1416478790-27522-1-git-send-email-mgorman@suse.de>
 <546E6221.5000409@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <546E6221.5000409@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, Nov 20, 2014 at 04:50:25PM -0500, Sasha Levin wrote:
> On 11/20/2014 05:19 AM, Mel Gorman wrote:
> > V1 failed while running under kvm-tools very quickly and a second report
> > indicated that it happens on bare metal as well. This version survived
> > an overnight run of trinity running under kvm-tools here but verification
> > from Sasha would be appreciated.
> 
> Hi Mel,
> 
> I tried giving it a spin, but it won't apply at all on the latest -mm
> tree:
> 
> $ git am -3 numa/*
> Applying: mm: numa: Do not dereference pmd outside of the lock during NUMA hinting fault
> Applying: mm: Add p[te|md] protnone helpers for use by NUMA balancing
> Applying: mm: Convert p[te|md]_numa users to p[te|md]_protnone_numa
> fatal: sha1 information is lacking or useless (mm/huge_memory.c).
> Repository lacks necessary blobs to fall back on 3-way merge.
> Cannot fall back to three-way merge.
> 
> Did I miss a prerequisite?
> 

No. V2 was still against 3.18-rc4 as that was what I had vanilla kernel
test data for. V3 will be against latest mmotm.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
