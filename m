Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA04152
	for <linux-mm@kvack.org>; Tue, 18 Nov 1997 07:15:46 -0500
Date: Tue, 18 Nov 1997 11:47:26 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: vhand-2.1.64... problems solved
Message-ID: <Pine.LNX.3.91.971118113503.416A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-kernel <linux-kernel@vger.rutgers.edu>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi there,

I've found the cause for vhand eating too much memory. Well, I think
I have... I think it is because kswapd would wake up vhand after 3
failures, while vhand would guarantee that 1/32nd of memory is ready
to swap out... Now, putting KSWAPD_MAX_FAIL at 128 (!) has alleviated
this problem, it's not over yet, but at least it's not severe.
(at the moment I'm looking at an uncharged kswapd and 5% max for
vhand. probably vhand gets billed for kswapd :-)
... somebody with an Alpha (HZ=1024) should take a closer look at 
this...

I also merged my patch with the excellent network_atomic_alloc_59
patch from Zlato Calusic <Zlato.Calusic@CARNet.hr>. Thanks Zlato!

-------------
Vhand is a patch that improves system responsiveness when memory
is short. It does this by also aging shared memory and buffers.
It also applies a fairer aging sceme to the aging of normal
program pages.
Although this patch is reported to be rock-solid, I still consider
it Beta. This is mainly because I've only had about 15 success
stories in my mailbox (and no failures:-).

You can find the patch on linux-mama <http://www.huwig.de/linux/mama/>
and on my home page <http://www.fys.ruu.nl/~riel/>.
-------------

Please send success-stories, bug-reports, bugfixes and flames
to me. Anything will help...

Rik.

----------
Send Linux memory-management wishes to me: I'm currently looking
for something to hack...
