Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4B90D6B0037
	for <linux-mm@kvack.org>; Wed, 30 Oct 2013 11:21:03 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id w10so1100978pde.16
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 08:21:02 -0700 (PDT)
Received: from psmtp.com ([74.125.245.150])
        by mx.google.com with SMTP id vs7si18266251pbc.85.2013.10.30.08.21.01
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 08:21:02 -0700 (PDT)
Date: Wed, 30 Oct 2013 15:20:57 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: get rid of unnecessary overhead of
 trace_mm_page_alloc_extfrag()
Message-ID: <20131030152057.GP2400@suse.de>
References: <1382719367-11537-1-git-send-email-kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1382719367-11537-1-git-send-email-kosaki.motohiro@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Fri, Oct 25, 2013 at 12:42:47PM -0400, kosaki.motohiro@gmail.com wrote:
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> In general, every tracepoint should be zero overhead if it is disabled.
> However, trace_mm_page_alloc_extfrag() is one of exception. It evaluate
> "new_type == start_migratetype" even if tracepoint is disabled.
> 
> However, the code can be moved into tracepoint's TP_fast_assign() and
> TP_fast_assign exist exactly such purpose. This patch does it.
> 
> Cc: Mel Gorman <mgorman@suse.de>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
