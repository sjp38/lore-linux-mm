Message-ID: <42544D7E.1040907@linux-m68k.org>
Date: Wed, 06 Apr 2005 22:58:38 +0200
From: Roman Zippel <zippel@linux-m68k.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] create mm/Kconfig for arch-independent memory options
References: <E1DIViE-0006Kf-00@kernel.beaverton.ibm.com>
In-Reply-To: <E1DIViE-0006Kf-00@kernel.beaverton.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

Hi,

Dave Hansen wrote:

> diff -puN mm/Kconfig~A6-mm-Kconfig mm/Kconfig
> --- memhotplug/mm/Kconfig~A6-mm-Kconfig	2005-04-04 09:04:48.000000000 -0700
> +++ memhotplug-dave/mm/Kconfig	2005-04-04 10:15:23.000000000 -0700
> @@ -0,0 +1,25 @@
> +choice
> +	prompt "Memory model"
> +	default FLATMEM
> +	default SPARSEMEM if ARCH_SPARSEMEM_DEFAULT
> +	default DISCONTIGMEM if ARCH_DISCONTIGMEM_DEFAULT

Does this really have to be a user visible option and can't it be
derived from other values? The help text entries are really no help at all.

bye, Roman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
