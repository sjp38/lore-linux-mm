Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4BCE06B0007
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 08:36:37 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p17so6736004wre.7
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 05:36:37 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f37si3698018wra.355.2018.04.04.05.36.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Apr 2018 05:36:35 -0700 (PDT)
Date: Wed, 4 Apr 2018 14:36:34 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: WARNING in account_page_dirtied
Message-ID: <20180404123634.6wz5ctjkryzm5nf7@quack2.suse.cz>
References: <001a113ff9ca1684ab0568cc6bb6@google.com>
 <20180403120529.z3mthf2v64he52gg@quack2.suse.cz>
 <b81bbecb-1c3c-ca92-84a5-15db63611db6@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b81bbecb-1c3c-ca92-84a5-15db63611db6@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Whitehouse <swhiteho@redhat.com>
Cc: Jan Kara <jack@suse.cz>, syzbot <syzbot+b7772c65a1d88bfd8fca@syzkaller.appspotmail.com>, akpm@linux-foundation.org, axboe@kernel.dk, hannes@cmpxchg.org, jlayton@redhat.com, keescook@chromium.org, laoar.shao@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, syzkaller-bugs@googlegroups.com, tytso@mit.edu, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

Hi,

On Wed 04-04-18 10:24:48, Steven Whitehouse wrote:
> On 03/04/18 13:05, Jan Kara wrote:
> > Hello,
> > 
> > On Sun 01-04-18 10:01:02, syzbot wrote:
> > > syzbot hit the following crash on upstream commit
> > > 10b84daddbec72c6b440216a69de9a9605127f7a (Sat Mar 31 17:59:00 2018 +0000)
> > > Merge branch 'perf-urgent-for-linus' of
> > > git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
> > > syzbot dashboard link:
> > > https://syzkaller.appspot.com/bug?extid=b7772c65a1d88bfd8fca
> > > 
> > > C reproducer: https://syzkaller.appspot.com/x/repro.c?id=5705587757154304
> > > syzkaller reproducer:
> > > https://syzkaller.appspot.com/x/repro.syz?id=5644332530925568
> > > Raw console output:
> > > https://syzkaller.appspot.com/x/log.txt?id=5472755969425408
> > > Kernel config:
> > > https://syzkaller.appspot.com/x/.config?id=-2760467897697295172
> > > compiler: gcc (GCC) 7.1.1 20170620
> > > 
> > > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > > Reported-by: syzbot+b7772c65a1d88bfd8fca@syzkaller.appspotmail.com
> > > It will help syzbot understand when the bug is fixed. See footer for
> > > details.
> > > If you forward the report, please keep this part and the footer.
> > > 
> > > gfs2: fsid=loop0.0: jid=0, already locked for use
> > > gfs2: fsid=loop0.0: jid=0: Looking at journal...
> > > gfs2: fsid=loop0.0: jid=0: Done
> > > gfs2: fsid=loop0.0: first mount done, others may mount
> > > gfs2: fsid=loop0.0: found 1 quota changes
> > > WARNING: CPU: 0 PID: 4469 at ./include/linux/backing-dev.h:341 inode_to_wb
> > > include/linux/backing-dev.h:338 [inline]
> > > WARNING: CPU: 0 PID: 4469 at ./include/linux/backing-dev.h:341
> > > account_page_dirtied+0x8f9/0xcb0 mm/page-writeback.c:2416
> > > Kernel panic - not syncing: panic_on_warn set ...
> > > 
> > > CPU: 0 PID: 4469 Comm: syzkaller368843 Not tainted 4.16.0-rc7+ #9
> > > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> > > Google 01/01/2011
> > > Call Trace:
> > >   __dump_stack lib/dump_stack.c:17 [inline]
> > >   dump_stack+0x194/0x24d lib/dump_stack.c:53
> > >   panic+0x1e4/0x41c kernel/panic.c:183
> > >   __warn+0x1dc/0x200 kernel/panic.c:547
> > >   report_bug+0x1f4/0x2b0 lib/bug.c:186
> > >   fixup_bug.part.10+0x37/0x80 arch/x86/kernel/traps.c:178
> > >   fixup_bug arch/x86/kernel/traps.c:247 [inline]
> > >   do_error_trap+0x2d7/0x3e0 arch/x86/kernel/traps.c:296
> > >   do_invalid_op+0x1b/0x20 arch/x86/kernel/traps.c:315
> > >   invalid_op+0x1b/0x40 arch/x86/entry/entry_64.S:986
> > > RIP: 0010:inode_to_wb include/linux/backing-dev.h:338 [inline]
> > > RIP: 0010:account_page_dirtied+0x8f9/0xcb0 mm/page-writeback.c:2416
> > > RSP: 0018:ffff8801d966e5c0 EFLAGS: 00010093
> > > RAX: ffff8801acb7e600 RBX: 1ffff1003b2cdcba RCX: ffffffff818f47a9
> > > RDX: 0000000000000000 RSI: ffff8801d3338148 RDI: 0000000000000082
> > > RBP: ffff8801d966e698 R08: 1ffff1003b2cdc13 R09: 000000000000000c
> > > R10: ffff8801d966e558 R11: 0000000000000002 R12: ffff8801c96f0368
> > > R13: ffffea0006b12780 R14: ffff8801c96f01d8 R15: ffff8801c96f01d8
> > >   __set_page_dirty+0x100/0x4b0 fs/buffer.c:605
> > >   mark_buffer_dirty+0x454/0x5d0 fs/buffer.c:1126
> > Huh, I don't see how this could possibly happen. The warning is:
> > 
> >          WARN_ON_ONCE(debug_locks &&
> >                       (!lockdep_is_held(&inode->i_lock) &&
> >                        !lockdep_is_held(&inode->i_mapping->tree_lock) &&
> >                        !lockdep_is_held(&inode->i_wb->list_lock)));
> > 
> > Now __set_page_dirty() which called account_page_dirtied() just did:
> > 
> > spin_lock_irqsave(&mapping->tree_lock, flags);
> > 
> > Now the fact is that account_page_dirtied() actually checks
> > mapping->host->i_mapping->tree_lock so if mapping->host->i_mapping doesn't
> > get us back to 'mapping', that would explain the warning. But then
> > something would have to be very wrong in the GFS2 land... Adding some GFS2
> > related CCs just in case they have some idea.
> So I looked at this for some time trying to work out what is going on. I'm
> sill not 100% sure now, but lets see if we can figure it out....
> 
> The stack trace shows a call path to the end of the journal flush code where
> we are unpinning pages that have been through the journal. Assuming that
> jdata is not in use (it is used for some internal files, even if it is not
> selected by the user) then it is most likely that this applies to a metadata
> page.
> 
> For recent gfs2, all the metadata pages are kept in an address space which
> for inodes is in the relevant glock, and for resource groups is a single
> address space kept for only that purpose in the super block. In both of
> those cases the mapping->host points to the block device inode. Since the
> inode's mapping->host reflects only the block device address space (unused
> by gfs2) we would not expect it to point back to the relevant address space.
> 
> As far as I can tell this usage is ok, since it doesn't make much sense to
> require lots of inodes to be hanging around uselessly just to keep metadata
> pages in. That after all, is why the address space and inode are separate
> structures in the first place since it is not a one to one relationship. So
> I think that probably explains why this triggers, since the test is not
> really a valid one in all cases,

The problem is we really do expect mapping->host->i_mapping == mapping as
we pass mapping and inode interchangebly in the mm code. The address_space
and inodes are separate structures because you can have many inodes
pointing to one address space (block devices). However it is not allowed
for several address_spaces to point to one inode! That way mm code may end
up using different address_spaces in different places although they should
be the same one as is the case in this assert... Probably you use these
address_spaces in a very limited way and so things seem to work but it is
really a pure coincidence. From a very quick look you seem to be using
these special address_spaces to track dirty metadata associated with an
inode? Anything else?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
