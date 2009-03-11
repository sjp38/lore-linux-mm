Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 78B016B003D
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 22:21:14 -0400 (EDT)
Date: Wed, 11 Mar 2009 03:21:07 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: PROBLEM: kernel BUG at mm/slab.c:3002!
Message-ID: <20090311022107.GB16561@wotan.suse.de>
References: <49B68450.9000505@hp.com> <alpine.DEB.1.10.0903101339210.9350@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0903101339210.9350@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: "Alan D. Brunelle" <Alan.Brunelle@hp.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, mpm@selenic.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 10, 2009 at 01:40:02PM -0400, Christoph Lameter wrote:
> Oh nice memory corruption. May have something to do with the vmap work by
> Nick.

Hmm, it might but I can't really tell. It happens in the vmap code
when kmallocing something, but it isn't obviously causing it AFAIKS.

Could you print out the values of the fields involved in the BUG()?
That might give some clues...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
