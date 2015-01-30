Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0B6646B0038
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 05:01:15 -0500 (EST)
Received: by mail-wg0-f45.google.com with SMTP id x12so25909487wgg.4
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 02:01:14 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id br7si19655126wjb.140.2015.01.30.02.01.12
        for <linux-mm@kvack.org>;
        Fri, 30 Jan 2015 02:01:13 -0800 (PST)
Date: Fri, 30 Jan 2015 11:58:07 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v4] mm: incorporate read-only pages into transparent huge
 pages
Message-ID: <20150130095807.GA27412@node.dhcp.inet.fi>
References: <1422543547-12591-1-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1422543547-12591-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, riel@redhat.com, aarcange@redhat.com, zhangyanfei.linux@aliyun.com

On Thu, Jan 29, 2015 at 04:59:07PM +0200, Ebru Akagunduz wrote:
> This patch aims to improve THP collapse rates, by allowing
> THP collapse in the presence of read-only ptes, like those
> left in place by do_swap_page after a read fault.
> 
> Currently THP can collapse 4kB pages into a THP when
> there are up to khugepaged_max_ptes_none pte_none ptes
> in a 2MB range. This patch applies the same limit for
> read-only ptes.
> 
> The patch was tested with a test program that allocates
> 800MB of memory, writes to it, and then sleeps. I force
> the system to swap out all but 190MB of the program by
> touching other memory. Afterwards, the test program does
> a mix of reads and writes to its memory, and the memory
> gets swapped back in.
> 
> Without the patch, only the memory that did not get
> swapped out remained in THPs, which corresponds to 24% of
> the memory of the program. The percentage did not increase
> over time.
> 
> With this patch, after 5 minutes of waiting khugepaged had
> collapsed 60% of the program's memory back into THPs.
> 
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
