Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2A41E8D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 02:40:00 -0500 (EST)
Date: Fri, 4 Mar 2011 08:39:44 +0100
From: Daniel Poelzleithner <poelzi@poelzi.org>
Message-ID: <20110304083944.22fb612f@sol>
Reply-To: linux-kernel@vger.kernel.org
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Subject: cgroup memory, blkio and the lovely swapping
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, containers@lists.linux-foundation.org

Hi,

currently when one process causes heavy swapping, the responsiveness of
the hole system suffers greatly. With the small memleak [1] test tool I
wrote, the effect can be experienced very easily, depending on the
delay the lag can become quite large. If I ensure that 10% of the RAM
stay free for free memory and cache, the system never swaps to death.
That works very well, but if accesses to the swap are very heavy, the
system still lags on all other processes, not only the swapping one.
Putting the swapping process into a blkio cgroup with little weight does
not affect the io or swap io from other processes with larger weight in
their group.

Maybe I'm mistaken, but wouldn't it be the easiest way to get fair
swapping and control to let the pagein respect the blkio.weight value
or even better add a second weight value for swapping io ?



kind regards
  Daniel


[1] https://github.com/poelzi/ulatencyd/blob/master/tests/memleak.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
