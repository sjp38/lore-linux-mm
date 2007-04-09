Date: Mon, 9 Apr 2007 15:01:20 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [QUICKLIST 3/4] Quicklist support for x86_64
In-Reply-To: <20070409142852.40da5add.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0704091500060.2761@schroedinger.engr.sgi.com>
References: <20070409182509.8559.33823.sendpatchset@schroedinger.engr.sgi.com>
 <20070409182520.8559.33529.sendpatchset@schroedinger.engr.sgi.com>
 <20070409142852.40da5add.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, ak@suse.de, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Apr 2007, Andrew Morton wrote:

> On Mon,  9 Apr 2007 11:25:20 -0700 (PDT)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > -static inline pgd_t *pgd_alloc(struct mm_struct *mm)
> > +static inline void pgd_ctor(void *x)
> > +static inline void pgd_dtor(void *x)
> 
> Seems dumb to inline these - they're only ever called indirectly, aren't
> they?

Yes.. In most cases they are not called at all because NULL is passed. 
Then the function call can be removed by the compiler from the in line 
functions.

> This means (I think) that the compiler will need to generate an out-of-line
> copy of these within each compilation unit which passes the address of these
> functions into some other function.

The function is constant. Constant propagation will lead to the function 
being included in the inline function.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
