Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id 887B46B0035
	for <linux-mm@kvack.org>; Thu,  1 May 2014 09:40:33 -0400 (EDT)
Received: by mail-ee0-f54.google.com with SMTP id b57so351830eek.41
        for <linux-mm@kvack.org>; Thu, 01 May 2014 06:40:32 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 45si34222739eeh.3.2014.05.01.06.40.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 01 May 2014 06:40:32 -0700 (PDT)
Date: Thu, 1 May 2014 14:40:28 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 15/17] mm: Do not use unnecessary atomic operations when
 adding pages to the LRU
Message-ID: <20140501134028.GL23991@suse.de>
References: <1398933888-4940-1-git-send-email-mgorman@suse.de>
 <1398933888-4940-16-git-send-email-mgorman@suse.de>
 <20140501133340.GE23420@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140501133340.GE23420@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On Thu, May 01, 2014 at 09:33:40AM -0400, Johannes Weiner wrote:
> On Thu, May 01, 2014 at 09:44:46AM +0100, Mel Gorman wrote:
> > When adding pages to the LRU we clear the active bit unconditionally. As the
> > page could be reachable from other paths we cannot use unlocked operations
> > without risk of corruption such as a parallel mark_page_accessed. This
> > patch test if is necessary to clear the atomic flag before using an atomic
> > operation. In the unlikely even this races with mark_page_accesssed the
> 
>                              event
> 

Will be corrected in v3. Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
