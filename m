Message-ID: <465E8D4C.9040506@s5r6.in-berlin.de>
Date: Thu, 31 May 2007 10:54:36 +0200
From: Stefan Richter <stefanr@s5r6.in-berlin.de>
MIME-Version: 1.0
Subject: Re: [RFC 1/4] CONFIG_STABLE: Define it
References: <20070531002047.702473071@sgi.com> <20070531003012.302019683@sgi.com>
In-Reply-To: <20070531003012.302019683@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> --- slub.orig/init/Kconfig	2007-05-30 16:35:05.000000000 -0700
> +++ slub/init/Kconfig	2007-05-30 16:35:45.000000000 -0700
> @@ -65,6 +65,13 @@ endmenu
>  
>  menu "General setup"
>  
> +config STABLE
> +	bool "Stable kernel"
> +	help
> +	  If the kernel is configured to be a stable kernel then various
> +	  checks that are only of interest to kernel development will be
> +	  omitted.
> +
>  config LOCALVERSION
>  	string "Local version - append to kernel release"
>  	help

a) Why in Kconfig, why not in Makefile?

b) Of course nobody wants STABLE=n. :-)  How about:

config RELEASE
	bool "Build for release"
	help
	  If the kernel is declared as a release build here, then
	  various checks that are only of interest to kernel development
	  will be omitted.

c) A drawback of this general option is, it's hard to tell what will be
omitted in particular.
-- 
Stefan Richter
-=====-=-=== -=-= =====
http://arcgraph.de/sr/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
