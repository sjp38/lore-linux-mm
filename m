Date: Fri, 10 Oct 2008 10:36:02 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] Markers : revert synchronize marker unregister static
	inline (update)
Message-ID: <20081010083602.GB29413@elte.hu>
References: <20081009164700.c9042902.akpm@linux-foundation.org> <20081009170349.35e0df12.akpm@linux-foundation.org> <1223621125.8959.9.camel@penberg-laptop> <20081010071815.GA23247@Krystal> <20081010072334.GA15715@elte.hu> <20081010073749.GD23247@Krystal> <1223624589.8959.32.camel@penberg-laptop> <20081010074825.GF23247@Krystal>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081010074825.GF23247@Krystal>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

* Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca> wrote:

> Use a #define for synchronize marker unregister to fix include dependencies.
> 
> Fixes the slab circular inclusion, where rcupdate includes slab, which
> includes markers which includes rcupdate.
> 
> Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
> Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

applied to tip/tracing/core, thanks Mathieu!

also fast-tracked it to tip/auto-ftrace-next and tip/auto-latest, to 
ease Andrew's integration efforts.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
