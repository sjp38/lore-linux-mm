Date: Fri, 20 Jul 2001 20:38:20 +0200
From: Christoph Hellwig <hch@ns.caldera.de>
Subject: Re: Support for Intel 4MB Pages
Message-ID: <20010720203820.A16411@caldera.de>
References: <Pine.A41.3.96.1010720142345.25692A-100000@vcmr-19.rcs.rpi.edu> <3B587934.6000103@interactivesi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3B587934.6000103@interactivesi.com>; from ttabi@interactivesi.com on Fri, Jul 20, 2001 at 01:32:20PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 20, 2001 at 01:32:20PM -0500, Timur Tabi wrote:
> I thought Linux already used 4MB pages for its 1-to-1 kernel virtual
> memory mapping.

Yes.   But this is only _wierd_ kernel memory, not general-purpose
memory.

	Christoph

-- 
Whip me.  Beat me.  Make me maintain AIX.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
