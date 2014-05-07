Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6BFE36B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 10:14:50 -0400 (EDT)
Received: by mail-qg0-f46.google.com with SMTP id q108so1093621qgd.5
        for <linux-mm@kvack.org>; Wed, 07 May 2014 07:14:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id l5si6765226qai.169.2014.05.07.07.14.48
        for <linux-mm@kvack.org>;
        Wed, 07 May 2014 07:14:48 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [patch v3 2/6] mm, compaction: return failed migration target pages back to freelist
Date: Wed,  7 May 2014 10:14:37 -0400
Message-Id: <536a3fd8.0542e00a.02f8.66c4SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <alpine.DEB.2.02.1405061921040.18635@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com> <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com> <alpine.DEB.2.02.1405061920470.18635@chino.kir.corp.google.com> <alpine.DEB.2.02.1405061921040.18635@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, vbabka@suse.cz, iamjoonsoo.kim@lge.com, gthelen@google.com, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, May 06, 2014 at 07:22:43PM -0700, David Rientjes wrote:
> Memory compaction works by having a "freeing scanner" scan from one end of a 
> zone which isolates pages as migration targets while another "migrating scanner" 
> scans from the other end of the same zone which isolates pages for migration.
> 
> When page migration fails for an isolated page, the target page is returned to 
> the system rather than the freelist built by the freeing scanner.  This may 
> require the freeing scanner to continue scanning memory after suitable migration 
> targets have already been returned to the system needlessly.
> 
> This patch returns destination pages to the freeing scanner freelist when page 
> migration fails.  This prevents unnecessary work done by the freeing scanner but 
> also encourages memory to be as compacted as possible at the end of the zone.
> 
> Reported-by: Greg Thelen <gthelen@google.com>
> Acked-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: David Rientjes <rientjes@google.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
