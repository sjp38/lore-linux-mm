Subject: Re: Active Memory Defragmentation: Our implementation & problems
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <38540000.1075876171@[10.10.2.4]>
References: <20040204050915.59866.qmail@web9704.mail.yahoo.com>
	 <1075874074.14153.159.camel@nighthawk>  <35380000.1075874735@[10.10.2.4]>
	 <1075875756.14153.251.camel@nighthawk>  <38540000.1075876171@[10.10.2.4]>
Content-Type: text/plain
Message-Id: <1075876826.14166.314.camel@nighthawk>
Mime-Version: 1.0
Date: 03 Feb 2004 22:40:26 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Alok Mooley <rangdi@yahoo.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2004-02-03 at 22:29, Martin J. Bligh wrote:
> There are a couple of special cases that might be feasible without making
> an ungodly mess. PTE pages spring to mind (particularly as they can be
> in highmem too). They should be reasonably easy to move (assuming we can
> use rmap to track them back to the process they belong to to lock them ...
> hmmm ....)

We don't do any pte page reclaim at any time other than process exit and
there are plenty of pte pages we can just plain free anyway.  Anthing
that's completely mapping page cache, for instance.

In the replacement case, taking mm->page_table_lock, doing the copy, and
replacing the pointer from the pmd should be all that it takes.  But, I
wonder if we could miss any sets of the pte dirty bit this way...

--dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
