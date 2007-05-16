Date: Tue, 15 May 2007 23:32:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Slab allocators: Define common size limitations
Message-Id: <20070515233239.335bd4ed.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0705152313490.5832@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705152313490.5832@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 May 2007 23:15:24 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> Currently we have a maze of configuration variables that determine
> the maximum slab size. Worst of all it seems to vary between SLAB and SLUB.
> 
> So define a common maximum size for kmalloc. For conveniences sake
> we use the maximum size ever supported which is 32 MB. We limit the maximum
> size to a lower limit if MAX_ORDER does not allow such large allocations.
> 
> For many architectures this patch will have the effect of adding large
> kmalloc sizes. x86_64 adds 5 new kmalloc sizes. So a small amount
> of memory will be needed for these caches (contemporary SLAB has dynamically
> sizeable node and cpu structure so the waste is less than in the past)
> 
> Most architectures will then be able to allocate object with sizes up to
> MAX_ORDER. We have had repeated breakage (in fact whenever we doubled the
> number of supported processors) on IA64 because one or the other struct
> grew beyond what the slab allocators supported. This will avoid future
> issues and f.e. avoid fixes for 2k and 4k cpu support.
> 
> CONFIG_LARGE_ALLOCS is no longer necessary so drop it.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  arch/blackfin/Kconfig         |    8 --------
>  arch/frv/Kconfig              |    8 --------
>  arch/m68knommu/Kconfig        |    8 --------
>  arch/v850/Kconfig             |    8 --------
>  include/linux/kmalloc_sizes.h |   20 +++++++++++++++-----
>  include/linux/slab.h          |   15 +++++++++++++++
>  include/linux/slub_def.h      |   19 ++-----------------
>  mm/slab.c                     |   19 ++-----------------
>  8 files changed, 34 insertions(+), 71 deletions(-)

rofl. Really we shouldn't put this into 2.6.22, but it turfs out so much
crap that it's hard to justify holding it back.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
