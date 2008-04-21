Date: Mon, 21 Apr 2008 17:14:05 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/4] Add a basic debugging framework for memory
	initialisation
Message-ID: <20080421151405.GI5474@elte.hu>
References: <20080417000624.18399.35041.sendpatchset@skynet.skynet.ie> <20080417000644.18399.66175.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080417000644.18399.66175.sendpatchset@skynet.skynet.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Mel Gorman <mel@csn.ul.ie> wrote:

> +config DEBUG_MEMORY_INIT
> +	bool "Debug memory initialisation"
> +	depends on DEBUG_KERNEL
> +	help
> +	  Enable this to turn on debug checks during memory initialisation. By
> +	  default, sanity checks will be made on the memory model and
> +	  information provided by the architecture. What level of checking
> +	  made and verbosity during boot can be set with the
> +	  mminit_debug_level= command-line option.
> +
> +	  If unsure, say N

should be "default y" - and perhaps only disable-able on 
CONFIG_EMBEDDED. We generally want such bugs to pop up as soon as 
possible, and the sanity checks should only go away if someone 
specifically aims for lowest system footprint.

the default loglevel for debug printouts might deserve another debug 
option - but the core checks should always be included, and _errors_ 
should always be printed out.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
