Date: Sat, 16 Feb 2008 11:34:03 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB: Increasing partial pages
In-Reply-To: <20080216190727.GH7657@parisc-linux.org>
Message-ID: <Pine.LNX.4.64.0802161133000.25573@schroedinger.engr.sgi.com>
References: <20080116195949.GO18741@parisc-linux.org>
 <Pine.LNX.4.64.0801161219050.9694@schroedinger.engr.sgi.com>
 <20080116214127.GA11559@parisc-linux.org> <Pine.LNX.4.64.0801161347160.11353@schroedinger.engr.sgi.com>
 <20080116221618.GB11559@parisc-linux.org> <Pine.LNX.4.64.0801161421240.12024@schroedinger.engr.sgi.com>
 <20080118191430.GD20490@parisc-linux.org> <Pine.LNX.4.64.0801221142330.27692@schroedinger.engr.sgi.com>
 <20080216190727.GH7657@parisc-linux.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 16 Feb 2008, Matthew Wilcox wrote:

> On Tue, Jan 22, 2008 at 12:00:00PM -0800, Christoph Lameter wrote:
> > Patches that I would recommend to test individually if you could do it 
> > (get the series via git pull 
> > git://git.kernel.org/pub/scm/linux/kernel/git/christoph/vm.git performance):
> 
> With these patches applied to 2.6.24-rc8, the perf team are seeing
> oopses while running the benchmark.  They're currently trying to narrow
> down which of the patches it is.  I'll get an oops for you to study when
> they've figured that out.

There is also new code upstream now with significant changes that 
affect performance. It may not be worthwhile to continue with 2.6.24-rc8 
+ patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
