Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C82F5900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 15:21:04 -0400 (EDT)
Date: Wed, 13 Apr 2011 12:19:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/thp: Use conventional format for boolean attributes
Message-Id: <20110413121925.55493041.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1104131202230.5563@chino.kir.corp.google.com>
References: <1300772711.26693.473.camel@localhost>
	<alpine.DEB.2.00.1104131202230.5563@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Ben Hutchings <ben@decadent.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Wed, 13 Apr 2011 12:04:59 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 22 Mar 2011, Ben Hutchings wrote:
> 
> > The conventional format for boolean attributes in sysfs is numeric
> > ("0" or "1" followed by new-line).  Any boolean attribute can then be
> > read and written using a generic function.  Using the strings
> > "yes [no]", "[yes] no" (read), "yes" and "no" (write) will frustrate
> > this.
> > 
> > Cc'd to stable in order to change this before many scripts depend on
> > the current strings.
> > 
> 
> I agree with this in general, it's certainly the standard way of altering 
> a boolean tunable throughout the kernel so it would be nice to use the 
> same userspace libraries with THP.

yup.

It's a bit naughty to change the existing interface in 2.6.38.x but the time
window is small and few people will be affected and they were nuts to be
using 2.6.38.0 anyway ;)

I suppose we could support both the old and new formats for a while,
then retire the old format but I doubt if it's worth it.

Isn't there some user documentation which needs to be updated to
reflect this change?  If not, why not?  :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
