Date: Wed, 28 May 2003 04:35:44 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.70-mm1 bootcrash, possibly IDE or RAID
Message-ID: <20030528113544.GV8978@holomorphy.com>
References: <20030408042239.053e1d23.akpm@digeo.com> <3ED49A14.2020704@aitel.hist.no> <20030528111345.GU8978@holomorphy.com> <3ED49EB8.1080506@aitel.hist.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3ED49EB8.1080506@aitel.hist.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Helge Hafting <helgehaf@aitel.hist.no>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 28, 2003 at 01:34:16PM +0200, Helge Hafting wrote:
> Here's the decoded crash, written down by hand:
> <stuff scrolled off screen>
> bio_endio
> _end_that_request_first
> ide_end_request
> ide_dma_intr
> ide_intr
> ide_dma_intr
> handle_IRQ_event
> do_IRQ
> default_idle
> default_idle
> common_interrupt

This is unusual; I'm having trouble very close to this area. There is
a remote chance it could be the same problem.

Could you log this to serial and get the rest of the oops/BUG? If it's
where I think it is, I've been looking at end_page_writeback() and so
might have an idea or two.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
