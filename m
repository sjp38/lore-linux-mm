Date: Thu, 4 Aug 2005 13:39:41 +0200
From: Andi Kleen <ak@suse.de>
Subject: Getting rid of SHMMAX/SHMALL ?
Message-ID: <20050804113941.GP8266@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: cr@sap.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I noticed that even 64bit architectures have a ridiculously low 
max limit on shared memory segments by default:

#define SHMMAX 0x2000000                 /* max shared seg size (bytes) */
#define SHMMNI 4096                      /* max num of segs system wide */
#define SHMALL (SHMMAX/PAGE_SIZE*(SHMMNI/16)) /* max shm system wide (pages) */

Even on 32bit architectures it is far too small and doesn't
make much sense. Does anybody remember why we even have this limit?

IMHO per process shm mappings should just be controlled by the normal
process and global mappings with the same heuristics as tmpfs
(by default max memory / 2 or more if shmfs is mounted with more)
Actually I suspect databases will usually want to use more 
so it might even make sense to support max memory - 1/8*max_memory

I would propose to get rid of of shmmax completely
and only keep the old shmall sysctl for compatibility.

Comments?

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
