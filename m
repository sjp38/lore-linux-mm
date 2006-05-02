Date: Tue, 2 May 2006 13:24:09 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 00/14] remap_file_pages protection support
Message-ID: <20060502112409.GA28159@elte.hu>
References: <20060430172953.409399000@zion.home.lan> <4456D5ED.2040202@yahoo.com.au> <4456D85E.6020403@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4456D85E.6020403@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: blaisorblade@yahoo.it, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> >Let's try get back to the good old days when people actually reported
> >their bugs (togther will *real* numbers) to the mailing lists. That way,
> >everybody gets to think about and discuss the problem.
> 
> Speaking of which, let's see some numbers for UML -- performance and 
> memory. I don't doubt your claims, but I (and others) would be 
> interested to see.

firstly, thanks for the review feedback!

originally i tested this feature with some minimal amount of RAM 
simulated by UML 128MB or so. That's just 32 thousand pages, but still 
the improvement was massive: context-switch times in UML were cut in 
half or more. Process-creation times improved 10-fold. With this feature 
included I accidentally (for the first time ever!) confused an UML shell 
prompt with a real shell prompt. (before that UML was so slow [even in 
"skas mode"] that you'd immediately notice it by the shell's behavior)

the 'have 1 vma instead of 32,000 vmas' thing is a really, really big 
plus. It makes UML comparable to Xen, in rough terms of basic VM design.

Now imagine a somewhat larger setup - 16 GB RAM UML instance with 4 
million vmas per UML process ... Frankly, without 
sys_remap_file_pages_prot() the UML design is still somewhat of a toy.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
