Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 343A96B0011
	for <linux-mm@kvack.org>; Tue, 31 May 2011 12:10:32 -0400 (EDT)
Subject: Re: [PATCH 14/14] tmpfs: no need to use i_lock
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <alpine.LSU.2.00.1105301754050.5482@sister.anvils>
References: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
	 <alpine.LSU.2.00.1105301754050.5482@sister.anvils>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 31 May 2011 09:08:10 -0700
Message-ID: <1306858090.2577.147.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2011-05-30 at 17:55 -0700, Hugh Dickins wrote:
> 2.6.36's 7e496299d4d2 to make tmpfs scalable with percpu_counter used
> inode->i_lock in place of sbinfo->stat_lock around i_blocks updates;
> but that was adverse to scalability, and unnecessary, since info->lock
> is already held there in the fast paths.
> 
> Remove those uses of i_lock, and add info->lock in the three error
> paths where it's then needed across shmem_free_blocks().  It's not
> actually needed across shmem_unacct_blocks(), but they're so often
> paired that it looks wrong to split them apart.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: Tim Chen <tim.c.chen@linux.intel.com>
> ---

Acked.  

Tim Chen



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
