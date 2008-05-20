Date: Tue, 20 May 2008 06:05:29 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
Message-ID: <20080520110528.GD30341@sgi.com>
References: <20080514041122.GE24516@wotan.suse.de> <20080514112625.GY9878@sgi.com> <20080515075747.GA7177@wotan.suse.de> <Pine.LNX.4.64.0805151031250.18708@schroedinger.engr.sgi.com> <20080515235203.GB25305@wotan.suse.de> <20080516112306.GA4287@sgi.com> <20080516115005.GC4287@sgi.com> <20080520053145.GA19502@wotan.suse.de> <20080520100111.GC30341@sgi.com> <20080520105025.GA25791@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080520105025.GA25791@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Robin Holt <holt@sgi.com>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <andrea@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 20, 2008 at 12:50:25PM +0200, Nick Piggin wrote:
> On Tue, May 20, 2008 at 05:01:11AM -0500, Robin Holt wrote:
> > On Tue, May 20, 2008 at 07:31:46AM +0200, Nick Piggin wrote:
> > > 
> > > Really? You can get the information through via a sleeping messaging API,
> > > but not a non-sleeping one? What is the difference from the hardware POV?
> > 
> > That was covered in the early very long discussion about 28 seconds.
> > The read timeout for the BTE is 28 seconds and it automatically retried
> > for certain failures.  In interrupt context, that is 56 seconds without
> > any subsequent interrupts of that or lower priority.
> 
> I thought you said it would be possible to get the required invalidate
> information without using the BTE. Couldn't you use XPMEM pages in
> the kernel to read the data out of, if nothing else?

I was wrong about that.  I thought it was safe to do an uncached write,
but it turns out any processor write is uncontained and the MCA that
surfaces would be fatal.  Likewise for the uncached read.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
