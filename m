Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E2AD66B0005
	for <linux-mm@kvack.org>; Wed, 11 May 2016 22:51:20 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 4so121203043pfw.0
        for <linux-mm@kvack.org>; Wed, 11 May 2016 19:51:20 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id d62si4304251pfc.214.2016.05.11.19.51.19
        for <linux-mm@kvack.org>;
        Wed, 11 May 2016 19:51:20 -0700 (PDT)
Date: Thu, 12 May 2016 11:51:23 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/6] mm/compaction: split freepages without holding the
 zone lock
Message-ID: <20160512025123.GB8215@js1304-P5Q-DELUXE>
References: <1462252984-8524-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1462252984-8524-2-git-send-email-iamjoonsoo.kim@lge.com>
 <5731F6AD.4090801@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5731F6AD.4090801@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>

On Tue, May 10, 2016 at 04:56:45PM +0200, Vlastimil Babka wrote:
> On 05/03/2016 07:22 AM, js1304@gmail.com wrote:
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > We don't need to split freepages with holding the zone lock. It will cause
> > more contention on zone lock so not desirable.
> 
> Fair enough, I just worry about the same thing as Hugh pointed out
> recently [1] in that it increases the amount of tricky stuff in
> compaction.c doing similar but not quite the same stuff as page/alloc.c,
> and which will be forgotten to be updated once somebody updates
> prep_new_page with e.g. a new debugging check. Can you perhaps think of
> a more robust solution here?

I will try it. I think that factoring some part of prep_new_page() out
would be enough to make thing robust.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
