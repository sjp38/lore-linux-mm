From: Rob Landley <rob@landley.net>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Date: Fri, 4 Nov 2005 20:48:57 -0600
References: <20051104210418.BC56F184739@thermo.lanl.gov> <Pine.LNX.4.64.0511041310130.28804@g5.osdl.org>
In-Reply-To: <Pine.LNX.4.64.0511041310130.28804@g5.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511042048.59310.rob@landley.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andy Nelson <andy@thermo.lanl.gov>, mingo@elte.hu, akpm@osdl.org, arjan@infradead.org, arjanv@infradead.org, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@mbligh.org, mel@csn.ul.ie, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Friday 04 November 2005 15:22, Linus Torvalds wrote:
> Now, if you want _most_ of memory to be available for hugepages, you
> really will always require a special boot option, and a friendly machine
> maintainer. Limiting things like inodes, process descriptors etc to a
> smallish percentage of memory would not be acceptable in general.

But it might make it a lot easier for User Mode Linux to give unused memory 
back to the host system via madvise(DONT_NEED).

(Assuming there's some way to beat the page cache into submission and actually 
free up space.  If there was an option to tell the page cache to stay the 
heck out of the hugepage zone, it would be just about perfect...)

Rob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
