Date: Sat, 3 Feb 2007 02:22:59 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 0/9] buffered write deadlock fix
Message-ID: <20070203012259.GA27300@wotan.suse.de>
References: <20070129081905.23584.97878.sendpatchset@linux.site> <20070202155232.babe1a52.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070202155232.babe1a52.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Fengguang Wu <fengguang.wu@gmail.com>, Suparna Bhattacharya <suparna@in.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Feb 02, 2007 at 03:52:32PM -0800, Andrew Morton wrote:
> On Mon, 29 Jan 2007 11:31:37 +0100 (CET)
> Nick Piggin <npiggin@suse.de> wrote:
> 
> > The following set of patches attempt to fix the buffered write
> > locking problems (and there are a couple of peripheral patches
> > and cleanups there too).
> > 
> > Patches against 2.6.20-rc6. I was hoping that 2.6.20-rc6-mm2 would
> > be an easier diff with the fsaio patches gone, but the readahead
> > rewrite clashes badly :(
> 
> Well fsaio is restored, but there's now considerable doubt over it due to
> the recent febril febrility.
> 
> How bad is the clash with the readahead patches?

I don't think it would be so bad that one couldn't merge readahead
back on top quite easily... The fsaio ones are a little harder because
they change generic_file_buffered_write.

> Clashes with git-block are likely, too.
> 
> Bugfixes come first, so I will drop readahead and fsaio and git-block to get
> this work completed if needed - please work agaisnt mainline.

OK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
