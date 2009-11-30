Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id EB4E1600309
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 18:43:45 -0500 (EST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH/RFC 1/6] numa: Use Generic Per-cpu Variables for numa_node_id()
Date: Tue, 1 Dec 2009 00:43:35 +0100
References: <20091113211714.15074.29078.sendpatchset@localhost.localdomain> <alpine.DEB.1.10.0911201044320.25879@V090114053VZO-1> <1259612920.4663.156.camel@useless.americas.hpqcorp.net>
In-Reply-To: <1259612920.4663.156.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Message-Id: <200912010043.36115.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-arch@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Monday 30 November 2009, Lee Schermerhorn wrote:
> Looking at other asm/foo.h and asm-generic/foo.h relationships, I see
> that some define the generic version of the api in the asm-generic
> header if the arch asm header hasn't already defined it.  asm/topology.h
> is an instance of this.  It includes asm-generic/topology.h after
> defining arch specific versions of some of the api.

This works alright, but if you expect every architecture to include the
asm-generic version, you might just as well take that choice away from
the architecture and put the common code into the linux/foo.h file,
which you can still override with definitions in asm/foo.h.

Most of the asm-generic headers are just mostly generic, and get included
by some but not all architectures, the others defining the whole contents
of the asm-generic file themselves in a different way.

So if you e.g. want ia64 to do everything itself and all other architectures to
share some or all parts of asm-generic/topology, your approach is right,
otherwise just leave the code in some file in include/linux/.

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
