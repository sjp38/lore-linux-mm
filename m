Date: Wed, 17 Oct 2007 00:41:47 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: During VM oom condition, kill all threads in process group
Message-ID: <20071016224147.GB29378@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Will Schmidt <will_schmidt@vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I'm interested about this patch dcca2bde4f86a14d3291660bede8f1844fe2b3df

I don't actually have a problem with what was merged, but I still think
that we should be calling the oom killer from this point. The oom killer
knows about what tasks to oom and what not to, whether to panic on oom,
etc.

I have a patch for this, but wasn't really pushing it hard because it's
pretty unlikely for x86 and standard filesystems to oom from here...

What architecture, filesystems, and workload did you observe problems with?
Did you discover which allocation was failing?

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
