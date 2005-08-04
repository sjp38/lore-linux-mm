Date: Thu, 4 Aug 2005 14:19:21 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Getting rid of SHMMAX/SHMALL ?
In-Reply-To: <20050804113941.GP8266@wotan.suse.de>
Message-ID: <Pine.LNX.4.61.0508041409540.3500@goblin.wat.veritas.com>
References: <20050804113941.GP8266@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-kernel@vger.kernel.org, Anton Blanchard <anton@samba.org>, cr@sap.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 4 Aug 2005, Andi Kleen wrote:

> I noticed that even 64bit architectures have a ridiculously low 
> max limit on shared memory segments by default:
> 
> #define SHMMAX 0x2000000                 /* max shared seg size (bytes) */
> #define SHMMNI 4096                      /* max num of segs system wide */
> #define SHMALL (SHMMAX/PAGE_SIZE*(SHMMNI/16)) /* max shm system wide (pages) */
> 
> Even on 32bit architectures it is far too small and doesn't
> make much sense. Does anybody remember why we even have this limit?

To be like the UNIXes.

> IMHO per process shm mappings should just be controlled by the normal
> process and global mappings with the same heuristics as tmpfs
> (by default max memory / 2 or more if shmfs is mounted with more)
> Actually I suspect databases will usually want to use more 
> so it might even make sense to support max memory - 1/8*max_memory
> 
> I would propose to get rid of of shmmax completely
> and only keep the old shmall sysctl for compatibility.

Anton proposed raising the limits last autumn, but I was a bit
discouraging back then, having noticed that even Solaris 9 was more
restrictive than Linux.  They seem to be ancient traditional limits
which everyone knows must be raised to get real work done.

It's possible that if we raise the limits, installation
of this or that application will then lower them again?

I don't think my opinion is worth much on this:
what would the distro tuners like to see there?

Hugh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
