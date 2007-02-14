Date: Wed, 14 Feb 2007 11:00:02 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch] mm: NUMA replicated pagecache
In-Reply-To: <20070213060924.GB20644@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0702141057060.975@schroedinger.engr.sgi.com>
References: <20070213060924.GB20644@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Feb 2007, Nick Piggin wrote:

> This is a scheme for page replication replicates read-only pagecache pages
> opportunistically, at pagecache lookup time (at points where we know the
> page is being looked up for read only).

The problem is that you may only have a single page table. One process 
with multiple threads will just fault in one thread in order to 
install the mapping to the page. The others threads may be running on 
different nodes and different processors but will not generate any 
faults. Pages will not be replicated as needed. The scheme only seems to 
be working for special cases of multiple processes mapping the same file.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
