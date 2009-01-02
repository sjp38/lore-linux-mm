Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 740256B00CB
	for <linux-mm@kvack.org>; Fri,  2 Jan 2009 14:40:27 -0500 (EST)
Message-ID: <495E6DA2.8060901@oracle.com>
Date: Fri, 02 Jan 2009 11:40:18 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] Update of Documentation/
References: <20090102193116.8124.22532.stgit@hermosa.site>
In-Reply-To: <20090102193116.8124.22532.stgit@hermosa.site>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter W Morreale <pmorreale@novell.com>
Cc: linux-kernel@vger.kernel.org, riel@nl.linux.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Peter W Morreale wrote:
> This patch updates Documentation/sysctl/vm.txt and
> Documentation/filesystems/proc.txt.   More specifically, the section on
> /proc/sys/vm in Documentation/filesystems/proc.txt was removed and a
> link to Documentation/sysctl/vm.txt added.
> 
> Most of the verbiage from proc.txt was simply moved in vm.txt, with new
> addtional text for "swappiness" and "stat_interval".
> 
> This update applies against linux-next-20090102.
> 
> Best,
> -PWM
> ---
> 
> Signed-off-by: Peter W Morreale <pmorreale@novell.com>
> 
>  Documentation/filesystems/proc.txt |  266 ----------------
>  Documentation/sysctl/vm.txt        |  590 +++++++++++++++++++++++++-----------
>  2 files changed, 413 insertions(+), 443 deletions(-)

I get this when trying to apply the patch (using 'patch'), but I don't
see why (yet):


|diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
|index 334ef2f..0a9c66a 100644
|--- a/Documentation/filesystems/proc.txt
|+++ b/Documentation/filesystems/proc.txt
--------------------------
Patching file Documentation/filesystems/proc.txt using Plan A...
Hunk #1 succeeded at 5.
Hunk #2 succeeded at 1373.
Hmm...  The next patch looks like a unified diff to me...
The text leading up to this was:
--------------------------
|diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
|index e9a5c28..9c97c68 100644
|--- a/Documentation/sysctl/vm.txt
|+++ b/Documentation/sysctl/vm.txt
--------------------------
Patching file Documentation/sysctl/vm.txt using Plan A...
Hunk #1 succeeded at 1.
Hunk #2 FAILED at 17.
1 out of 2 hunks FAILED -- saving rejects to file Documentation/sysctl/vm.txt.rej
Hmm...missing header for unified diff at line 603 of patch
  The next patch looks like a unified diff to me...
can't find file to patch at input line 603
Perhaps you used the wrong -p or --strip option?
The text leading up to this was:
--------------------------
| 
--------------------------
File to patch:




-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
