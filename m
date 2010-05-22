Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 01F196002CC
	for <linux-mm@kvack.org>; Sat, 22 May 2010 04:38:01 -0400 (EDT)
Received: by fxm11 with SMTP id 11so641349fxm.14
        for <linux-mm@kvack.org>; Sat, 22 May 2010 01:37:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100521211452.659982351@quilx.com>
References: <20100521211452.659982351@quilx.com>
Date: Sat, 22 May 2010 11:37:59 +0300
Message-ID: <AANLkTikU1cJR1FXKNbkSNeNUyihko1nTkSNMhE7Vq9Ip@mail.gmail.com>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Sat, May 22, 2010 at 12:14 AM, Christoph Lameter <cl@linux.com> wrote:
> SLEB is a merging of SLUB with some queuing concepts from SLAB and a new way
> of managing objects in the slabs using bitmaps. It uses a percpu queue so that
> free operations can be properly buffered and a bitmap for managing the
> free/allocated state in the slabs. It is slightly more inefficient than
> SLUB (due to the need to place large bitmaps --sized a few words--in some
> slab pages if there are more than BITS_PER_LONG objects in a slab page) but
> in general does compete well with SLUB (and therefore also with SLOB)
> in terms of memory wastage.

I merged patches 1-7 to "sleb/core" branch of slab.git if people want
to test them:

http://git.kernel.org/?p=linux/kernel/git/penberg/slab-2.6.git;a=shortlog;h=refs/heads/sleb/core

I didn't put them in linux-next for obvious reasons.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
