Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id D8AD56B002B
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 22:07:16 -0500 (EST)
Received: by mail-da0-f46.google.com with SMTP id p5so69892dak.19
        for <linux-mm@kvack.org>; Tue, 11 Dec 2012 19:07:16 -0800 (PST)
Date: Tue, 11 Dec 2012 19:07:14 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH, RESEND] asm-generic, mm: pgtable: consolidate zero page
 helpers
In-Reply-To: <1354881215-26257-1-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.00.1212111906270.18872@chino.kir.corp.google.com>
References: <1354881215-26257-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mips@linux-mips.org, Ralf Baechle <ralf@linux-mips.org>, John Crispin <blogic@openwrt.org>

On Fri, 7 Dec 2012, Kirill A. Shutemov wrote:

> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> We have two different implementation of is_zero_pfn() and
> my_zero_pfn() helpers: for architectures with and without zero page
> coloring.
> 
> Let's consolidate them in <asm-generic/pgtable.h>.
> 

What's the benefit from doing this other than generalizing some per-arch 
code?  It simply adds on more layer of redirection to try to find the 
implementation that matters for the architecture you're hacking on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
