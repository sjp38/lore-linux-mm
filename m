Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 927C46B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 22:25:25 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id x6so14894699oif.0
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 19:25:25 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id f85si36856902iod.134.2016.06.14.19.25.24
        for <linux-mm@kvack.org>;
        Tue, 14 Jun 2016 19:25:25 -0700 (PDT)
Date: Wed, 15 Jun 2016 11:27:31 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 1/7] mm/compaction: split freepages without holding
 the zone lock
Message-ID: <20160615022731.GB19863@js1304-P5Q-DELUXE>
References: <1464230275-25791-1-git-send-email-iamjoonsoo.kim@lge.com>
 <575F1813.4020700@oracle.com>
 <20160614055257.GA13753@js1304-P5Q-DELUXE>
 <5760569D.6030907@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5760569D.6030907@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 14, 2016 at 03:10:21PM -0400, Sasha Levin wrote:
> On 06/14/2016 01:52 AM, Joonsoo Kim wrote:
> > On Mon, Jun 13, 2016 at 04:31:15PM -0400, Sasha Levin wrote:
> >> > On 05/25/2016 10:37 PM, js1304@gmail.com wrote:
> >>> > > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >>> > > 
> >>> > > We don't need to split freepages with holding the zone lock. It will cause
> >>> > > more contention on zone lock so not desirable.
> >>> > > 
> >>> > > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >> > 
> >> > Hey Joonsoo,
> > Hello, Sasha.
> >> > 
> >> > I'm seeing the following corruption/crash which seems to be related to
> >> > this patch:
> > Could you tell me why you think that following corruption is related
> > to this patch? list_del() in __isolate_free_page() is unchanged part.
> > 
> > Before this patch, we did it by split_free_page() ->
> > __isolate_free_page() -> list_del(). With this patch, we do it by
> > calling __isolate_free_page() directly.
> 
> I haven't bisected it, but it's the first time I see this issue and this
> commit seems to have done related changes that might cause this.
> 
> I can go ahead with bisection if you don't think it's related.

Hmm... I can't find a bug in this patch for now. There are more candidates
on this area hat changed by me and it would be very helpful if you can
do bisection.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
