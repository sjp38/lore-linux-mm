Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 579196B00A1
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 17:54:58 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so985570pad.14
        for <linux-mm@kvack.org>; Wed, 12 Dec 2012 14:54:57 -0800 (PST)
Date: Wed, 12 Dec 2012 14:54:55 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH, RESEND] asm-generic, mm: pgtable: consolidate zero page
 helpers
In-Reply-To: <20121212105538.GA14208@otc-wbsnb-06>
Message-ID: <alpine.DEB.2.00.1212121452430.23465@chino.kir.corp.google.com>
References: <1354881215-26257-1-git-send-email-kirill.shutemov@linux.intel.com> <alpine.DEB.2.00.1212111906270.18872@chino.kir.corp.google.com> <20121212105538.GA14208@otc-wbsnb-06>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mips@linux-mips.org, Ralf Baechle <ralf@linux-mips.org>, John Crispin <blogic@openwrt.org>

On Wed, 12 Dec 2012, Kirill A. Shutemov wrote:

> > What's the benefit from doing this other than generalizing some per-arch 
> > code?  It simply adds on more layer of redirection to try to find the 
> > implementation that matters for the architecture you're hacking on.
> 
> The idea of asm-generic is consolidation arch code which can be re-used
> for different arches. It also makes support of new arches easier.
> 

Yeah, but you're moving is_zero_pfn() unnecessarily into a header file 
when it is only used mm/memory.c and it adds a __HAVE_* definition that we 
always try to reduce (both __HAVE and __ARCH definitions are frowned 
upon).  I don't think it's much of a win to obfuscate the code because 
mips and s390 implement colored zero pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
