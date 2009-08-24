Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id DF4666B0087
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 15:39:02 -0400 (EDT)
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by acsinet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n7PJdnKj007769
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 19:39:51 GMT
Date: Mon, 24 Aug 2009 09:01:21 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 0/4] compcache: compressed in-memory swapping
Message-Id: <20090824090121.61c6f0ea.randy.dunlap@oracle.com>
In-Reply-To: <200908241007.33844.ngupta@vflare.org>
References: <200908241007.33844.ngupta@vflare.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org
List-ID: <linux-mm.kvack.org>

On Mon, 24 Aug 2009 10:07:33 +0530 Nitin Gupta wrote:

> (Sorry for long patch[2/4] but its now very hard to split it up).
> 
>  Documentation/blockdev/00-INDEX       |    2 +
>  Documentation/blockdev/ramzswap.txt   |   52 ++
>  drivers/block/Kconfig                 |   22 +
>  drivers/block/Makefile                |    1 +
>  drivers/block/ramzswap/Makefile       |    2 +

I can't find drivers/block/ramzswap/Makefile in the patches...

>  drivers/block/ramzswap/ramzswap.c     | 1511 +++++++++++++++++++++++++++++++++
>  drivers/block/ramzswap/ramzswap.h     |  182 ++++
>  drivers/block/ramzswap/xvmalloc.c     |  556 ++++++++++++
>  drivers/block/ramzswap/xvmalloc.h     |   30 +
>  drivers/block/ramzswap/xvmalloc_int.h |   86 ++
>  include/linux/ramzswap_ioctl.h        |   51 ++
>  include/linux/swap.h                  |    5 +
>  mm/swapfile.c                         |   33 +
>  13 files changed, 2533 insertions(+), 0 deletions(-)


---
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
