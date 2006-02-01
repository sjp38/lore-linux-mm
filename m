Date: Wed, 1 Feb 2006 15:59:13 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [discuss] Memory performance problems on Tyan VX50
In-Reply-To: <43E11968.6080906@t-platforms.ru>
Message-ID: <Pine.LNX.4.62.0602011555400.20831@schroedinger.engr.sgi.com>
References: <43DF7654.6060807@t-platforms.ru> <200602011539.40368.ak@suse.de>
 <Pine.LNX.4.62.0602010900200.16613@schroedinger.engr.sgi.com>
 <200602011816.35114.ak@suse.de> <43E11968.6080906@t-platforms.ru>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrey Slepuhin <pooh@t-platforms.ru>
Cc: Andi Kleen <ak@suse.de>, discuss@x86-64.org, Ray Bryant <raybry@mpdtxmail.amd.com>, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

> ffffffff801549ac -> include/linux/list.h:150

Hmm... That may indicate that something overwrites
page->lru. 

Wild guess: lru is placed after the spinlock used for
page table locking in struct page. Is this system using
per page page table locks?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
