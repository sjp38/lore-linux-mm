Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 78B1B6B0044
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 09:54:17 -0400 (EDT)
From: Nikanth Karthikesan <knikanth@suse.de>
Subject: Re: [RFC] [PATCH] Avoid livelock for fsync
Date: Tue, 27 Oct 2009 19:26:14 +0530
References: <20091026181314.GE7233@duck.suse.cz>
In-Reply-To: <20091026181314.GE7233@duck.suse.cz>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Message-Id: <200910271926.15176.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: WU Fengguang <wfg@mail.ustc.edu.cn>, npiggin@suse.de, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, hch@infradead.org, chris.mason@oracle.com
List-ID: <linux-mm.kvack.org>

On Monday 26 October 2009 23:43:14 Jan Kara wrote:
>   Hi,
> 
>   on my way back from Kernel Summit, I've coded the attached patch which
> implements livelock avoidance for write_cache_pages. We tag patches that
> should be written in the beginning of write_cache_pages and then write
> only tagged pages (see the patch for details). The patch is based on Nick's
> idea.

As I understand, livelock can be caused only by dirtying new pages.

So theoretically, if a process can dirty pages faster than we can tag pages 
for writeback, even now isn't there a chance for livelock? But if it is really 
a very fast operation and livelock is not possible, why not hold the tree_lock 
during the entire period of tagging the pages for writeback i.e., call 
tag_pages_for_writeback() under mapping->tree_lock? Would it cause 
deadlock/starvation or some other serious problems?

Thanks
Nikanth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
