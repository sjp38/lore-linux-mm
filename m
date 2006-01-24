Date: Mon, 23 Jan 2006 19:26:01 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [PATCH/RFC] Shared page tables
Message-ID: <7CE20BE034007D536E3724B3@[10.1.1.4]>
In-Reply-To: <200601240211.59171.ak@suse.de>
References: <A6D73CCDC544257F3D97F143@[10.1.1.4]>
 <200601240139.46751.ak@suse.de> <08A96D993E5CB2984F6F448A@[10.1.1.4]>
 <200601240211.59171.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Ray Bryant <raybry@mpdtxmail.amd.com>, Robin Holt <holt@sgi.com>, Hugh Dickins <hugh@veritas.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--On Tuesday, January 24, 2006 02:11:58 +0100 Andi Kleen <ak@suse.de> wrote:

> Really? That sounds like a quite bad idea because it can easily break
> if something changes in the way virtual memory is laid out (which
> has happened - e.g. movement to 4level page tables on x86-64 and now
> randomized mmaps) 
> 
> I don't think we should encourage such unportable behaviour.

I haven't looked into how they do it.  It could be as simple as mapping the
memory region, then forking all the processes that use it.  Or they could
be communicating the mapped address to the other processes dynamically via
some other mechanism.  All I know is the memory ends up being mapped at the
same address in all processes.

Or are you saying using the same address is a bad thing even if it's
determined at runtime?

Dave McCracken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
