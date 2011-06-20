Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id EB91B6B0012
	for <linux-mm@kvack.org>; Sun, 19 Jun 2011 22:07:51 -0400 (EDT)
Date: Sun, 19 Jun 2011 19:07:46 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH] fix cleancache config
Message-Id: <20110619190746.457544f1.rdunlap@xenotime.net>
In-Reply-To: <20110619215026.GA17202@infradead.org>
References: <7182365.DrQ0shW2IG@donald.sf-tec.de>
	<20110619215026.GA17202@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Rolf Eike Beer <eike-kernel@sf-tec.de>, linux-mm@kvack.org, akpm@linux-foundation.org

On Sun, 19 Jun 2011 17:50:26 -0400 Christoph Hellwig wrote:

> On Sun, Jun 19, 2011 at 05:29:55PM +0200, Rolf Eike Beer wrote:
> > >From 2b3ebe8ffd22793dc53f4b7301048d60e8db017e Mon Sep 17 00:00:00 2001
> > From: Rolf Eike Beer <eike-kernel@sf-tec.de>
> > Date: Thu, 9 Jun 2011 14:13:58 +0200
> > Subject: [PATCH] fix cleancache config
> > 
> > It doesn't make sense to have a default setting different to that what we
> > suggest the user to select. Also fixes a typo.
> 
> NAK
> 
> default y is not for random crap, but for essential bits that should
> only be explicitly disabled if you really know what you do.


I.e., please change the last line of CLEANCACHE help text in mm/Kconfig.

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
