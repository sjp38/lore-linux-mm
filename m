Date: Wed, 18 Aug 1999 10:55:44 +0200 (CEST)
From: Rik van Riel <riel@humbolt.nl.linux.org>
Subject: Re: AW: [bigmem-patch] 4GB with Linux on IA32
In-Reply-To: <A91A08D00A4FD2119BD500104B55BDF6021A6694@pdbh936a.pdb.siemens.de>
Message-ID: <Pine.LNX.4.05.9908181054140.5444-100000@humbolt.nl.linux.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Wichert, Gerhard" <Gerhard.Wichert@pdb.siemens.de>
Cc: 'Matthew Wilcox' <Matthew.Wilcox@genedata.com>, "'linux-kernel@vger.rutgers.edu'" <linux-kernel@vger.rutgers.edu>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 18 Aug 1999, Wichert, Gerhard wrote:

> This shows that we get only approx. 2% overhead in the worst case. In
> real-world applications you won't probably see any performance
> degradation.

And even if it's possible to create even worse degradations,
it doesn't matter.

People can simply take into account the way the system works
and (if performance really matters) optimize for it. And if
performance doesn't matter, who cares?

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.
--
work at:	http://www.reseau.nl/
home at:	http://www.nl.linux.org/~riel/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
