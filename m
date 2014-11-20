Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 95A3B6B0081
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 05:47:27 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id hi2so4871000wib.5
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 02:47:27 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bj3si6727572wib.82.2014.11.20.02.47.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Nov 2014 02:47:27 -0800 (PST)
Date: Thu, 20 Nov 2014 10:47:22 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 03/10] mm: Convert p[te|md]_numa users to
 p[te|md]_protnone_numa
Message-ID: <20141120104722.GL2725@suse.de>
References: <1416478790-27522-1-git-send-email-mgorman@suse.de>
 <1416478790-27522-4-git-send-email-mgorman@suse.de>
 <063D6719AE5E284EB5DD2968C1650D6D1C9F48CB@AcuExch.aculab.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1C9F48CB@AcuExch.aculab.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Laight <David.Laight@ACULAB.COM>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Paul Mackerras <paulus@samba.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Sasha Levin <sasha.levin@oracle.com>, Dave Jones <davej@redhat.com>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, Kirill Shutemov <kirill.shutemov@linux.intel.com>

On Thu, Nov 20, 2014 at 10:38:56AM +0000, David Laight wrote:
> From:  Mel Gorman
> > Convert existing users of pte_numa and friends to the new helper. Note
> > that the kernel is broken after this patch is applied until the other
> > page table modifiers are also altered. This patch layout is to make
> > review easier.
> 
> Doesn't that break bisection?
> 

Yes, for automatic NUMA balancing at least. The patch structure is to
to make reviewers job easier and besides, bisecting within patches 2-6
is pointless. If desired, I can collapse patches 2-6 together for the
final submission.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
