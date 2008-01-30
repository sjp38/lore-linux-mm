Message-ID: <47A0C441.4020502@sgi.com>
Date: Wed, 30 Jan 2008 10:38:57 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/6] powerpc: Use generic per cpu linux-2.6.git
References: <20080130180940.022172000@sgi.com> <20080130180940.788340000@sgi.com> <20080130182809.GA27168@elte.hu>
In-Reply-To: <20080130182809.GA27168@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> * travis@sgi.com <travis@sgi.com> wrote:
> 
>> Powerpc has a way to determine the address of the per cpu area of the 
>> currently executing processor via the paca and the array of per cpu 
>> offsets is avoided by looking up the per cpu area from the remote 
>> paca's (copying x86_64).
> 
> i needed the fix below to get my powerpc crosscompile build to succeed.
> 
> 	Ingo

Thanks!  I double-checked the logs and my ppc build worked.  But yes, this was
in the original patch.  And wierdly, powerpc was the only arch that had it
dropped.

-Mike
> 
> -------------->
> Subject: powerpc: percpu build fix
> From: Ingo Molnar <mingo@elte.hu>
> 
> Signed-off-by: Ingo Molnar <mingo@elte.hu>
> ---
>  include/asm-powerpc/percpu.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-x86.q/include/asm-powerpc/percpu.h
> ===================================================================
> --- linux-x86.q.orig/include/asm-powerpc/percpu.h
> +++ linux-x86.q/include/asm-powerpc/percpu.h
> @@ -13,7 +13,7 @@
>  #include <asm/paca.h>
>  
>  #define __per_cpu_offset(cpu) (paca[cpu].data_offset)
> -#define __my_cpu_offset() get_paca()->data_offset
> +#define __my_cpu_offset get_paca()->data_offset
>  #define per_cpu_offset(x) (__per_cpu_offset(x))
>  
>  #endif /* CONFIG_SMP */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
