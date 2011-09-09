Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 04A7A6B016E
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 16:47:23 -0400 (EDT)
Date: Fri, 9 Sep 2011 13:34:47 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH v2 0/3] staging: zcache: xcfmalloc support
Message-ID: <20110909203447.GB19127@kroah.com>
References: <1315404547-20075-1-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1315404547-20075-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: gregkh@suse.de, devel@driverdev.osuosl.org, dan.magenheimer@oracle.com, cascardo@holoscopio.com, linux-kernel@vger.kernel.org, dave@linux.vnet.ibm.com, linux-mm@kvack.org, brking@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com, ngupta@vflare.org

On Wed, Sep 07, 2011 at 09:09:04AM -0500, Seth Jennings wrote:
> Changelog:
> v2: fix bug in find_remove_block()
>     fix whitespace warning at EOF
> 
> This patchset introduces a new memory allocator for persistent
> pages for zcache.  The current allocator is xvmalloc.  xvmalloc
> has two notable limitations:
> * High (up to 50%) external fragmentation on allocation sets > PAGE_SIZE/2
> * No compaction support which reduces page reclaimation

I need some acks from other zcache developers before I can accept this.

{hint...}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
