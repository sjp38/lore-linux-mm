Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3761A6B025E
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 19:09:43 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id h186so3153716pfg.3
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 16:09:43 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id e62si5793998pfe.193.2016.07.18.16.09.42
        for <linux-mm@kvack.org>;
        Mon, 18 Jul 2016 16:09:42 -0700 (PDT)
Date: Mon, 18 Jul 2016 17:09:39 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH] radix-tree: fix radix_tree_iter_retry() for tagged
 iterators.
Message-ID: <20160718230939.GA2076@linux.intel.com>
References: <CACT4Y+a99OW7TYeLsuEic19uY2j45DGXL=LowUMq3TywWS3f2Q@mail.gmail.com>
 <1468495196-10604-1-git-send-email-aryabinin@virtuozzo.com>
 <20160714222527.GA26136@linux.intel.com>
 <5788A46A.70106@virtuozzo.com>
 <20160715190040.GA7195@linux.intel.com>
 <20160715135733.0a33f8f2bc3ee3fadb62b109@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160715135733.0a33f8f2bc3ee3fadb62b109@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, syzkaller@googlegroups.com, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, stable@vger.kernel.org

On Fri, Jul 15, 2016 at 01:57:33PM -0700, Andrew Morton wrote:
> On Fri, 15 Jul 2016 13:00:40 -0600 Ross Zwisler <ross.zwisler@linux.intel.com> wrote:
> 
> > 
> > ...
> >
> > In looking at this more, I agree that your patch fixes this particular bug,
> > but I think that ultimately we might want something more general.
> > 
> > ...
> >
> > --- a/include/linux/radix-tree.h
> > +++ b/include/linux/radix-tree.h
> > @@ -463,6 +463,9 @@ static inline struct radix_tree_node *entry_to_node(void *ptr)
> >  static __always_inline void **
> >  radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
> >  {
> > +	if (unlikely(!slot))
> > +		return NULL;
> > +
> >  	if (flags & RADIX_TREE_ITER_TAGGED) {
> >  		void *canon = slot;
> 
> I'll hang onto Andrey's
> radix-tree-fix-radix_tree_iter_retry-for-tagged-iterators.patch for
> now, plan to send it in to Linus Wednesdayish.  If we can get the above
> settled down prior to that then I shall swap over.

Sure, that works for me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
