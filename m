Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 948096B004A
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 14:16:38 -0400 (EDT)
Date: Tue, 10 Apr 2012 14:16:32 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [Lsf] [RFC] writeback and cgroup
Message-ID: <20120410181631.GK21801@redhat.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404145134.GC12676@redhat.com>
 <20120407080027.GA2584@quack.suse.cz>
 <CAH2r5mvLVnM3Se5vBBsYzwaz5Ckp3i6SVnGp2T0XaGe9_u8YYA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAH2r5mvLVnM3Se5vBBsYzwaz5Ckp3i6SVnGp2T0XaGe9_u8YYA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve French <smfrench@gmail.com>
Cc: Jan Kara <jack@suse.cz>, ctalbott@google.com, rni@google.com, andrea@betterlinux.com, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, lsf@lists.linux-foundation.org, linux-mm@kvack.org, jmoyer@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Tue, Apr 10, 2012 at 11:23:16AM -0500, Steve French wrote:

[..]
> In the case of block device throttling - other than the file system
> internally using such APIs who would use block device specific
> throttling - only the file system knows where it wants to put hot data,
> and in the case of btrfs, doesn't the file system manage the
> storage pool.   The block device should be transparent to the
> user in the long run, and only the volume visible.

This is a good point. I guess this goes back to Jan's question of what's
the intended use case of absolute throttling. Having a dependency on 
per device limits has the drawback of user knowing exactly the details
of storage stack and it assumes that there is one single aggregation point
of block devices. (Which is not true in case of btrfs).

If user is simply looking for something like that I don't want a backup
process to be writing at more than 50MB/s (so that other processes doing
IO to same filesystem are effected less), then it is a case of global
throttling and per device throttling really does not gel well.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
