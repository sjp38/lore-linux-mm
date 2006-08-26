Date: Sat, 26 Aug 2006 14:36:23 +0000
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 6/6] nfs: Enable swap over NFS
Message-ID: <20060826143622.GA5260@ucw.cz>
References: <20060825153709.24254.28118.sendpatchset@twins> <20060825153812.24254.9718.sendpatchset@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060825153812.24254.9718.sendpatchset@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Rik van Riel <riel@redhat.com>, Trond Myklebust <trond.myklebust@fys.uio.no>
List-ID: <linux-mm.kvack.org>

Hi!

> Now that NFS can handle swap cache pages, add a swapfile method to allow
> swapping over NFS.
> 
> NOTE: this dummy method is obviously not enough to make it safe.
> A more complete version of the nfs_swapfile() function will be present
> in the next VM deadlock avoidance patches.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

We probably do not want to enable functionality before it is safe...

Also swsusp interactions will be interesting. (Rafael is working on
swapfile support these days).
						Pavel
-- 
Thanks for all the (sleeping) penguins.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
