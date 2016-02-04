Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 18B83680F7F
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 19:04:27 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id o185so23312533pfb.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 16:04:27 -0800 (PST)
Received: from mail-pf0-x232.google.com (mail-pf0-x232.google.com. [2607:f8b0:400e:c00::232])
        by mx.google.com with ESMTPS id n16si12345027pfa.122.2016.02.03.16.04.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 16:04:26 -0800 (PST)
Received: by mail-pf0-x232.google.com with SMTP id n128so23144854pfn.3
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 16:04:26 -0800 (PST)
Date: Wed, 3 Feb 2016 16:04:24 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v4 06/14] mm, debug: replace dump_flags() with the new
 printk formats
In-Reply-To: <1453812353-26744-7-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.10.1602031604110.10331@chino.kir.corp.google.com>
References: <1453812353-26744-1-git-send-email-vbabka@suse.cz> <1453812353-26744-7-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Ingo Molnar <mingo@redhat.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>

On Tue, 26 Jan 2016, Vlastimil Babka wrote:

> With the new printk format strings for flags, we can get rid of dump_flags()
> in mm/debug.c.
> 
> This also fixes dump_vma() which used dump_flags() for printing vma flags.
> However dump_flags() did a page-flags specific filtering of bits higher than
> NR_PAGEFLAGS in order to remove the zone id part. For dump_vma() this resulted
> in removing several VM_* flags from the symbolic translation.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Sasha Levin <sasha.levin@oracle.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Acked-by: Michal Hocko <mhocko@suse.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
