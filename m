Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id ACE836B0032
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 17:53:02 -0500 (EST)
Received: by widex7 with SMTP id ex7so3284751wid.1
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 14:53:02 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y6si5855295wiv.123.2015.02.27.14.53.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Feb 2015 14:53:00 -0800 (PST)
Message-ID: <54F0F548.6070109@suse.cz>
Date: Fri, 27 Feb 2015 23:52:56 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch 1/2] mm: remove GFP_THISNODE
References: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com> <54EED9A7.5010505@suse.cz> <alpine.DEB.2.10.1502261902580.24302@chino.kir.corp.google.com> <54F01E02.1090007@suse.cz> <alpine.DEB.2.10.1502271335520.4718@chino.kir.corp.google.com> <54F0ED7E.6010900@suse.cz> <alpine.DEB.2.10.1502271428320.7225@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1502271428320.7225@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Pravin Shelar <pshelar@nicira.com>, Jarno Rajahalme <jrajahalme@nicira.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, dev@openvswitch.org

On 27.2.2015 23:31, David Rientjes wrote:
> On Fri, 27 Feb 2015, Vlastimil Babka wrote:
>
>>> Do you see any issues with either patch 1/2 or patch 2/2 besides the
>>> s/GFP_TRANSHUGE/GFP_THISNODE/ that is necessary on the changelog?
>> Well, my point is, what if the node we are explicitly trying to allocate
>> hugepage on, is in fact not allowed by our cpuset? This could happen in the page
>> fault case, no? Although in a weird configuration when process can (and really
>> gets scheduled to run) on a node where it is not allowed to allocate from...
>>
> If the process is running a node that is not allowed by the cpuset, then
> alloc_hugepage_vma() now fails with VM_FAULT_FALLBACK.  That was the
> intended policy change of commit 077fcf116c8c ("mm/thp: allocate
> transparent hugepages on local node").

Ah, right, didn't realize that mempolicy also takes that into account.
Thanks for removing the exception anyway.

>
>   [ alloc_hugepage_vma() should probably be using numa_mem_id() instead for
>     memoryless node platforms. ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
