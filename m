Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id D973D6B004D
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 08:22:00 -0500 (EST)
Date: Fri, 16 Dec 2011 14:21:56 +0100
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH -mm] slub: document setting min order with
 debug_guardpage_minorder > 0
Message-ID: <20111216132155.GA14271@redhat.com>
References: <1321633507-13614-1-git-send-email-sgruszka@redhat.com>
 <alpine.DEB.2.00.1112081303100.8127@chino.kir.corp.google.com>
 <20111212145948.GA2380@redhat.com>
 <201112130021.41429.rjw@sisk.pl>
 <alpine.DEB.2.00.1112131640240.32369@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1112131640240.32369@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>

On Tue, Dec 13, 2011 at 04:41:34PM -0800, David Rientjes wrote:
> > > +		When debug_guardpage_minorder > 0 parameter is specified, the
> > > +		minimum possible order is used and cannot be changed.
> > 
> > Well, I'm not sure what you wanted to say, actually?  How does one change
> > debug_guardpage_minorder (or specify it), for example?  Is it a kernel
> > command-line switch?
> > 
> 
> Yeah, we'll need a reference to Documentation/kernel-parameters.txt.
> 
> > Also I'm not sure what "cannot be changed" is supposed to mean.  Does it
> > mean that /sys/cache/slab/cache/order has no effect in that case?
> > 
> 
> Good point, we should say that "this tunable" cannot be used to change the 
> order at runtime if debug_guardpage_minorder is used on the command line.
> 
> Stanislaw, one more revision?

Ehh, I silently hoped that someone else with better English skills could
fix it ;-)

As Andrew already applied my patch (and fix whitespace) I'll post the
incremental patch in the next e-mail.

Thanks
Stanislaw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
