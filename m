Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 770B26B0069
	for <linux-mm@kvack.org>; Sun, 22 Jan 2017 09:40:25 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 75so166410585pgf.3
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 06:40:25 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id d9si12735320pge.193.2017.01.22.06.40.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Jan 2017 06:40:24 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id f144so8413583pfa.2
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 06:40:24 -0800 (PST)
Date: Sun, 22 Jan 2017 22:40:17 +0800
From: Geliang Tang <geliangtang@gmail.com>
Subject: Re: [PATCH] writeback: use rb_entry()
Message-ID: <20170122144017.4uqlvmzhravsrprf@ThinkPad>
References: <5b23d0cb523f4719673a462ab1569ae99084337e.1483685419.git.geliangtang@gmail.com>
 <671275de093d93ddc7c6f77ddc0d357149691a39.1484306840.git.geliangtang@gmail.com>
 <20170115235431.GF14446@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170115235431.GF14446@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Jens Axboe <axboe@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Jan 15, 2017 at 06:54:31PM -0500, Tejun Heo wrote:
> On Fri, Jan 13, 2017 at 11:17:12PM +0800, Geliang Tang wrote:
> > To make the code clearer, use rb_entry() instead of container_of() to
> > deal with rbtree.
> > 
> > Signed-off-by: Geliang Tang <geliangtang@gmail.com>
> > ---
> >  mm/backing-dev.c | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> > index 3bfed5ab..ffb77a1 100644
> > --- a/mm/backing-dev.c
> > +++ b/mm/backing-dev.c
> > @@ -410,8 +410,8 @@ wb_congested_get_create(struct backing_dev_info *bdi, int blkcg_id, gfp_t gfp)
> >  
> >  	while (*node != NULL) {
> >  		parent = *node;
> > -		congested = container_of(parent, struct bdi_writeback_congested,
> > -					 rb_node);
> > +		congested = rb_entry(parent, struct bdi_writeback_congested,
> > +				     rb_node);
> 
> I don't get the rb_entry() macro.  It's just another name for
> container_of().  I have no objection to the patch but this macro is a
> bit silly.
> 

There are several *_entry macros which are defined in kernel data
structures, like list_entry, hlist_entry, rb_entry, etc. Each of them is
just another name for container_of. We use different *_entry so that we
could identify the specific type of data structure that we are dealing
with.

-Geliang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
