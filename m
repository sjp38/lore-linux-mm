Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2A9166B01B8
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 11:19:07 -0400 (EDT)
Date: Tue, 29 Jun 2010 10:15:44 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q 09/16] [percpu] make allocpercpu usable during early boot
In-Reply-To: <4C25B610.1050305@kernel.org>
Message-ID: <alpine.DEB.2.00.1006291014540.16135@router.home>
References: <20100625212026.810557229@quilx.com> <20100625212106.384650677@quilx.com> <4C25B610.1050305@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Sat, 26 Jun 2010, Tejun Heo wrote:

> Christoph, how do you wanna route these patches?  I already have the
> other two patches in the percpu tree, I can push this there too, which
> then you can pull into the allocator tree.

Please push via your trees. Lets keep stuff subsystem specific if
possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
