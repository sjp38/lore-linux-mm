Date: Fri, 18 Jan 2008 06:11:18 +0100
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH 2/6] percpu: Change Kconfig ARCH_SETS_UP_PER_CPU_AREA to HAVE_SETUP_PER_CPU_AREA
Message-ID: <20080118051118.GA14882@uranus.ravnborg.org>
References: <20080117223505.203884000@sgi.com> <20080117223505.513183000@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080117223505.513183000@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

Hi Mike.

> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -20,6 +20,7 @@ config X86
>  	def_bool y
>  	select HAVE_OPROFILE
>  	select HAVE_KPROBES
> +	select HAVE_SETUP_PER_CPU_AREA if ARCH = "x86_64"

It is simpler to just say:
> +	select HAVE_SETUP_PER_CPU_AREA if X86_64

And this is the way we do it in the rest of the
x86 Kconfig files.

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
