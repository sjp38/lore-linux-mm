Date: Thu, 12 Jun 2008 03:24:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: repeatable slab corruption with LTP msgctl08
Message-Id: <20080612032442.930e62e4.akpm@linux-foundation.org>
In-Reply-To: <87mylrnj84.fsf@basil.nowhere.org>
References: <20080611221324.42270ef2.akpm@linux-foundation.org>
	<20080611233449.08e6eaa0.akpm@linux-foundation.org>
	<20080612010200.106df621.akpm@linux-foundation.org>
	<20080612011537.6146c41d.akpm@linux-foundation.org>
	<87mylrnj84.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Nadia Derbey <Nadia.Derbey@bull.net>, Manfred Spraul <manfred@colorfullife.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Jun 2008 10:35:55 +0200 Andi Kleen <andi@firstfloor.org> wrote:

> BTW a great way to debug slab corruptions with LTP faster is to run with
> a slab thrasher stress module like http://firstfloor.org/~andi/crasher-26.diff

Well I tried that.  It didn't actually seem to do much (no CPU time
consumed) so I revved it up a bit: 

--- a/drivers/char/crasher.c~crasher-26-speedup
+++ a/drivers/char/crasher.c
@@ -59,7 +59,7 @@ struct mem_buf {
 static unsigned long crasher_random(void)
 {
         rand_seed = rand_seed*69069L+1;
-        return rand_seed^jiffies;
+        return (rand_seed^jiffies) & 3;
 }
 
 void crasher_srandom(unsigned long entropy)
_


But it hasn't crashed after 57 minutes.

I don't think that is how we should fix this bug ;)

I'm pretty much out of time on this one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
