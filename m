Date: Wed, 27 Jun 2007 16:05:31 +1000
From: David Chinner <dgc@sgi.com>
Subject: Re: [RFC] fsblock
Message-ID: <20070627060531.GV31489@sgi.com>
References: <20070624014528.GA17609@wotan.suse.de> <20070626030640.GM989688@sgi.com> <46808E1F.1000509@yahoo.com.au> <20070626092309.GF31489@sgi.com> <20070626123449.GM14224@think.oraclecorp.com> <20070627053245.GA6033@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070627053245.GA6033@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Chris Mason <chris.mason@oracle.com>, David Chinner <dgc@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 27, 2007 at 07:32:45AM +0200, Nick Piggin wrote:
> I think using fsblock to drive the IO and keep the pagecache flags
> uptodate and using a btree in the filesystem to manage extents of block
> allocations wouldn't be a bad idea though. Do any filesystems actually
> do this?

Yes. XFS. But we still need to hold state in buffer heads (BH_delay,
BH_unwritten) that is needed to determine what type of
allocation/extent conversion is necessary during writeback. i.e.
what we originally mapped the page as during the ->prepare_write
call.

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
