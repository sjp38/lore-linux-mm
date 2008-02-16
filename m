Date: Sat, 16 Feb 2008 12:07:28 -0700
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: SLUB: Increasing partial pages
Message-ID: <20080216190727.GH7657@parisc-linux.org>
References: <20080116195949.GO18741@parisc-linux.org> <Pine.LNX.4.64.0801161219050.9694@schroedinger.engr.sgi.com> <20080116214127.GA11559@parisc-linux.org> <Pine.LNX.4.64.0801161347160.11353@schroedinger.engr.sgi.com> <20080116221618.GB11559@parisc-linux.org> <Pine.LNX.4.64.0801161421240.12024@schroedinger.engr.sgi.com> <20080118191430.GD20490@parisc-linux.org> <Pine.LNX.4.64.0801221142330.27692@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801221142330.27692@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 22, 2008 at 12:00:00PM -0800, Christoph Lameter wrote:
> Patches that I would recommend to test individually if you could do it 
> (get the series via git pull 
> git://git.kernel.org/pub/scm/linux/kernel/git/christoph/vm.git performance):

With these patches applied to 2.6.24-rc8, the perf team are seeing
oopses while running the benchmark.  They're currently trying to narrow
down which of the patches it is.  I'll get an oops for you to study when
they've figured that out.

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
