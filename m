Date: Thu, 20 Sep 2007 03:24:41 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH/RFC 2/14] Reclaim Scalability:  convert inode
	i_mmap_lock to reader/writer lock
Message-ID: <20070920012441.GQ4608@v2.random>
References: <20070914205359.6536.98017.sendpatchset@localhost> <20070914205412.6536.34898.sendpatchset@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070914205412.6536.34898.sendpatchset@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, Sep 14, 2007 at 04:54:12PM -0400, Lee Schermerhorn wrote:
> Note:  This patch is meant to address a situation I've seen
> running large Oracle OLTP workload--1000s of users--on an
> large HP ia64 NUMA platform.  The system hung, spitting out
> "soft lockup" messages on the console.  Stack traces showed
> that all cpus were in page_referenced(), as mentioned above.
> I let the system run overnight in this state--it never
> recovered before I decided to reboot.

Just to understand better, was that an oom condition? Can you press
SYSRQ+M to check the RAM and swap levels? If it's an oom condition the
problem may be quite different.

Still making those spinlocks rw sounds good to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
