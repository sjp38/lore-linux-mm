Message-ID: <4046C3F8.4070402@matchmail.com>
Date: Wed, 03 Mar 2004 21:51:52 -0800
From: Mike Fedyk <mfedyk@matchmail.com>
MIME-Version: 1.0
Subject: Re: Non-GPL export of invalidate_mmap_range
References: <20040217073522.A25921@infradead.org> <20040217124001.GA1267@us.ibm.com> <20040217161929.7e6b2a61.akpm@osdl.org> <1077108694.4479.4.camel@laptop.fenrus.com> <20040218140021.GB1269@us.ibm.com> <20040218211035.A13866@infradead.org> <20040218150607.GE1269@us.ibm.com> <20040218222138.A14585@infradead.org> <20040218145132.460214b5.akpm@osdl.org> <20040219091132.GE17140@khan.acc.umu.se> <20040219085819.GB1269@us.ibm.com>
In-Reply-To: <20040219085819.GB1269@us.ibm.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: paulmck@us.ibm.com
Cc: Andrew Morton <akpm@osdl.org>, Christoph Hellwig <hch@infradead.org>, arjanv@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Paul E. McKenney wrote:
> On Thu, Feb 19, 2004 at 10:11:32AM +0100, David Weinehall wrote:
> 
>>On Wed, Feb 18, 2004 at 02:51:32PM -0800, Andrew Morton wrote:
>>
>>>Christoph Hellwig <hch@infradead.org> wrote:
>>>
>>>>I don't understand why IBM is pushing this dubious change right now,
>>>
>>>It isn't a dubious change, on technical grounds.  It is reasonable for a
>>>distributed filesystem to want to be able to shoot down pte's which map
>>>sections of pagecache.  Just as it is reasonable for the filesystem to be
>>>able to shoot down the pagecache itself.
>>>
>>>We've exported much lower-level stuff than this, because some in-kernel
>>>module happened to use it.
>>
>>Probably not always the right choice, though...  I highly suspect we
>>far to much of our intestines are easily available.
> 
> 
> Again, the whole point of the patch is to -reduce- the degree of
> intestinal export.
> 
> 						Thanx, Paul

Paul, this still doesn't answer why GPFS can't be released under the GPL.

If this has been answered, I'd love to see a pointer to which archives 
in which I should search.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
