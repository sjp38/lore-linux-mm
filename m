Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id E74C86B0032
	for <linux-mm@kvack.org>; Mon, 16 Feb 2015 06:50:20 -0500 (EST)
Received: by mail-wg0-f43.google.com with SMTP id z12so15294735wgg.2
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 03:50:20 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id br7si21484096wjb.140.2015.02.16.03.50.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Feb 2015 03:50:19 -0800 (PST)
Message-ID: <54E1D977.30004@suse.cz>
Date: Mon, 16 Feb 2015 12:50:15 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: incorporate zero pages into transparent huge pages
References: <1423688635-4306-1-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1423688635-4306-1-git-send-email-ebru.akagunduz@gmail.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, riel@redhat.com, aarcange@redhat.com

On 02/11/2015 10:03 PM, Ebru Akagunduz wrote:
> This patch improves THP collapse rates, by allowing zero pages.
> 
> Currently THP can collapse 4kB pages into a THP when there
> are up to khugepaged_max_ptes_none pte_none ptes in a 2MB
> range.  This patch counts pte none and mapped zero pages
> with the same variable.
> 
> The patch was tested with a program that allocates 800MB of
> memory, and performs interleaved reads and writes, in a pattern
> that causes some 2MB areas to first see read accesses, resulting
> in the zero pfn being mapped there.
> 
> To simulate memory fragmentation at allocation time, I modified
> do_huge_pmd_anonymous_page to return VM_FAULT_FALLBACK for read
> faults.
> 
> Without the patch, only %50 of the program was collapsed into
> THP and the percentage did not increase over time.
> 
> With this patch after 10 minutes of waiting khugepaged had
> collapsed %99 of the program's memory.
> 
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> Reviewed-by: Rik van Riel <riel@redhat.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
