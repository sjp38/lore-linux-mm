Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 11B9F6B0078
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 00:13:27 -0500 (EST)
Date: Thu, 14 Jan 2010 05:13:08 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 1/8] vfs: fix too big f_pos handling
Message-ID: <20100114051308.GA14616@ZenIV.linux.org.uk>
References: <20100113140955.GA18593@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100113140955.GA18593@localhost>
Sender: owner-linux-mm@kvack.org
To: "Wu, Fengguang" <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 13, 2010 at 10:09:56PM +0800, Wu, Fengguang wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, rw_verify_area() checsk f_pos is negative or not. And if
> negative, returns -EINVAL.
> 
> But, some special files as /dev/(k)mem and /proc/<pid>/mem etc..
> has negative offsets. And we can't do any access via read/write
> to the file(device).
> 
> This patch introduce a flag S_VERYBIG and allow negative file
> offsets.

Ehh...  FMODE_NEG_OFFSET in file->f_mode, perhaps?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
