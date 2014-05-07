Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 78F366B003A
	for <linux-mm@kvack.org>; Wed,  7 May 2014 17:15:37 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y10so1523726pdj.39
        for <linux-mm@kvack.org>; Wed, 07 May 2014 14:15:37 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ke1si14448130pad.91.2014.05.07.14.15.36
        for <linux-mm@kvack.org>;
        Wed, 07 May 2014 14:15:36 -0700 (PDT)
Date: Wed, 7 May 2014 14:15:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch v3 2/6] mm, compaction: return failed migration target
 pages back to freelist
Message-Id: <20140507141534.d4def933b3a9999e7826df5c@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1405061921040.18635@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com>
	<alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com>
	<alpine.DEB.2.02.1405061920470.18635@chino.kir.corp.google.com>
	<alpine.DEB.2.02.1405061921040.18635@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 6 May 2014 19:22:43 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

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

What did Greg actually report?  IOW, what if any observable problem is
being fixed here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
