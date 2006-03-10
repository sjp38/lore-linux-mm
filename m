From: Nick Piggin <npiggin@suse.de>
Message-Id: <20060207021822.10002.30448.sendpatchset@linux.site>
Subject: A lockless pagecache for Linux
Date: Fri, 10 Mar 2006 16:18:09 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
Cc: Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi,

I was waiting for 2.6.16 before releasing my patchset, but that got
boring.

ftp://ftp.kernel.org/pub/linux/kernel/people/npiggin/patches/lockless/2.6.16-rc5/

Now I've used some clever subject lines on the subsequent patches
to make you think this isn't a big deal. Actually there are about
36 other "prep" patches before those, and PageReserved removal before
that (which are luckily now mostly in -mm or -linus, respectively).
What's more, there aren't 3 lockless pagecache patches, there are
5 -- but the last two are optimisations.

I'm writing some stuff about these patches, and I've uploaded a
**draft** chapter on the RCU radix-tree, 'radix-intro.pdf' in above
directory (note the bibliography didn't make it -- but thanks Paul
McKenney!)

If anyone would like to test or review it, I would be very happy.
Suggestions to the code or document would be very welcome... but
I'm still hoping nobody spots a fundamental flaw until after OLS.

Rollup of prep patches (5 posted patches apply to the top of this):
2.6.16-rc5-git14-prep.patch.gz

Rollup of prep+lockless patches (includes the 5 posted patches):
2.6.16-rc5-git14-lockless.patch.gz

Note: anyone interested in benchmarking should test prep+rollup vs
prep rather than vs mainline if possible, because there are various
other optimisations in prep.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
