Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4F0046B0035
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 04:42:12 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id w62so6949340wes.29
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 01:42:09 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id vl8si32705148wjc.152.2014.07.28.01.42.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 28 Jul 2014 01:42:08 -0700 (PDT)
Message-ID: <53D60CDD.4080801@suse.cz>
Date: Mon, 28 Jul 2014 10:42:05 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch v3] mm, thp: only collapse hugepages to nodes with affinity
 for zone_reclaim_mode
References: <alpine.DEB.2.02.1407141807030.8808@chino.kir.corp.google.com> <alpine.DEB.2.02.1407151712520.12279@chino.kir.corp.google.com> <53C69C7B.1010709@suse.cz> <alpine.DEB.2.02.1407161754000.23892@chino.kir.corp.google.com> <alpine.DEB.2.02.1407161757500.23892@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1407161757500.23892@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Bob Liu <bob.liu@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/17/2014 02:59 AM, David Rientjes wrote:
> Commit 9f1b868a13ac ("mm: thp: khugepaged: add policy for finding target
> node") improved the previous khugepaged logic which allocated a
> transparent hugepages from the node of the first page being collapsed.
>
> However, it is still possible to collapse pages to remote memory which may
> suffer from additional access latency.  With the current policy, it is
> possible that 255 pages (with PAGE_SHIFT == 12) will be collapsed remotely
> if the majority are allocated from that node.
>
> When zone_reclaim_mode is enabled, it means the VM should make every attempt
> to allocate locally to prevent NUMA performance degradation.  In this case,
> we do not want to collapse hugepages to remote nodes that would suffer from
> increased access latency.  Thus, when zone_reclaim_mode is enabled, only
> allow collapsing to nodes with RECLAIM_DISTANCE or less.
>
> There is no functional change for systems that disable zone_reclaim_mode.
>
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
