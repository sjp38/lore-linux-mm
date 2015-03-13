Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 65C54829BE
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 16:02:13 -0400 (EDT)
Received: by wiwh11 with SMTP id h11so9024457wiw.1
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 13:02:12 -0700 (PDT)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com. [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id di3si4657400wid.48.2015.03.13.13.02.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 13:02:12 -0700 (PDT)
Received: by wiwl15 with SMTP id l15so8771314wiw.0
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 13:02:11 -0700 (PDT)
Date: Fri, 13 Mar 2015 21:02:08 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V5] Allow compaction of unevictable pages
Message-ID: <20150313200208.GA28848@dhcp22.suse.cz>
References: <1426267597-25811-1-git-send-email-emunson@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1426267597-25811-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 13-03-15 13:26:37, Eric B Munson wrote:
[...]
> +compact_unevictable
> +
> +Available only when CONFIG_COMPACTION is set. When set to 1, compaction is
> +allowed to examine the unevictable lru (mlocked pages) for pages to compact.
> +This should be used on systems where stalls for minor page faults are an
> +acceptable trade for large contiguous free memory.  Set to 0 to prevent
> +compaction from moving pages that are unevictable.

It is not clear which behavior is default from this text.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
