Date: Mon, 8 Mar 2004 23:02:46 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [RFC][PATCH 4/4] vm-mapped-x-active-lists
Message-ID: <20040309070246.GI655@holomorphy.com>
References: <404D56D8.2000008@cyberone.com.au> <404D5784.9080004@cyberone.com.au> <404D5A6F.4070300@matchmail.com> <404D5EED.80105@cyberone.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <404D5EED.80105@cyberone.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Mike Fedyk <mfedyk@matchmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 09, 2004 at 05:06:37PM +1100, Nick Piggin wrote:
> Not sure to be honest, I haven't looked at it :\. I'm not really
> sure if the rmap mitigation direction is just a holdover until
> page clustering or intended as a permanent feature...
> Either way, I trust its proponents will take the onus for regressions.

Actually, anobjrmap does wonderful things wrt. liberating pgcl
internals from some very frustrating complications having to do with
assumptions of a 1:1 correspondence between pte pages and struct pages,
so I would regard work in the direction of anobjrmap as useful to
advance the state of page clustering regardless of its rmap mitigation
overtones.  The "partial" objrmap is actually insufficient to clean up
this assumption, and introduces new failure modes I don't like (which
it is in fact not necessary to do; aa's code is very close to doing the
partial-but-insufficient-for-pgcl objrmap properly apart from trying to
allocate more pte_chains than necessary and not falling back to the vma
lists for linear/nonlinear mapping mixtures). The current port has some
code to deal with this I'm extremely eager to dump as soon as things
such as anobjrmap etc. make it possible, if they're merged.

Current efforts are now a background/spare time affair centering around
non-i386 architectures and driver audits.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
