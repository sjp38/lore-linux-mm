Date: Wed, 16 Jan 2008 14:28:44 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB: Increasing partial pages
In-Reply-To: <20080116221618.GB11559@parisc-linux.org>
Message-ID: <Pine.LNX.4.64.0801161421240.12024@schroedinger.engr.sgi.com>
References: <20080116195949.GO18741@parisc-linux.org>
 <Pine.LNX.4.64.0801161219050.9694@schroedinger.engr.sgi.com>
 <20080116214127.GA11559@parisc-linux.org> <Pine.LNX.4.64.0801161347160.11353@schroedinger.engr.sgi.com>
 <20080116221618.GB11559@parisc-linux.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 16 Jan 2008, Matthew Wilcox wrote:

> About 0.1-0.2%  0.3% is considered significant.

The results are that stable? A kernel compilation which slightly 
rearranges cachelines due to code and data changes typically leads to a 
larger variance on my 8 way box (gets even larger under NUMA). I would 
expect that the variations on a database load would be more significant.

I repeatedly saw patches from Intel to do minor changes to SLAB that 
increase performance by 0.5% or so (like the recent removal of a BUG_ON 
for performance reasons). These do not regress again when you build a 
newer kernel release?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
