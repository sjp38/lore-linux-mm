Date: Fri, 4 May 2007 10:02:46 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: incoming
Message-ID: <20070504170246.GA23069@kroah.com>
References: <20070502150252.7ddf67ac.akpm@linux-foundation.org> <20070504133728.GA19460@kroah.com> <20070504091434.106ad04d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070504091434.106ad04d.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Christoph Lameter <clameter@engr.sgi.com>, "David S. Miller" <davem@davemloft.net>, Andi Kleen <ak@suse.de>, "Luck, Tony" <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Roland McGrath <roland@redhat.com>, Stephen Smalley <sds@tycho.nsa.gov>
List-ID: <linux-mm.kvack.org>

On Fri, May 04, 2007 at 09:14:34AM -0700, Andrew Morton wrote:
> On Fri, 4 May 2007 06:37:28 -0700 Greg KH <greg@kroah.com> wrote:
> 
> > On Wed, May 02, 2007 at 03:02:52PM -0700, Andrew Morton wrote:
> > > - One little security patch
> > 
> > Care to cc: linux-stable with it so we can do a new 2.6.21 release with
> > it if needed?
> > 
> 
> Ah.  The patch affects security code, but it doesn't actually address any
> insecurity.  I didn't think it was needed for -stable?

Ah, ok, I read "security" as fixing a insecure problem, my mistake :)

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
