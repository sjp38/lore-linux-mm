Message-ID: <3F37DFDC.6080308@mvista.com>
Date: Mon, 11 Aug 2003 11:26:36 -0700
From: George Anzinger <george@mvista.com>
MIME-Version: 1.0
Subject: Re: 2.6.0-test3-mm1
References: <20030809203943.3b925a0e.akpm@osdl.org> <200308101941.33530.schlicht@uni-mannheim.de>
In-Reply-To: <200308101941.33530.schlicht@uni-mannheim.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thomas Schlichter <schlicht@uni-mannheim.de>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Thomas Schlichter wrote:
> Hi,
> 
> 
>>kgdb-ga.patch
>>  kgdb stub for ia32 (George Anzinger's one)
>>  kgdbL warning fix
> 
> 
> that patch sets DEBUG_INFO to y by default, even if whether DEBUG_KERNEL nor 
> KGDB is enabled. The attached patch changes this to enable DEBUG_INFO by 
> default only if KGDB is enabled.

Looks good to me, but.... just what does this turn on?  Its been a 
long time and me thinks a wee comment here would help me remember next 
time.

-g

> 
> Please apply...
> 
> Best regards
>    Thomas Schlichter
> 
> 
> ------------------------------------------------------------------------
> 
> --- linux-2.6.0-test3-mm1/arch/i386/Kconfig.orig	Sun Aug 10 14:25:13 2003
> +++ linux-2.6.0-test3-mm1/arch/i386/Kconfig	Sun Aug 10 14:25:56 2003
> @@ -1462,6 +1462,7 @@
>  
>  config DEBUG_INFO
>  	bool
> +	depends on KGDB
>  	default y
>  
>  config KGDB_MORE

-- 
George Anzinger   george@mvista.com
High-res-timers:  http://sourceforge.net/projects/high-res-timers/
Preemption patch: http://www.kernel.org/pub/linux/kernel/people/rml

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
