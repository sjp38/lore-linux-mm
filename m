Message-ID: <401F7382.3030507@gmx.de>
Date: Tue, 03 Feb 2004 11:10:10 +0100
From: "Prakash K. Cheemplavam" <PrakashKC@gmx.de>
MIME-Version: 1.0
Subject: Re: 2.6.2-rc3-mm1
References: <20040202235817.5c3feaf3.akpm@osdl.org> <401F70E1.5070408@gmx.de>
In-Reply-To: <401F70E1.5070408@gmx.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Prakash K. Cheemplavam wrote:
> Hi,
> 
> I am getting this on init. I think while udev inits:
> 
> i_size_write() called without i_sem
> Feb  3 10:53:53 tachyon Call Trace:
> Feb  3 10:53:53 tachyon [<c013d347>] i_size_write_check+0x57/0x60
> Feb  3 10:53:53 tachyon [<c01767de>] simple_commit_write+0x3e/0xa0
> Feb  3 10:53:53 tachyon [<c0167f3c>] page_symlink+0xec/0x1dd
> Feb  3 10:5i_size_write() called without i_sem
> Feb  3 10:53:53 tachyon Call Trace:
> Feb  3 10:53:53 tachyon [<c013d347>] i_size_write_check+0x57/0x60
> Feb  3 10:53:53 tachyon [<c01767de>] simple_commit_write+0x3e/0xa0
> Feb  3 10:53:53 tachyon [<c0167f3c>] page_symlink+0xec/0x1dd
> Feb  3 10:53:53 tachyon [<c01bbbdd>] ramfs_symlink+0x5d/0xc0
> Feb  3 10:53:53 tachyon [<c0166e37>] vfs_symlink+0x57/0xb0
> Feb  3 10:53:53 tachyon [<c0166f63>] sys_symlink+0xd3/0xf0
> Feb  3 10:53:53 tachyon [<c038fa86>] sysenter_past_esp+0x43/0x65
> 3:53 tachyon [<c01bbbdd>] ramfs_symlink+0x5d/0xc0
> Feb  3 10:53:53 tachyon [<c0166e37>] vfs_symlink+0x57/0xb0
> Feb  3 10:53:53 tachyon [<c0166f63>] sys_symlink+0xd3/0xf0
> Feb  3 10:53:53 tachyon [<c038fa86>] sysenter_past_esp+0x43/0x65

BTW, my root is reiserfs, my boot ext2, which shouldn't be mounted by 
default, so this is reiferfs case.

Prakash
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
