Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 690986001DA
	for <linux-mm@kvack.org>; Sun, 31 Jan 2010 18:53:48 -0500 (EST)
From: Frans Pop <elendil@planet.nl>
Subject: Re: [PATCH 09/10] mm/slab.c: Fix continuation line formats
Date: Mon, 1 Feb 2010 00:53:44 +0100
References: <cover.1264967493.git.joe@perches.com> <201001312132.19798.elendil@planet.nl> <1264970322.25140.175.camel@Joe-Laptop.home>
In-Reply-To: <1264970322.25140.175.camel@Joe-Laptop.home>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <201002010053.45818.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, cl@linux-foundation.org, penberg@cs.helsinki.fi, mpm@selenic.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sunday 31 January 2010, Joe Perches wrote:
> On Sun, 2010-01-31 at 21:32 +0100, Frans Pop wrote:
> > If that spacing part is really needed (is it?), wouldn't it be more
> >
> > readable as:
> > > +		seq_printf(m, " : globalstat %7lu %6lu %5lu %4lu"
> > > +				" 				"
> > > +				"%4lu %4lu %4lu %4lu %4lu",
> > > +				allocs, high, grown,
>
> If it's required (most likely not, but it's a seq_printf and
> some people think those should never be modified because it's
> a public interface), it should probably be explicit:
>
> " : globalstat %7lu %6lu %5lu %4lu \t\t\t\t%4lu %4lu %4lu %4lu %4lu"

Yes, would be better. And if it is kept for compatibility it probably 
deserves a comment explaining the weirdness.

Cheers,
FJP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
