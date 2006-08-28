Date: Mon, 28 Aug 2006 10:04:14 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 2/7] ia64 generic PAGE_SIZE
In-Reply-To: <20060828154414.38AEDAA2@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0608281003070.27677@schroedinger.engr.sgi.com>
References: <20060828154413.E05721BD@localhost.localdomain>
 <20060828154414.38AEDAA2@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Aug 2006, Dave Hansen wrote:

> -config IA64_PAGE_SIZE_64KB
> -	depends on !ITANIUM
> -	bool "64KB"
> -
> -endchoice

Uhh.. arch specific stuff in mm/Kconfig. Each arch needs to modify the 
mm/Kconfig?

Also cc linux-ia64@vger.kernel.org on these.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
