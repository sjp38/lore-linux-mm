Date: Thu, 8 Jun 2000 22:29:50 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: journaling & VM
Message-ID: <20000608222950.Z3886@redhat.com>
References: <Pine.LNX.4.21.0006061956360.7328-100000@duckman.distro.conectiva> <393DA31A.358AE46D@reiser.to> <20000607121243.F29432@redhat.com> <m2r9a9a1q6.fsf_-_@boreas.southchinaseas> <20000607181144.U30951@redhat.com> <20000608114435.A15433@uni-koblenz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000608114435.A15433@uni-koblenz.de>; from ralf@uni-koblenz.de on Thu, Jun 08, 2000 at 11:44:35AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ralf Baechle <ralf@uni-koblenz.de>, linux-mm@kvack.org
Cc: "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Jun 08, 2000 at 11:44:35AM +0200, Ralf Baechle wrote:
> On Wed, Jun 07, 2000 at 06:11:44PM +0100, Stephen C. Tweedie wrote:
> 
> > Because you want to have some idea of the usage patterns of the 
> > pages, too, so that you can free pages which haven't been accessed 
> > recently regardless of who owns them.
> 
> some device drivers may also collect relativly large amounts of memory.
> In case of my HIPPI cards this may be in the range of megabytes.  So I'd
> like to see a hook for freeing device memory.

Rik, here's yet another item for the wishlist on your new VM. :)

Device drivers really are a special case because they typically need
their memory at short notice, and at awkward times (such as in the 
middle of interrupts).  What sort of flexibility do you have regarding
the allocation/release of the buffer pull in your driver?

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
