Date: Wed, 28 Jun 2000 23:05:17 +0200
From: "Andi Kleen" <ak@suse.de>
Subject: Re: kmap_kiobuf()
Message-ID: <20000628230517.A14031@gruyere.muc.suse.de>
References: <200006281652.LAA19162@jen.americas.sgi.com> <20000628190612.E2392@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000628190612.E2392@redhat.com>; from sct@redhat.com on Wed, Jun 28, 2000 at 07:06:12PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: lord@sgi.com, "Benjamin C.R. LaHaise" <blah@kvack.org>, David Woodhouse <dwmw2@infradead.org>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 28, 2000 at 07:06:12PM +0100, Stephen C. Tweedie wrote:
> Hi,
> 
> On Wed, Jun 28, 2000 at 11:52:40AM -0500, lord@sgi.com wrote:
> > 
> > I am not a VM guy either, Ben, is the cost of the TLB flush mostly in
> > the synchronization between CPUs, or is it just expensive anyway you
> > look at it?
> 
> The TLB IPI is by far the biggest factor here.

In theory it would be possible to do it lazily associated with the object's
lock (so that the TLB is only transfered when some other CPU aquires the lock of the
object in question). It would be probably rather error prone though.


	


-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
