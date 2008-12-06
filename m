Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mB60IYaR032634
	for <linux-mm@kvack.org>; Fri, 5 Dec 2008 17:18:34 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mB60Jxb9203622
	for <linux-mm@kvack.org>; Fri, 5 Dec 2008 17:19:59 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mB60JwC3016958
	for <linux-mm@kvack.org>; Fri, 5 Dec 2008 17:19:59 -0700
Date: Fri, 5 Dec 2008 18:19:57 -0600
From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC v11][PATCH 00/13] Kernel based checkpoint/restart
Message-ID: <20081206001957.GA29851@us.ibm.com>
References: <1228498282-11804-1-git-send-email-orenl@cs.columbia.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1228498282-11804-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Linux Torvalds <torvalds@osdl.org>, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, MinChan Kim <minchan.kim@gmail.com>, arnd@arndb.de, jeremy@goop.org
List-ID: <linux-mm.kvack.org>

Quoting Oren Laadan (orenl@cs.columbia.edu):
> Checkpoint-restart (c/r): fixed races in file handling (comments from
> from Al Viro). Updated and tested against v2.6.28-rc7 (feaf384...)
> 
> We'd like these to make it into -mm. This version addresses the
> last of the known bugs. Please pull at least the first 11 patches,
> as they are similar to before.
> 
> Patches 1-11 are stable, providing self- and external- c/r of a
> single process.
> Patches 12 and 13 are newer, adding support for c/r of multiple
> processes.
> 
> The git tree tracking v11, branch 'ckpt-v11' (and older versions):
> 	git://git.ncl.cs.columbia.edu/pub/git/linux-cr.git
> 
> Restarting multiple processes requires 'mktree' userspace tool:
> 	git://git.ncl.cs.columbia.edu/pub/git/user-cr.git

Thanks Oren, this set is working great for me.  hours of
(run in container; while (1) { checkpoint; kill; restart in container;}
went fine.  500 simultaneoush checkpoints of the same task
went fine.  mktree works great.

thanks,
-serge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
