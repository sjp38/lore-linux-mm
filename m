Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5F96B003D
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 15:36:21 -0400 (EDT)
Date: Wed, 1 Apr 2009 21:36:39 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Detailed Stack Information Patch [2/3]
Message-ID: <20090401193639.GB12316@elte.hu>
References: <1238511507.364.62.camel@matrix>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1238511507.364.62.camel@matrix>
Sender: owner-linux-mm@kvack.org
To: Stefani Seibold <stefani@seibold.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Joerg Engel <joern@logfs.org>
List-ID: <linux-mm.kvack.org>


* Stefani Seibold <stefani@seibold.net> wrote:

> +config PROC_STACK_MONITOR
> + 	default y
> +	depends on PROC_STACK
> +	bool "Enable /proc/stackmon detailed stack monitoring"
> + 	help
> +	  This enables detailed monitoring of process and thread stack
> +	  utilization via the /proc/stackmon interface.
> +	  Disabling these interfaces will reduce the size of the kernel by
> +	  approximately 2kb.

Hm, i'm not convinced about this one. Stupid question: what's wrong 
with ulimit -s?

Also, if for some reason you dont want to (or cannot) enforce a 
system-wide stack size ulimit, or it has some limitation that makes 
it impractical for you - if we add what i suggested to the 
/proc/*/maps files, your user-space watchdog daemon could scan those 
periodically and report any excesses and zap the culprit ... right?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
