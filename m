Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 793926B0068
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 19:20:34 -0400 (EDT)
Date: Thu, 1 Nov 2012 19:20:30 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: shmem_getpage_gfp VM_BUG_ON triggered. [3.7rc2]
Message-ID: <20121101232030.GA25519@redhat.com>
References: <20121025023738.GA27001@redhat.com>
 <alpine.LNX.2.00.1210242121410.1697@eggly.anvils>
 <20121101191052.GA5884@redhat.com>
 <alpine.LNX.2.00.1211011546090.19377@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1211011546090.19377@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Nov 01, 2012 at 04:03:40PM -0700, Hugh Dickins wrote:
 > > I just noticed we had a user report hitting this same warning, but
 > > with a different trace..
 > > 
 > > : [<ffffffff8105b84f>] warn_slowpath_common+0x7f/0xc0
 > > : [<ffffffff8105b8aa>] warn_slowpath_null+0x1a/0x20
 > > : [<ffffffff81143c73>] shmem_getpage_gfp+0x7f3/0x830
 > > : [<ffffffff81158c9d>] ? vma_adjust+0x3ed/0x620
 > > : [<ffffffff81143f02>] shmem_file_aio_read+0x1f2/0x380
 > > : [<ffffffff8118e487>] do_sync_read+0xa7/0xe0
 > > : [<ffffffff8118eda9>] vfs_read+0xa9/0x180
 > > : [<ffffffff8118eeca>] sys_read+0x4a/0x90
 > > : [<ffffffff816226e9>] system_call_fastpath+0x16/0x1b
 > 
 > Equally explicable by Hannes's hypothesis;
 > but useful supporting evidence, thank you.
 > 
 > Except... earlier in the thread you explained how you hacked
 > #define VM_BUG_ON(cond) WARN_ON(cond)
 > to get this to come out as a warning instead of a bug,
 > and now it looks as if "a user" has here done the same.
 > 
 > Which is very much a user's right, of course; but does
 > make me wonder whether that user might actually be davej ;)

indirectly. I made the same change in the Fedora kernel a while ago
to test a hypothesis that we weren't getting any VM_BUG_ON reports.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
