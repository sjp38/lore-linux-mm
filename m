Date: Wed, 16 Jan 2008 15:16:18 -0700
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: SLUB: Increasing partial pages
Message-ID: <20080116221618.GB11559@parisc-linux.org>
References: <20080116195949.GO18741@parisc-linux.org> <Pine.LNX.4.64.0801161219050.9694@schroedinger.engr.sgi.com> <20080116214127.GA11559@parisc-linux.org> <Pine.LNX.4.64.0801161347160.11353@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801161347160.11353@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 16, 2008 at 02:01:08PM -0800, Christoph Lameter wrote:
> On Wed, 16 Jan 2008, Matthew Wilcox wrote:
> > I sent you a mail on December 6th ... here are the contents of that
> > mail:
> 
> Dec 6th? I was on vacation then and it seems that I was unable to 
> reproduce the oopses. Can I get some backtraces or other information 
> that would allow me to diagnose the problem?

I'll ask to see what they have.

> > Applying just patches 1-7 and 9 leads to a slight (0.34%) performance
> > reduction compared to slub.  That is 6.45% versus slab, reduces to 6.79%
> > with the 8 patches applied.
> 
> Patch 8 is the one that optimizes the fastpath. How much runtime 
> variability have these tests?

About 0.1-0.2%  0.3% is considered significant.

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
