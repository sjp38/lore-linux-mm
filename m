Date: Mon, 14 Mar 2005 21:50:13 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mm counter operations through macros
In-Reply-To: <20050314214506.050efadf.akpm@osdl.org>
Message-ID: <Pine.LNX.4.58.0503142148510.16812@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0503110422150.19280@schroedinger.engr.sgi.com>
 <20050311182500.GA4185@redhat.com> <Pine.LNX.4.58.0503111103200.22240@schroedinger.engr.sgi.com>
 <16946.62799.737502.923025@gargle.gargle.HOWL>
 <Pine.LNX.4.58.0503142103090.16582@schroedinger.engr.sgi.com>
 <20050314214506.050efadf.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: nikita@clusterfs.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 14 Mar 2005, Andrew Morton wrote:

> I don't think the MM_COUNTER_T macro adds much, really.  How about this?

Then you wont be able to get rid of the counters by

#define MM_COUNTER(xx)

anymore.

>
> --- 25/include/linux/sched.h~mm-counter-operations-through-macros-tidy	2005-03-14 21:43:00.000000000 -0800
> +++ 25-akpm/include/linux/sched.h	2005-03-14 21:43:00.000000000 -0800
> @@ -210,7 +210,6 @@ extern void arch_unmap_area_topdown(stru
>  #define inc_mm_counter(mm, member) (mm)->_##member++
>  #define dec_mm_counter(mm, member) (mm)->_##member--
>  typedef unsigned long mm_counter_t;
> -#define MM_COUNTER_T(member) mm_counter_t _##member
>
>  struct mm_struct {
>  	struct vm_area_struct * mmap;		/* list of VMAs */
> @@ -241,8 +240,8 @@ struct mm_struct {
>  	unsigned long exec_vm, stack_vm, reserved_vm, def_flags, nr_ptes;
>
>  	/* Special counters protected by the page_table_lock */
> -	MM_COUNTER_T(rss);
> -	MM_COUNTER_T(anon_rss);
> +	mm_counter_t _rss;
> +	mm_counter_t _anon_rss;
>
>  	unsigned long saved_auxv[42]; /* for /proc/PID/auxv */
>
> _
>
>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
