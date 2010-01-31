Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8111E62000C
	for <linux-mm@kvack.org>; Sun, 31 Jan 2010 15:38:44 -0500 (EST)
Subject: Re: [PATCH 09/10] mm/slab.c: Fix continuation line formats
From: Joe Perches <joe@perches.com>
In-Reply-To: <201001312132.19798.elendil@planet.nl>
References: <cover.1264967493.git.joe@perches.com>
	 <cover.1264967493.git.joe@perches.com>
	 <9d64ab1e1d69c750d53a398e09fe5da2437668c5.1264967500.git.joe@perches.com>
	 <201001312132.19798.elendil@planet.nl>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 31 Jan 2010 12:38:42 -0800
Message-ID: <1264970322.25140.175.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>
Cc: linux-kernel@vger.kernel.org, cl@linux-foundation.org, penberg@cs.helsinki.fi, mpm@selenic.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 2010-01-31 at 21:32 +0100, Frans Pop wrote:
> If that spacing part is really needed (is it?), wouldn't it be more
> readable as:
> > +		seq_printf(m, " : globalstat %7lu %6lu %5lu %4lu"
> > +				" 				"
> > +				"%4lu %4lu %4lu %4lu %4lu",  
> > +				allocs, high, grown,

If it's required (most likely not, but it's a seq_printf and
some people think those should never be modified because it's
a public interface), it should probably be explicit:

" : globalstat %7lu %6lu %5lu %4lu \t\t\t\t%4lu %4lu %4lu %4lu %4lu"



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
