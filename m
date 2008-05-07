Date: Wed, 7 May 2008 13:05:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01 of 11] mmu-notifier-core
Message-Id: <20080507130528.adfd154c.akpm@linux-foundation.org>
In-Reply-To: <e20917dcc8284b6a07cf.1210170951@duo.random>
References: <patchbomb.1210170950@duo.random>
	<e20917dcc8284b6a07cf.1210170951@duo.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: clameter@sgi.com, steiner@sgi.com, holt@sgi.com, npiggin@suse.de, a.p.zijlstra@chello.nl, kvm-devel@lists.sourceforge.net, kanojsarcar@yahoo.com, rdreier@cisco.com, swise@opengridcomputing.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, hugh@veritas.com, rusty@rustcorp.com.au, aliguori@us.ibm.com, chrisw@redhat.com, marcelo@kvack.org, dada1@cosmosbay.com, paulmck@us.ibm.com, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 07 May 2008 16:35:51 +0200
Andrea Arcangeli <andrea@qumranet.com> wrote:

> # HG changeset patch
> # User Andrea Arcangeli <andrea@qumranet.com>
> # Date 1210096013 -7200
> # Node ID e20917dcc8284b6a07cfcced13dda4cbca850a9c
> # Parent  5026689a3bc323a26d33ad882c34c4c9c9a3ecd8
> mmu-notifier-core

The patch looks OK to me.

The proposal is that we sneak this into 2.6.26.  Are there any
sufficiently-serious objections to this?

The patch will be a no-op for 2.6.26.

This is all rather unusual.  For the record, could we please review the
reasons for wanting to do this?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
