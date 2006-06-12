Date: Mon, 12 Jun 2006 14:49:34 +0200 (MEST)
From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: Re: [PATCH]: Adding a counter in vma to indicate the number of
 physical pages backing it
In-Reply-To: <200606121317.44139.ak@suse.de>
Message-ID: <Pine.LNX.4.61.0606121449140.1125@yvahk01.tjqt.qr>
References: <1149903235.31417.84.camel@galaxy.corp.google.com>
 <1150042142.3131.82.camel@laptopd505.fenrus.org> <200606121317.44139.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Arjan van de Ven <arjan@infradead.org>, rohitseth@google.com, Andrew Morton <akpm@osdl.org>, Linux-mm@kvack.org, Linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>
>I agree it's a bad idea. smaps is only a debugging kludge anyways
>and it's not a good idea to we bloat core data structures for it.
>
Is there a way to disable it (smaps), then?


Jan Engelhardt
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
