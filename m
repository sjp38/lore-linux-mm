Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7F2F46B004D
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 12:30:50 -0400 (EDT)
Message-ID: <4A31316C.8050007@redhat.com>
Date: Thu, 11 Jun 2009 12:31:40 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] HWPOISON: report sticky EIO for poisoned file
References: <20090611142239.192891591@intel.com> <20090611144430.813191526@intel.com>
In-Reply-To: <20090611144430.813191526@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Wu Fengguang wrote:
> This makes the EIO reports on write(), fsync(), or the NFS close()
> sticky enough. The only way to get rid of it may be
> 
> 	echo 3 > /proc/sys/vm/drop_caches
> 
> Note that the impacted process will only be killed if it mapped the page.
> XXX
> via read()/write()/fsync() instead of memory mapped reads/writes, simply
> because it's very hard to find them.
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
