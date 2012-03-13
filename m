Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 215EA6B007E
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 13:08:59 -0400 (EDT)
Date: Tue, 13 Mar 2012 10:08:51 -0700
From: Daniel Walker <dwalker@fifo99.com>
Subject: Re: [PATCH 0/5] Persist printk buffer across reboots.
Message-ID: <20120313170851.GA5218@fifo99.com>
References: <1331617001-20906-1-git-send-email-apenwarr@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1331617001-20906-1-git-send-email-apenwarr@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Avery Pennarun <apenwarr@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Josh Triplett <josh@joshtriplett.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "David S. Miller" <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Fabio M. Di Nitto" <fdinitto@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Olaf Hering <olaf@aepfle.de>, Paul Gortmaker <paul.gortmaker@windriver.com>, Tejun Heo <tj@kernel.org>, "H. Peter Anvin" <hpa@linux.intel.com>, Yinghai LU <yinghai@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Mar 13, 2012 at 01:36:36AM -0400, Avery Pennarun wrote:
> The last patch in this series implements a new CONFIG_PRINTK_PERSIST option
> that, when enabled, puts the printk buffer in a well-defined memory location
> so that we can keep appending to it after a reboot.  The upshot is that,
> even after a kernel panic or non-panic hard lockup, on the next boot
> userspace will be able to grab the kernel messages leading up to it.  It
> could then upload the messages to a server (for example) to keep crash
> statistics.

There's currently driver/mtd/mtdoops.c, fs/pstore/, and
drivers/staging/android/ram_console.c that do similar things
as this. Did you investigate those for potentially modifying them to add
this functionality ? If so what issues did you find?

I have a arm MSM G1 with persistent memory at 0x16d00000 size 20000bytes..
It's fairly simple you just have to ioremap the memory, but then it's good
for writing.. Currently the android ram_console uses this. How would I
convert this area for use with your changes?

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
