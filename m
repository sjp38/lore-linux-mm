Date: Sat, 12 Jan 2008 23:59:07 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 2/2] updating ctime and mtime at syncing
Message-ID: <20080112235907.05fc44d4@bree.surriel.com>
In-Reply-To: <12001992023392-git-send-email-salikhmetov@gmail.com>
References: <12001991991217-git-send-email-salikhmetov@gmail.com>
	<12001992023392-git-send-email-salikhmetov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Salikhmetov <salikhmetov@gmail.com>
Cc: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com
List-ID: <linux-mm.kvack.org>

On Sun, 13 Jan 2008 07:39:59 +0300
Anton Salikhmetov <salikhmetov@gmail.com> wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=2645
> 
> Changes for updating the ctime and mtime fields for memory-mapped files:
> 
> 1) new flag triggering update of the inode data;
> 2) new function to update ctime and mtime for block device files;
> 3) new helper function to update ctime and mtime when needed;
> 4) updating time stamps for mapped files in sys_msync() and do_fsync();
> 5) implementing the feature of auto-updating ctime and mtime.
> 
> Signed-off-by: Anton Salikhmetov <salikhmetov@gmail.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
