Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 635D36003C1
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 19:55:14 -0500 (EST)
Date: Tue, 26 Jan 2010 19:55:10 -0500
From: Jeff Dike <jdike@addtoit.com>
Subject: Re: which fields in /proc/meminfo are orthogonal?
Message-ID: <20100127005510.GA8637@c2.user-mode-linux.org>
References: <4B5F3C9C.3050908@nortel.com> <4B5F54DE.7030302@nortel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B5F54DE.7030302@nortel.com>
Sender: owner-linux-mm@kvack.org
To: Chris Friesen <cfriesen@nortel.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 02:47:26PM -0600, Chris Friesen wrote:
> I've tried adding up
> MemFree+Buffers+Cached+AnonPages+Mapped+Slab+PageTables+VmallocUsed
> 
> (hugepages are disabled and there is no swap)
> 
> Shortly after boot this gets me within about 3MB of MemTotal.  However,
> after 1070 minutes there is a 64MB difference between MemTotal and the
> above sum.

I believe that pages allocated directly with get_free_pages won't show
up in your sum.  So, just look for someone doing a lot of that :-)

				Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
