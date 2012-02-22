Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id B964D6B00FE
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 12:03:18 -0500 (EST)
Date: Wed, 22 Feb 2012 18:03:16 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] thp: 'transparent_hugepage=' can also be specified on
 cmdline
Message-ID: <20120222170315.GJ10222@redhat.com>
References: <alpine.LNX.2.00.1202221710050.31150@pobox.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1202221710050.31150@pobox.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jkosina@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>

On Wed, Feb 22, 2012 at 05:13:04PM +0100, Jiri Kosina wrote:
> Behavior of THP can either be toggled through sysfs in runtime or using a 
> kernel cmdline parameter 'transparent_hugepage='. Document the latter.
> 
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>
> ---
>  Documentation/kernel-parameters.txt |    7 +++++++
>  Documentation/vm/transhuge.txt      |    3 +++
>  2 files changed, 10 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> index 033d4e6..a4de9b9 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -2629,6 +2629,13 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>  			to facilitate early boot debugging.
>  			See also Documentation/trace/events.txt
>  
> +	transparent_hugepage=
> +			[KNL]
> +			Format: [always|madvise|never]
> +			Can be used to control the default behavior of the system
> +			with respect to transparent hugepages.
> +			See Documentation/vm/transhuge.txt for more details.
> +
>  	tsc=		Disable clocksource stability checks for TSC.
>  			Format: <string>
>  			[x86] reliable: mark tsc clocksource as reliable, this

Ok.

> diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
> index 29bdf62..4a3816d 100644
> --- a/Documentation/vm/transhuge.txt
> +++ b/Documentation/vm/transhuge.txt
> @@ -103,6 +103,9 @@ echo always >/sys/kernel/mm/transparent_hugepage/enabled
>  echo madvise >/sys/kernel/mm/transparent_hugepage/enabled
>  echo never >/sys/kernel/mm/transparent_hugepage/enabled
>  
> +The always/madvise/never value can also be specified on the kernel boot
> +commandline using 'transparent_hugepage=' parameter.
> +
>  It's also possible to limit defrag efforts in the VM to generate

This is a dup.

== Boot parameter ==

You can change the sysfs boot time defaults of Transparent Hugepage
Support by passing the parameter "transparent_hugepage=always" or
"transparent_hugepage=madvise" or "transparent_hugepage=never"
(without "") to the kernel command line.


>  hugepages in case they're not immediately free to madvise regions or
>  to never try to defrag memory and simply fallback to regular pages
> -- 
> 1.7.3.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
