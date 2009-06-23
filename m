Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 99CE46B0055
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 16:23:00 -0400 (EDT)
Date: Tue, 23 Jun 2009 22:23:35 +0200
From: Jesper Nilsson <Jesper.Nilsson@axis.com>
Subject: Re: [PATCH] cris: add pgprot_noncached
Message-ID: <20090623202335.GJ12383@axis.com>
References: <20090614132845.17543.11882.sendpatchset@rx1.opensource.se> <200906231455.31499.arnd@arndb.de> <20090623192041.GH12383@axis.com> <200906232207.46136.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200906232207.46136.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Mundt <lethal@linux-sh.org>, "magnus.damm@gmail.com" <magnus.damm@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jayakumar.lkml@gmail.com" <jayakumar.lkml@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 23, 2009 at 10:07:42PM +0200, Arnd Bergmann wrote:
> On Tuesday 23 June 2009, Jesper Nilsson wrote:
> > No, this looks good to me.
> > Do you want me to grab it for the CRIS tree or do you want
> > to keep it as a series?
> 
> I'd prefer you to take it. The order of the four patches is
> entirely arbitrary anyway and there are no other dependencies
> on it once the asm-generic version is merged.

Right, I'll add it the CRIS tree. Thanks!

> 	Arnd <><

/^JN - Jesper Nilsson
-- 
               Jesper Nilsson -- jesper.nilsson@axis.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
