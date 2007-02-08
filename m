Subject: Re: [patch 0/3] 2.6.20 fix for PageUptodate memorder problem (try
	2)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20070208111421.30513.77904.sendpatchset@linux.site>
References: <20070208111421.30513.77904.sendpatchset@linux.site>
Content-Type: text/plain
Date: Fri, 09 Feb 2007 09:21:50 +1100
Message-Id: <1170973310.2620.369.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-02-08 at 14:26 +0100, Nick Piggin wrote:
> Still no independent confirmation as to whether this is a problem or not.
> Updated some comments, added diffstats to patches, don't use __SetPageUptodate
> as an internal page-flags.h private function.
> 
> I would like to eventually get an ack from Hugh regarding the anon memory
> and especially swap side of the equation, and a glance from whoever put the
> smp_wmb()s into the copy functions (Was it Ben H or Anton maybe?)

I don't remember adding that one ... Anton ?

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
