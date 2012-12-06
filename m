Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id A46726B0081
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 09:48:24 -0500 (EST)
Date: Thu, 6 Dec 2012 15:48:21 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: Oops in 3.7-rc8 isolate_free_pages_block()
Message-ID: <20121206144821.GC18547@quack.suse.cz>
References: <20121206091744.GA1397@polaris.bitmath.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121206091744.GA1397@polaris.bitmath.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Henrik Rydberg <rydberg@euromail.se>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, mgorman@suse.de, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu 06-12-12 10:17:44, Henrik Rydberg wrote:
> Hi Linus,
> 
> This is the third time I encounter this oops in 3.7, but the first
> time I managed to get a decent screenshot:
> 
> http://bitmath.org/test/oops-3.7-rc8.jpg
> 
> It seems to have to do with page migration. I run with transparent
> hugepages configured, just for the fun of it.
> 
> I am happy to test any suggestions.
  Adding linux-mm and Mel as an author of compaction in particular to CC...
It seems that while traversing struct page structures, we entered into a new
huge page (note that RBX is 0xffffea0001c00000 - just the beginning of
a huge page) and oopsed on PageBuddy test (_mapcount is at offset 0x18 in
struct page). It might be useful if you provide disassembly of
isolate_freepages_block() function in your kernel so that we can guess more
from other register contents...

								Honza

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
