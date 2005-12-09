Date: Fri, 9 Dec 2005 23:02:26 +0100
From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [RFC] Introduce atomic_long_t
Message-ID: <20051209220226.GG23349@stusta.de>
References: <Pine.LNX.4.62.0512091053260.2656@schroedinger.engr.sgi.com> <20051209201127.GE23349@stusta.de> <Pine.LNX.4.62.0512091352590.3182@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0512091352590.3182@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@ver.kernel.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, Dec 09, 2005 at 01:57:05PM -0800, Christoph Lameter wrote:
> On Fri, 9 Dec 2005, Adrian Bunk wrote:
> 
> > What about creating an include/linux/atomic.h [1] that contains both 
> > this new code and other common code like the atomic_t typedef (unless 
> > there's a good reason why counter isn't volatile on h8300 and v850...).
> 
> Ok that would look something like the attached patch [only exist to
> give an idea on how this would work]. It would require
> 
> 1. A replacement of all #include <asm/atomic.h>s with #include 
>   <linux/atomic.h> throughout all files of the kernel
> 
> 2. Rework of all include/asm-xx/atomic.h to extract common code.
> 
> I will do just that if everyone agrees to this approach.
>...

I'd say the sequence is:
1. create an linux/atomic.h the #include's asm/atomic.h
2. convert all asm/atomic.h to use linux/atomic.h
3. move common code to linux/atomic.h

There should be a small amount of time between 2. and 3. because 
doing all three steps at the same time in both Linus' tree and -mm
sounds like a hard task.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
