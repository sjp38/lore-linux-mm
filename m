Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 76A148D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 09:48:09 -0400 (EDT)
Date: Wed, 30 Mar 2011 21:48:05 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Very aggressive memory reclaim
Message-ID: <20110330134804.GA10113@localhost>
References: <AANLkTinFqqmE+fTMTLVU-_CwPE+LQv7CpXSQ5+CdAKLK@mail.gmail.com>
 <4D90C071.7040205@mnsu.edu>
 <AANLkTikmQJFq633VNqNOMC-BfEC=BU=g7j5uW78P4B4Z@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTikmQJFq633VNqNOMC-BfEC=BU=g7j5uW78P4B4Z@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Lepikhin <johnlepikhin@gmail.com>
Cc: Jeffrey Hundstad <jeffrey.hundstad@mnsu.edu>, "linux-kernel@vger.kernel.org. Alexander Viro" <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

Hi John,

On Mon, Mar 28, 2011 at 10:50:56PM +0400, John Lepikhin wrote:
> 2011/3/28 Jeffrey Hundstad <jeffrey.hundstad@mnsu.edu>:
> 
> > I'd take a look here:
> > http://www.linuxinsight.com/proc_sys_vm_hierarchy.html
> 
> Yes, I already played with dirty_*, min_free_kbytes (3000kb),
> swappiness (0..100), vfs_cache_pressure (1..200) and zone_reclaim_mode
> (currently 0). Other parameters are set to defaults.
> 
> By the way, there is no swap enabled. Instead of just dropping 50% of
> page caches, kernel was intensively swapping then there was a swap
> device.

Is your memory usage balanced across the nodes? You can check it via
/sys/devices/system/node/node*/meminfo.

Are there lots of high-order memory allocations?  /proc/buddyinfo will
disclose some of them.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
