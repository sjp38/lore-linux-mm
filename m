Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0F2286B024A
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 16:45:03 -0400 (EDT)
Date: Tue, 6 Jul 2010 15:41:39 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q 09/16] [percpu] make allocpercpu usable during early boot
In-Reply-To: <4C2A118C.2030206@kernel.org>
Message-ID: <alpine.DEB.2.00.1007061541210.7945@router.home>
References: <20100625212026.810557229@quilx.com> <20100625212106.384650677@quilx.com> <4C25B610.1050305@kernel.org> <alpine.DEB.2.00.1006291014540.16135@router.home> <4C2A118C.2030206@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jun 2010, Tejun Heo wrote:

> I haven't committed the gfp_allowed_mask patch yet.  I'll commit it
> once it gets resolved.

Dont commit. I dropped it myself.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
