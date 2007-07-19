Message-ID: <384813965.25550@ustc.edu.cn>
Date: Thu, 19 Jul 2007 10:59:27 +0800
From: Fengguang Wu <fengguang.wu@gmail.com>
Subject: Re: [patch] fix periodic superblock dirty inode flushing
Message-ID: <20070719025927.GA11874@mail.ustc.edu.cn>
References: <b040c32a0707112121y21d08438u8ca7f138931827b0@mail.gmail.com> <20070712120519.8a7241dd.akpm@linux-foundation.org> <b040c32a0707131517m4cc20d3an2123e324746d3e7@mail.gmail.com> <b040c32a0707161701q49ad150di6387b029a39b39c3@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b040c32a0707161701q49ad150di6387b029a39b39c3@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 16, 2007 at 05:01:31PM -0700, Ken Chen wrote:
> On 7/13/07, Ken Chen <kenchen@google.com> wrote:
> >On 7/12/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> >> Was this tested in combination with check_dirty_inode_list.patch,
> >> to make sure that the time-orderedness is being retained?
> >
> >I think I tested with the debug patch.  And just to be sure, I ran the
> >test again with the time-order check in place.  It passed the test.
> 
> I ran some more tests over the weekend with the debug turned on. There
> are a few fall out that the order-ness of sb-s_dirty is corrupted.  We
> probably should drop this patch until I figure out a real solution to
> this.
> 
> One idea is to use rb-tree for sorting and use a in-tree dummy node as
> a tree iterator.  Do you think that will work better?  I will hack on
> that.

Sorry if I'm not backgrounded.

But what's the problem of a list? If we always do the two actions
*together*:
        1) update inode->dirtied_when
        2) requeue inode in the correct place
the list will be in order.
linux-2.6.22-rc6-mm1/fs/fs-writeback.c obviously obeys this rule.

I don't see how can a new data structure make life easier.
1) and 2) should still be safeguarded, isn't it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
