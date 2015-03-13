Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id EDBCB829BE
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 14:56:43 -0400 (EDT)
Received: by qcrw7 with SMTP id w7so28852391qcr.8
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 11:56:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h13si2687843qhc.98.2015.03.13.11.56.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 11:56:43 -0700 (PDT)
Message-ID: <550332CE.7040404@redhat.com>
Date: Fri, 13 Mar 2015 14:56:14 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH V5] Allow compaction of unevictable pages
References: <1426267597-25811-1-git-send-email-emunson@akamai.com>
In-Reply-To: <1426267597-25811-1-git-send-email-emunson@akamai.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/13/2015 01:26 PM, Eric B Munson wrote:

> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1046,6 +1046,8 @@ typedef enum {
>  	ISOLATE_SUCCESS,	/* Pages isolated, migrate */
>  } isolate_migrate_t;
>  
> +int sysctl_compact_unevictable;
> +
>  /*
>   * Isolate all pages that can be migrated from the first suitable block,
>   * starting at the block pointed to by the migrate scanner pfn within

I suspect that the use cases where users absolutely do not want
unevictable pages migrated are special cases, and it may make
sense to enable sysctl_compact_unevictable by default.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
