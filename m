Date: Fri, 21 Mar 2008 15:24:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/9] Store max number of objects in the page struct.
Message-Id: <20080321152407.b0fbe81f.akpm@linux-foundation.org>
In-Reply-To: <1205983937.14496.24.camel@ymzhang>
References: <20080317230516.078358225@sgi.com>
	<20080317230528.279983034@sgi.com>
	<1205917757.10318.1.camel@ymzhang>
	<Pine.LNX.4.64.0803191049450.29173@schroedinger.engr.sgi.com>
	<1205983937.14496.24.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Cc: clameter@sgi.com, linux-kernel@vger.kernel.org, penberg@cs.helsinki.fi, mel@csn.ul.ie, mpm@selenic.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Mar 2008 11:32:17 +0800
"Zhang, Yanmin" <yanmin_zhang@linux.intel.com> wrote:

> Add definitions of USHRT_MAX and others into kernel. ipc uses it and
> slub implementation might also use it.
> 
> The patch is against 2.6.25-rc6.
> 
> Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>
> 
> ---
> 
> --- linux-2.6.25-rc6/include/linux/kernel.h	2008-03-20 04:25:46.000000000 +0800
> +++ linux-2.6.25-rc6_work/include/linux/kernel.h	2008-03-20 04:17:45.000000000 +0800
> @@ -20,6 +20,9 @@
>  extern const char linux_banner[];
>  extern const char linux_proc_banner[];
>  
> +#define USHRT_MAX	((u16)(~0U))
> +#define SHRT_MAX	((s16)(USHRT_MAX>>1))
> +#define SHRT_MIN	(-SHRT_MAX - 1)

We have UINT_MAX and ULONG_MAX and ULLONG_MAX.  If these were actually
UNT_MAX, ULNG_MAX and ULLNG_MAX then USHRT_MAX would make sense.

But they aren't, so it doesn't ;)

Please, let's call them USHORT_MAX, SHORT_MAX and SHORT_MIN.

> --- linux-2.6.25-rc6/ipc/util.h	2008-03-20 04:25:46.000000000 +0800
> +++ linux-2.6.25-rc6_work/ipc/util.h	2008-03-20 04:22:07.000000000 +0800
> @@ -12,7 +12,6 @@
>  
>  #include <linux/err.h>
>  
> -#define USHRT_MAX 0xffff
>  #define SEQ_MULTIPLIER	(IPCMNI)
>  
>  void sem_init (void);

And then convert IPC to use them?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
