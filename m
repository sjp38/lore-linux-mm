Date: Fri, 10 Oct 2008 11:06:14 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] Markers : revert synchronize marker unregister static
	inline
Message-ID: <20081010090614.GB5116@elte.hu>
References: <20081009164700.c9042902.akpm@linux-foundation.org> <20081009170349.35e0df12.akpm@linux-foundation.org> <1223621125.8959.9.camel@penberg-laptop> <20081010071815.GA23247@Krystal> <20081010072334.GA15715@elte.hu> <20081010073749.GD23247@Krystal> <1223624589.8959.32.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1223624589.8959.32.camel@penberg-laptop>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

* Pekka Enberg <penberg@cs.helsinki.fi> wrote:

> On Fri, 2008-10-10 at 03:37 -0400, Mathieu Desnoyers wrote:
> > Use a #define for synchronize marker unregister to fix include
> > dependencies.
> 
> Looks good to me. Maybe you want to explicitly mention the connection 
> with slab in the changelog though? Otherwise someone else will go and 
> break the thing giving Andrew yet another excuse to drop my tree. :-)

i applied the commit below - and i added the info about this slab.git 
and tracing.git integration effect as well.

	Ingo

-------------->
