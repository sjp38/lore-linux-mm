Date: Thu, 10 May 2007 14:49:31 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [Bug 8464] New: autoreconf: page allocation failure. order:2,
 mode:0x84020
In-Reply-To: <20070510144319.48d2841a.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0705101447120.12874@schroedinger.engr.sgi.com>
References: <200705102128.l4ALSI2A017437@fire-2.osdl.org>
 <20070510144319.48d2841a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, linux-kernel@vger.kernel.org, Nicolas.Mailhot@LaPoste.net, "bugme-daemon@kernel-bugs.osdl.org" <bugme-daemon@bugzilla.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 10 May 2007, Andrew Morton wrote:

> Christoph, can we please take a look at /proc/slabinfo and its slub
> equivalent (I forget what that is?) and review any and all changes to the
> underlying allocation size for each cache?
> 
> Because this is *not* something we should change lightly.

It was changed specially for mm in order to stress the antifrag code. If 
this causes trouble then do not merge the patches against SLUB that 
exploit the antifrag methods. This failure should help see how effective 
Mel's antifrag patches are. He needs to get on this dicussion.

Upstream has slub_max_order=1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
