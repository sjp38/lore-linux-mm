Date: Fri, 18 Jan 2008 12:14:30 -0700
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: SLUB: Increasing partial pages
Message-ID: <20080118191430.GD20490@parisc-linux.org>
References: <20080116195949.GO18741@parisc-linux.org> <Pine.LNX.4.64.0801161219050.9694@schroedinger.engr.sgi.com> <20080116214127.GA11559@parisc-linux.org> <Pine.LNX.4.64.0801161347160.11353@schroedinger.engr.sgi.com> <20080116221618.GB11559@parisc-linux.org> <Pine.LNX.4.64.0801161421240.12024@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801161421240.12024@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 16, 2008 at 02:28:44PM -0800, Christoph Lameter wrote:
> On Wed, 16 Jan 2008, Matthew Wilcox wrote:
> > About 0.1-0.2%  0.3% is considered significant.
> 
> The results are that stable? A kernel compilation which slightly 
> rearranges cachelines due to code and data changes typically leads to a 
> larger variance on my 8 way box (gets even larger under NUMA). I would 
> expect that the variations on a database load would be more significant.

The load runs for a long time.  You can reduce variance by increasing
your sample size (ok, it's twelve years since I've done a stats course ...)

> I repeatedly saw patches from Intel to do minor changes to SLAB that 
> increase performance by 0.5% or so (like the recent removal of a BUG_ON 
> for performance reasons). These do not regress again when you build a 
> newer kernel release?

No, they don't.  Unless someone's broken something (eg putting pages on
the LRU in the wrong order so we don't get merges any more ;-)

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
