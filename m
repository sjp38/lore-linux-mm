From: Thomas Schlichter <schlicht@uni-mannheim.de>
Subject: Re: 2.5.74-mm3
Date: Wed, 9 Jul 2003 11:25:38 +0200
References: <20030708223548.791247f5.akpm@osdl.org> <200307091106.00781.schlicht@uni-mannheim.de> <20030709021849.31eb3aec.akpm@osdl.org>
In-Reply-To: <20030709021849.31eb3aec.akpm@osdl.org>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200307091125.40879.schlicht@uni-mannheim.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 09 July 2003 11:18, Andrew Morton wrote:
> Thomas Schlichter <schlicht@uni-mannheim.de> wrote:
> > This gives following compile error when compiling the kernel with APM
> > support for UP:
> >
> >  arch/i386/kernel/apm.c: In function `apm_bios_call':
> >  arch/i386/kernel/apm.c:600: error: incompatible types in assignment
> >  arch/i386/kernel/apm.c: In function `apm_bios_call_simple':
> >  arch/i386/kernel/apm.c:643: error: incompatible types in assignment
> >
> >  The attached patch fixes this...
>
> Seems complex.  I just have this:
>
>
> diff -puN arch/i386/kernel/apm.c~cpumask-apm-fix-2 arch/i386/kernel/apm.c
> --- 25/arch/i386/kernel/apm.c~cpumask-apm-fix-2	2003-07-08
> 23:09:23.000000000 -0700 +++ 25-akpm/arch/i386/kernel/apm.c	2003-07-08
> 23:28:50.000000000 -0700 @@ -528,7 +528,7 @@ static inline void
> apm_restore_cpus(cpum
>   *	No CPU lockdown needed on a uniprocessor
>   */
>
> -#define apm_save_cpus()	0
> +#define apm_save_cpus()		CPU_MASK_NONE
>  #define apm_restore_cpus(x)	(void)(x)
>
>  #endif

I thought about this one, too, but I wasn't sure if gcc is able to optimize 
away the assignment and the local cpumask_t variable with this oneliner...

But for me it is OK, too...
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
