Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id BEBFE6B004D
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 13:20:26 -0400 (EDT)
Date: Thu, 28 Jun 2012 19:20:20 +0200
From: Paul Slootman <paul@wurtel.net>
Subject: Re: memory leak in recent (3.x) kernels?
Message-ID: <20120628172020.GB4389@msgid.wurtel.net>
References: <20120622112614.GA17413@msgid.wurtel.net>
 <20120628152208.GA16222@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120628152208.GA16222@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 28 Jun 2012, Michal Hocko wrote:
> On Fri 22-06-12 13:26:14, Paul Slootman wrote:

> > Perhaps I'm triggering something that exists since before 3.0, but
> > anyway:
> > 
> > After some time, all swap space gets gradually used up, without a clear
> > indication what's using it (at least, I haven't managed to find out).
> > 
> > System is running debian testing, and most usage is a lot of rxvt
> > processes mostly ssh'ed out to other systems, and google chrome.
> > I suspect google chrome may be the cause of the problem.
> > Root is btrfs, /home is NFS.
> > 
> > The system earlier had 4GB RAM and swap is currently 5 x 2GB LVM
> > partitions. With that config I needed to reboot after about a week, as
> > the system ended up thrashing the swap.  I've added 8GB RAM, and now the
> > uptime is 42 days, system still usable.
> > 
> > Stopping google-chrome at such a point in time usually does not help.
> > 
> > At every reboot I upgrade to the latest kernel :) Currently running
> > 3.4.0-rc6, but I saw the same behaviour with all 3.x kernels I tried.

Memory was full again yesterday, at which point I tried 3.5.0-rc4.
Unfortunately something there (or something I may have changed in the
config) prevents my google chrome from starting all of my open tabs;
about 1/3 remain blank with a loading spinner running. Opening a new tab
and entering one of those URLs gives "window not responding" error after
some time. Wierd.


> > I would have thought that with almost 10GB memory free (w/o cache) such
> > a swapoff should succeed.  I also wonder why that 9GB cached memory is
> > being held; it's not released after echo 3 > drop_caches .

> > Shmem:           9181016 kB <<<

> Because the most of the memory is anonymous and shmem.
> ipcs -pm should tell you about the current segments and pids behind.

OK, I'll do that the next time, thanks. I hadn't noticed the Shmem line
(I didn't really know where to begin looking :-)
I find it a bit unexpected that this is shown by "free" as cached
memory.

I did notice however, that after restarting the X server the memory
apparently _was_ released (stopping all the windows didn't seem to
help).



Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
