Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 5391A6B0183
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 19:41:39 -0500 (EST)
Received: by vcbfk26 with SMTP id fk26so278242vcb.14
        for <linux-mm@kvack.org>; Tue, 13 Dec 2011 16:41:38 -0800 (PST)
Date: Tue, 13 Dec 2011 16:41:34 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -mm] slub: document setting min order with debug_guardpage_minorder
 > 0
In-Reply-To: <201112130021.41429.rjw@sisk.pl>
Message-ID: <alpine.DEB.2.00.1112131640240.32369@chino.kir.corp.google.com>
References: <1321633507-13614-1-git-send-email-sgruszka@redhat.com> <alpine.DEB.2.00.1112081303100.8127@chino.kir.corp.google.com> <20111212145948.GA2380@redhat.com> <201112130021.41429.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Stanislaw Gruszka <sgruszka@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>

On Tue, 13 Dec 2011, Rafael J. Wysocki wrote:

> > diff --git a/Documentation/ABI/testing/sysfs-kernel-slab b/Documentation/ABI/testing/sysfs-kernel-slab
> > index 8b093f8..d84ca80 100644
> > --- a/Documentation/ABI/testing/sysfs-kernel-slab
> > +++ b/Documentation/ABI/testing/sysfs-kernel-slab
> > @@ -345,7 +345,9 @@ Description:
> >  		allocated.  It is writable and can be changed to increase the
> >  		number of objects per slab.  If a slab cannot be allocated
> >  		because of fragmentation, SLUB will retry with the minimum order
> > -		possible depending on its characteristics.
> > +		possible depending on its characteristics. 
> 
> Added trailing whitespace (please remove).
> 
> > +		When debug_guardpage_minorder > 0 parameter is specified, the
> > +		minimum possible order is used and cannot be changed.
> 
> Well, I'm not sure what you wanted to say, actually?  How does one change
> debug_guardpage_minorder (or specify it), for example?  Is it a kernel
> command-line switch?
> 

Yeah, we'll need a reference to Documentation/kernel-parameters.txt.

> Also I'm not sure what "cannot be changed" is supposed to mean.  Does it
> mean that /sys/cache/slab/cache/order has no effect in that case?
> 

Good point, we should say that "this tunable" cannot be used to change the 
order at runtime if debug_guardpage_minorder is used on the command line.

Stanislaw, one more revision?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
