Date: Wed, 12 Apr 2006 10:37:12 +1000
From: David Chinner <dgc@sgi.com>
Subject: Re: [RFC] [PATCH] support for oom_die
Message-ID: <20060412003712.GB2732@melbourne.sgi.com>
References: <20060411142909.1899c4c4.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0604111025110.564@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0604111025110.564@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 11, 2006 at 10:28:32AM -0700, Christoph Lameter wrote:
> On Tue, 11 Apr 2006, KAMEZAWA Hiroyuki wrote:
> 
> > I think 2.6 kernel is very robust against OOM situation but sometimes
> > it occurs. Yes, oom_kill works enough and exit oom situation, *when*
> > the system wants to survive.
> 
> A user process can cause an oops by using too much memory? Would it not be 
> better to terminate the rogue process instead? Otherwise any user can 
> bring down the system?

In a HA environment, the OOM killer can take out the failover daemon
or other services and the failover infrastructure may not be able to
handle this gracefully and services will become unavailable. This is
about the worst thing that can happen in this environment.

In these situations, it is better to panic the box on OOM and get a
clean failover of services than risk having the OOM killer
compromise your HA setup.

Also, you typically don't have Random J. User logging in and running
stuff on HA server clusters, so if you're in an OOM situation there
is already something wrong that needs fixing.....

Cheers,

Dave.
-- 
Dave Chinner
R&D Software Enginner
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
