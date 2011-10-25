Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7EAC06B0031
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 05:47:47 -0400 (EDT)
Date: Tue, 25 Oct 2011 05:47:43 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: XFS deadlock the second
Message-ID: <20111025094743.GA17937@infradead.org>
References: <4EA5504D.9090302@profihost.ag>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4EA5504D.9090302@profihost.ag>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: "xfs@oss.sgi.com" <xfs@oss.sgi.com>, linux-mm@kvack.org

On Mon, Oct 24, 2011 at 01:47:25PM +0200, Stefan Priebe - Profihost AG wrote:
> Hi,
> 
> today i received another deadlock while running all your patches.
> 
> Output sysrq + w:
> http://pastebin.com/raw.php?i=YZGV6hxm

I just one process waiting for memory allocation in the networking code,
and two in XFS waiting for a page to be unlocked.  One during read, so
defintively waitin for I/O,  the other in write_begin so probably as
well.  If this didn't go away after a while it seems like a VM balancing
issue to me.

> 
> Stefan
> 
> _______________________________________________
> xfs mailing list
> xfs@oss.sgi.com
> http://oss.sgi.com/mailman/listinfo/xfs
---end quoted text---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
