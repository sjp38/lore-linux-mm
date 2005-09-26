Subject: Re: update_mmu_cache(): fault or not fault ?
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1127715725.15882.43.camel@gaston>
References: <1127715725.15882.43.camel@gaston>
Content-Type: text/plain
Date: Mon, 26 Sep 2005 18:05:23 +1000
Message-Id: <1127721923.15882.67.camel@gaston>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> So I suggest adding an argument to it "int is_fault", that would
> basically be '1' on all the call sites in mm/memory.c and '0' in all the
> call sites in mm/fremap.c.
> 
> Any objection, comment, whatever, before I come up with a patch adding
> it to all archs ?

Acutally, that wouldn't work for calls to get_user_pages() which will
cause the fault code path on non-faults... looks like David's solution
is the best one at this point.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
