Date: Fri, 4 May 2007 12:24:07 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: incoming
Message-ID: <20070504192407.GA32235@kroah.com>
References: <20070504091434.106ad04d.akpm@linux-foundation.org> <20070504185721.3CB7C1800A0@magilla.sf.frob.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070504185721.3CB7C1800A0@magilla.sf.frob.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roland McGrath <roland@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Christoph Lameter <clameter@engr.sgi.com>, "David S. Miller" <davem@davemloft.net>, Andi Kleen <ak@suse.de>, "Luck, Tony" <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Stephen Smalley <sds@tycho.nsa.gov>
List-ID: <linux-mm.kvack.org>

On Fri, May 04, 2007 at 11:57:21AM -0700, Roland McGrath wrote:
> > Ah.  The patch affects security code, but it doesn't actually address any
> > insecurity.  I didn't think it was needed for -stable?
> 
> I would not recommend it for -stable.  
> It is an ABI change for the case of a security refusal.

ABI changes are not a problem for -stable, so don't let that stop anyone
:)

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
