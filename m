Date: Fri, 9 Dec 2005 23:33:28 +0100
From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [RFC] Introduce atomic_long_t
Message-ID: <20051209223327.GH23349@stusta.de>
References: <Pine.LNX.4.62.0512091053260.2656@schroedinger.engr.sgi.com> <20051209201127.GE23349@stusta.de> <Pine.LNX.4.62.0512091352590.3182@schroedinger.engr.sgi.com> <20051209220226.GG23349@stusta.de> <20051209222045.GL11190@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051209222045.GL11190@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@engr.sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@ver.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Dec 09, 2005 at 11:20:45PM +0100, Andi Kleen wrote:
> > I'd say the sequence is:
> > 1. create an linux/atomic.h the #include's asm/atomic.h
> > 2. convert all asm/atomic.h to use linux/atomic.h
> > 3. move common code to linux/atomic.h
> 
> I don't think there is much common code actually. atomic_t 
> details vary widly between architectures. Just defining
> a few macros to others is really not significant. I think 
> Christoph's original patch was just fine.

All of Christoph's original patch contains common code.

The amount of duplication his patch would create alone would IMHO be 
worth creating an linux/atomic.h.

> -Andi

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
