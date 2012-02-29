Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 2FAF46B0092
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 22:42:00 -0500 (EST)
Date: Wed, 29 Feb 2012 00:39:09 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH] oom: add sysctl to enable slab memory dump
Message-ID: <20120229033908.GA28416@t510.redhat.com>
References: <20120222115320.GA3107@x61.redhat.com>
 <alpine.DEB.2.00.1202221640420.14213@chino.kir.corp.google.com>
 <20120223152226.GA2014@x61.redhat.com>
 <alpine.DEB.2.00.1202231509510.26362@chino.kir.corp.google.com>
 <alpine.LFD.2.02.1202240856370.1917@tux.localdomain>
 <alpine.DEB.2.00.1202240200380.24971@chino.kir.corp.google.com>
 <CAOJsxLExoyzvpRNOEdT3+x1mhSCZt0dO7NLKkpi7CrJ7HW2kpw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAOJsxLExoyzvpRNOEdT3+x1mhSCZt0dO7NLKkpi7CrJ7HW2kpw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Randy Dunlap <rdunlap@xenotime.net>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Josef Bacik <josef@redhat.com>, linux-kernel@vger.kernel.org

On Fri, Feb 24, 2012 at 12:05:27PM +0200, Pekka Enberg wrote:
> On Fri, Feb 24, 2012 at 12:03 PM, David Rientjes <rientjes@google.com> wrote:
> > I like how slub handles this when it can't allocate more slab with
> > slab_out_of_memory() and has the added benefit of still warning even with
> > __GFP_NORETRY that the oom killer is never called for.  If there's really
> > a slab leak happening, there's a good chance that this diagnostic
> > information is going to be emitted by the offending cache at some point in
> > time if you're using slub.  This could easily be extended to slab.c, so
> > it's even more reason not to include this type of information in the oom
> > killer.
> 
> Works for me. Rafael?

New patch, following the suggested approach, posted: 
https://lkml.org/lkml/2012/2/28/561

Thanks folks, for all your feedback here!
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
