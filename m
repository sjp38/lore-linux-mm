Date: Wed, 21 Nov 2001 12:35:22 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: recursive lock-enter-deadlock
Message-ID: <20011121123522.G2500@redhat.com>
References: <20011121105631.B2500@redhat.com> <XFMail.20011121125211.R.Oehler@GDImbH.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <XFMail.20011121125211.R.Oehler@GDImbH.com>; from R.Oehler@GDImbH.com on Wed, Nov 21, 2001 at 12:52:11PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: R.Oehler@GDImbH.com
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Nov 21, 2001 at 12:52:11PM +0100, R.Oehler@GDImbH.com wrote:
 
> On 21-Nov-2001 Stephen C. Tweedie wrote:
> > Hi,
> > 
> > On Wed, Nov 21, 2001 at 11:19:13AM +0100, R.Oehler@GDImbH.com wrote:
> >> A short question (I don't have a recent 2.4.x at hand, currently):
> >> Is this recursive lock-enter-deadlock (2.4.0) fixed in newer kernels?
> > 
> > Yes.  Seriously, 2.4.0 is so old and so full of bugs like this that
> > it's really not worth spending any effort looking for problems like
> > that in it.

> Well, maybe, but it's the one distributed in SuSE-71.

Isn't that the one that only shipped 2.4 as a preview kernel?

For production use, it's common for distributions to apply their own
patches on top of the basic kernel --- mostly bugfixes back-ported
from later official kernel releases.  I'd be enormously surprised if
SuSE shipped a completely unpatched 2.4.0 as a production kernel, so
it's quite possible that the SuSE kernel has that fix applied.

> By the way: 2.4.10-ac works, as Alan says, so what changed in the linus'
> kernel and didn't change in the -ac kernel between 2.4.0 and 2.4.10 ?

2.4.10 had an absolute ton of block device layer changes which Alan
didn't apply to 2.4.10-ac.  Your bug isn't the only nasty in 2.4.10:
e2fsprogs gets bitten too, and things like tune2fs on mounted
filesystems are broken in that kernel.

Cheers,  
  Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
