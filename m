Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D18A86B0055
	for <linux-mm@kvack.org>; Thu, 28 May 2009 08:48:03 -0400 (EDT)
Date: Thu, 28 May 2009 14:48:40 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090528124840.GB1421@ucw.cz>
References: <20090520183045.GB10547@oblivion.subreption.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090520183045.GB10547@oblivion.subreption.com>
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi!

> Index: linux-2.6/mm/Kconfig
> ===================================================================
> --- linux-2.6.orig/mm/Kconfig
> +++ linux-2.6/mm/Kconfig
> @@ -155,6 +155,26 @@ config PAGEFLAGS_EXTENDED
>  	def_bool y
>  	depends on 64BIT || SPARSEMEM_VMEMMAP || !NUMA || !SPARSEMEM
>  
> +config PAGE_SENSITIVE
> +	bool "Support for selective page sanitization"
> +	help
> +	 This option provides support for honoring the sensitive bit
> +	 in the low level page allocator. This bit is used to mark
> +	 pages that will contain sensitive information (such as
> +	 cryptographic secrets and credentials).
> +
> +	 Pages marked with the sensitive bit will be sanitized upon
> +	 release, to prevent information leaks and data remanence that
> +	 could allow Iceman/coldboot attacks to reveal such data.
> +
> +	 If you are unsure, select N. This option might introduce a
> +	 minimal performance impact on those subsystems that make
> +	 use of the flag associated with the sensitive bit.
> +
> +	 If you use the cryptographic API or want to prevent tty
> +	 information leaks locally, you most likely want to enable
> +	 this.

This should not be configurable. Runtime config, defaulting to
'sanitize' may make some sense, but... better just be secure.

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
