Date: Sat, 30 Jun 2007 11:40:38 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 1/3] add the fsblock layer
Message-ID: <20070630104038.GB24123@infradead.org>
References: <20070624014528.GA17609@wotan.suse.de> <20070624014613.GB17609@wotan.suse.de> <18046.63436.472085.535177@notabene.brown> <467F71C6.6040204@yahoo.com.au> <20070625122906.GB12446@think.oraclecorp.com> <46807B32.6050302@yahoo.com.au> <18048.32372.40011.10896@notabene.brown> <468082FF.6090704@yahoo.com.au> <20070626122650.GL14224@think.oraclecorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070626122650.GL14224@think.oraclecorp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Neil Brown <neilb@suse.de>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 26, 2007 at 08:26:50AM -0400, Chris Mason wrote:
> Since we're testing new code, I would just leave the blkdev address
> space alone.  If a filesystem wants to use fsblocks, they allocate a new
> inode during mount, stuff it into their private super block (or in the
> generic super), and use that for everything.  Basically ignoring the
> block device address space completely.

Exactly, same thing XFS does.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
