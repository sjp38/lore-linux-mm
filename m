Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8D8856B005A
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 05:24:11 -0400 (EDT)
Received: by fxm12 with SMTP id 12so80035fxm.38
        for <linux-mm@kvack.org>; Fri, 12 Jun 2009 02:24:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1244798515.7172.99.camel@pasglop>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI>
	 <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI>
	 <20090612091002.GA32052@elte.hu> <1244798515.7172.99.camel@pasglop>
Date: Fri, 12 Jun 2009 12:24:55 +0300
Message-ID: <84144f020906120224v5ef44637pb849fd247eab84ea@mail.gmail.com>
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or
	suspending
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@linux-foundation.org, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi Ben,

On Fri, Jun 12, 2009 at 12:21 PM, Benjamin
Herrenschmidt<benh@kernel.crashing.org> wrote:
> I really think we are looking for trouble (and a lot of hidden bugs) by
> trying to "fix" all callers, in addition to making some code like
> vmalloc() more failure prone because it's unconditionally changed from
> GFP_KERNEL to GFP_NOWAIT.

It's a new API function vmalloc_node_boot() that uses GFP_NOWAIT so I
don't share your concern that it's error prone.

                                              Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
