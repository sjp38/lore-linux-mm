Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B2DA0600227
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 12:23:04 -0400 (EDT)
Date: Tue, 29 Jun 2010 10:42:42 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q 01/16] [PATCH] ipc/sem.c: Bugfix for semop() not reporting
  successful operation
In-Reply-To: <AANLkTinmvRtH24uflD9e7MknaW6tgMSnN75vVgaj0IM6@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1006291042100.16135@router.home>
References: <20100625212026.810557229@quilx.com> <20100625212101.622422748@quilx.com> <AANLkTinmvRtH24uflD9e7MknaW6tgMSnN75vVgaj0IM6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, Manfred Spraul <manfred@colorfullife.com>, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This is a patch from Manfred. Required to make 2.6.35-rc3 work.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
