Date: Thu, 8 Jan 2004 12:50:08 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.1-rc2-mm1
Message-Id: <20040108125008.228dd6fe.akpm@osdl.org>
In-Reply-To: <1073594191.1618.13.camel@moria.arnor.net>
References: <20040107232831.13261f76.akpm@osdl.org>
	<1073593346.1618.3.camel@moria.arnor.net>
	<1073594191.1618.13.camel@moria.arnor.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Torrey Hoffman <thoffman@arnor.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Torrey Hoffman <thoffman@arnor.net> wrote:
>
> ... And another kernel error about two minutes later than the ones
> below. This happened while starting up my X desktop and apps. The
> gnome-notification-applet failed to start, and Mozilla doesn't appear
> start up properly for me in rc2-mm1. However, Evolution is sending and
> receiving mail ok...  
> 
> I'll reboot to -rc2-vanilla and see if I can reproduce the problem
> there.  (same .config was used on both -rc2-vanilla and -rc2-mm1)
> 
> Jan  8 12:18:27 moria kernel:  <3>Debug: sleeping function called from
> invalid context at mm/page_alloc.c:550
> Jan  8 12:18:27 moria kernel: in_atomic():1, irqs_disabled():0
> Jan  8 12:18:27 moria kernel: Call Trace:
> Jan  8 12:18:27 moria kernel:  [<c012420c>] __might_sleep+0xab/0xc9
> Jan  8 12:18:27 moria kernel:  [<c0146d80>] __alloc_pages+0x341/0x346
> Jan  8 12:18:27 moria kernel:  [<c011ee17>] pte_alloc_one+0x20/0x56
> Jan  8 12:18:27 moria kernel:  [<c0150185>] pte_alloc_map+0x4e/0x111
> Jan  8 12:18:27 moria kernel:  [<c014395f>]
> filemap_populate_nonblock+0x2a1/0x2ce

Yes, this one's a locking problem in the new filemap code.

I'm not sure why people are seeing oopses in the poll code - I hope
networking didn't break.

Oh well, it looks like 2.6.1-rc2-mm1 is a dud.  I'll drop a few things and
do rc3-mm1 tonight.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
