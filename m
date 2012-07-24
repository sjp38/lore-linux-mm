Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 35F0E6B004D
	for <linux-mm@kvack.org>; Tue, 24 Jul 2012 04:10:51 -0400 (EDT)
Date: Tue, 24 Jul 2012 09:10:46 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/34] Memory management performance backports for
 -stable V2
Message-ID: <20120724081046.GK9222@suse.de>
References: <1343050727-3045-1-git-send-email-mgorman@suse.de>
 <1343109531.7412.47.camel@marge.simpson.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1343109531.7412.47.camel@marge.simpson.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Galbraith <efault@gmx.de>
Cc: Stable <stable@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 24, 2012 at 07:58:51AM +0200, Mike Galbraith wrote:
> On Mon, 2012-07-23 at 14:38 +0100, Mel Gorman wrote: 
> > Changelog since V1
> >   o Expand some of the notes					(jrnieder)
> >   o Correct upstream commit SHA1				(hugh)
> > 
> > This series is related to the new addition to stable_kernel_rules.txt
> > 
> >  - Serious issues as reported by a user of a distribution kernel may also
> >    be considered if they fix a notable performance or interactivity issue.
> >    As these fixes are not as obvious and have a higher risk of a subtle
> >    regression they should only be submitted by a distribution kernel
> >    maintainer and include an addendum linking to a bugzilla entry if it
> >    exists and additional information on the user-visible impact.
> > 
> > All of these patches have been backported to a distribution kernel and
> > address some sort of performance issue in the VM. As they are not all
> > obvious, I've added a "Stable note" to the top of each patch giving
> > additional information on why the patch was backported. Lets see where
> > the boundaries lie on how this new rule is interpreted in practice :).
> 
> FWIW, I'm all for performance backports.  They do have a downside though
> (other than the risk of bugs slipping in, or triggering latent bugs).
> 
> When the next enterprise kernel is built, marketeers ask for numbers to
> make potential customers drool over, and you _can't produce any_ because
> you wedged all the spiffy performance stuff into the crusty old kernel.
> 

I'm not a marketing person but I expect the performance figures they
really care about are between versions of the product which includes more
than the kernel. The are not going to be comparisons between the upstream
kernel and the distribution kernel so they'll still are able to produce
the drool-inducing figures. By backporting certain performance figures,
data from regression testing major kernel releases is more valuable to
the distribution vendor when considering a change of kernel version.

There is also the lag factor to consider. Distribution kernels will carry
fixes for the functional and performance regression fixes from the time
of discovery and supply temporary kernels to their users to minimise the
lifetime of a bug. It could be weeks if not months before the same fixes
bubble their way up to -stable. They might never bubble up if the developer
is pressed for time or the patch unsuitable for -stable for some reason.

None of that takes into account the fact that distribution kernels are
backed by quality support and developer teams that can diagnose and fix
a range of problems encountered in the field. This is true whether it is
an distribution that directly sells support as part of the software or
is a distribution with a lot of developers that are also contractors.
The same guarantees do not necessarily apply to upstream kernels where
support is conditional on getting the attention of the right people.

These backports are not going to destroy the value proposition of
distribution kernels :)

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
