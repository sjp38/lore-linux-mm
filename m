Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j36L25cY014831
	for <linux-mm@kvack.org>; Wed, 6 Apr 2005 17:02:05 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j36L24ZW215244
	for <linux-mm@kvack.org>; Wed, 6 Apr 2005 17:02:04 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j36L24M6032605
	for <linux-mm@kvack.org>; Wed, 6 Apr 2005 17:02:04 -0400
Subject: Re: [PATCH 1/4] create mm/Kconfig for arch-independent memory
	options
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <42544D7E.1040907@linux-m68k.org>
References: <E1DIViE-0006Kf-00@kernel.beaverton.ibm.com>
	 <42544D7E.1040907@linux-m68k.org>
Content-Type: text/plain
Date: Wed, 06 Apr 2005 14:01:59 -0700
Message-Id: <1112821319.14584.28.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Zippel <zippel@linux-m68k.org>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-04-06 at 22:58 +0200, Roman Zippel wrote:
> Dave Hansen wrote:
> > --- memhotplug/mm/Kconfig~A6-mm-Kconfig	2005-04-04 09:04:48.000000000 -0700
> > +++ memhotplug-dave/mm/Kconfig	2005-04-04 10:15:23.000000000 -0700
> > @@ -0,0 +1,25 @@
> > +choice
> > +	prompt "Memory model"
> > +	default FLATMEM
> > +	default SPARSEMEM if ARCH_SPARSEMEM_DEFAULT
> > +	default DISCONTIGMEM if ARCH_DISCONTIGMEM_DEFAULT
> 
> Does this really have to be a user visible option and can't it be
> derived from other values? The help text entries are really no help at all.

I hope that this selection will replace the current DISCONTIGMEM prompts
in the individual architectures.  That way, you won't get a net increase
in the number of prompts.  However, I do realize that architectures
without DISCONTIG see a new, relatively useless menu/prompt.

Is there a way to hide an entire "choice" menu?  If there is, we can
certainly hide it when there's only one possible choice.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
