Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D9C946B0005
	for <linux-mm@kvack.org>; Wed, 11 May 2016 22:58:54 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 203so121376388pfy.2
        for <linux-mm@kvack.org>; Wed, 11 May 2016 19:58:54 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id t17si13957810pfa.119.2016.05.11.19.58.53
        for <linux-mm@kvack.org>;
        Wed, 11 May 2016 19:58:53 -0700 (PDT)
Date: Thu, 12 May 2016 11:58:58 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 3/6] mm/page_owner: copy last_migrate_reason in
 copy_page_owner()
Message-ID: <20160512025858.GC8215@js1304-P5Q-DELUXE>
References: <1462252984-8524-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1462252984-8524-4-git-send-email-iamjoonsoo.kim@lge.com>
 <5731FA88.2060701@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5731FA88.2060701@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, May 10, 2016 at 05:13:12PM +0200, Vlastimil Babka wrote:
> On 05/03/2016 07:23 AM, js1304@gmail.com wrote:
> >From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >
> >Currently, copy_page_owner() doesn't copy all the owner information.
> >It skips last_migrate_reason because copy_page_owner() is used for
> >migration and it will be properly set soon. But, following patch
> >will use copy_page_owner() and this skip will cause the problem that
> >allocated page has uninitialied last_migrate_reason. To prevent it,
> >this patch also copy last_migrate_reason in copy_page_owner().
> 
> Hmm it's a corner case, but if the "new" page was dumped e.g. due to
> a bug during the migration, is the copied migrate reason from the
> "old" page actually meaningful? I'd say it might be misleading and
> it's simpler to just make sure it's initialized to -1.

Hmm... if it is the case, other fields are also misleading. I think
that we can tolerate this corner case and keeping function semantic as
function name suggests is better practice.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
