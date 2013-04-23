Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 04D406B0002
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 21:26:44 -0400 (EDT)
Date: Tue, 23 Apr 2013 10:26:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 6/6] add documentation on proc.txt
Message-ID: <20130423012638.GB2603@blaptop>
References: <1366620306-30940-1-git-send-email-minchan@kernel.org>
 <1366620306-30940-6-git-send-email-minchan@kernel.org>
 <1366645719.18069.147@driftwood>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1366645719.18069.147@driftwood>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Landley <rob@landley.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Rik van Riel <riel@redhat.com>

Hello Rob,

On Mon, Apr 22, 2013 at 10:48:39AM -0500, Rob Landley wrote:
> On 04/22/2013 03:45:06 AM, Minchan Kim wrote:
> >This patch adds documentation about new reclaim field in proc.txt
> >
> >Cc: Rob Landley <rob@landley.net>
> >Signed-off-by: Minchan Kim <minchan@kernel.org>
> >---
> > Documentation/filesystems/proc.txt | 24 ++++++++++++++++++++++++
> > 1 file changed, 24 insertions(+)
> >
> >diff --git a/Documentation/filesystems/proc.txt
> >b/Documentation/filesystems/proc.txt
> >index 488c094..c1f5ee4 100644
> >--- a/Documentation/filesystems/proc.txt
> >+++ b/Documentation/filesystems/proc.txt
> >@@ -136,6 +136,7 @@ Table 1-1: Process specific entries in /proc
> >  maps		Memory maps to executables and library files	(2.4)
> >  mem		Memory held by this process
> >  root		Link to the root directory of this process
> >+ reclaim	Reclaim pages in this process
> >  stat		Process status
> >  statm		Process memory status information
> >  status		Process status in human readable form
> >@@ -489,6 +490,29 @@ To clear the soft-dirty bit
> >
> > Any other value written to /proc/PID/clear_refs will have no effect.
> >
> >+The /proc/PID/reclaim is used to reclaim pages in this process.
> 
> Trivial nitpick: Either start with "The file" or just /proc/PID/reclaim

I prefer "The file".

> 
> >+To reclaim file-backed pages,
> >+    > echo 1 > /proc/PID/reclaim
> >+
> >+To reclaim anonymous pages,
> >+    > echo 2 > /proc/PID/reclaim
> >+
> >+To reclaim both pages,
> >+    > echo 3 > /proc/PID/reclaim
> >+
> >+Also, you can specify address range of process so part of address
> >space
> >+will be reclaimed. The format is following as
> >+    > echo 4 addr size > /proc/PID/reclaim
> 
> Size is in bytes or pages? (I'm guessing bytes. It must be a
> multiple of pages?)

Hmm, current implementation doesn't force it but it sounds good.
I will do it in next spin. addr should be page-aligned but not necessary
to be for size.


> 
> So the following examples are telling it to reclaim a specific page?

Right.

> 
> >+To reclaim file-backed pages in address range,
> >+    > echo 4 $((1<<20) 4096 > /proc/PID/reclaim
> >+
> >+To reclaim anonymous pages in address range,
> >+    > echo 5 $((1<<20) 4096 > /proc/PID/reclaim
> >+
> >+To reclaim both pages in address range,
> >+    > echo 6 $((1<<20) 4096 > /proc/PID/reclaim
> >+
> > The /proc/pid/pagemap gives the PFN, which can be used to find
> >the pageflags
> > using /proc/kpageflags and number of times a page is mapped using
> > /proc/kpagecount. For detailed explanation, see
> >Documentation/vm/pagemap.txt.
> 
> Otherwise, if the series goes in I'm fine with this going in with it.
> 
> Acked-by: Rob Landley <rob@landley.net>

Thanks for the review!

> 
> Rob
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
