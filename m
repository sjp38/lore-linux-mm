Date: Fri, 23 Sep 2005 14:57:46 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Use node macros for memory policies
Message-Id: <20050923145746.77a846b7.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.62.0509231109001.22542@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0509231109001.22542@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: ak@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@engr.sgi.com> wrote:
>
> Use node macros for memory policies
> 
> 1. Use node macros throughout instead of bitmaps
> 
> 3. Blank fixes and clarifying comments.

There's already a patch in -mm which does this.  There are differences, so
please review
ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.14-rc2/2.6.14-rc2-mm1/broken-out/convert-mempolicies-to-nodemask_t.patch

Which typedef weenie inflicted nodemask_t upon us anyway?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
