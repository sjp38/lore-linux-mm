Date: Wed, 16 Jan 2008 14:41:28 -0700
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: SLUB: Increasing partial pages
Message-ID: <20080116214127.GA11559@parisc-linux.org>
References: <20080116195949.GO18741@parisc-linux.org> <Pine.LNX.4.64.0801161219050.9694@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801161219050.9694@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 16, 2008 at 12:39:31PM -0800, Christoph Lameter wrote:
> Ahhh.. Good to hear that the issue on x86_64 gets better. I am still 
> waiting for a test with the patchset that I did specifically to address 
> your regression: http://lkml.org/lkml/2007/10/27/245 (where I tried to 
> come up with an in kernel benchmark that exposes the issue even more)? It 
> is much more likely now that this patchset in mm addresses your regression 
> since the hackbench performance improvement fix already reduce it 
> partially.

I sent you a mail on December 6th ... here are the contents of that
mail:

---

On Thu, Nov 29, 2007 at 07:54:44PM -0800, Christoph Lameter wrote:
> Hmmmm... I have been running them for awhile and they have been in mm 
> for awhile. Never seen a boot issue.

After investigation, there are two issues.

Patch 8/10 oopses during the run, typically after about an hour.

Patch 10/10 oopses during boot.  I haven't been able to reproduce this
on my quad-core machine, but it happens every time for them on their
dual quad-core machine.

---

Applying just patches 1-7 and 9 leads to a slight (0.34%) performance
reduction compared to slub.  That is 6.45% versus slab, reduces to 6.79%
with the 8 patches applied.

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
