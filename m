Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D90566B03BE
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 05:27:30 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z1so16111429wrz.10
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 02:27:30 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 42si16433165wrz.119.2017.06.21.02.27.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 21 Jun 2017 02:27:29 -0700 (PDT)
Date: Wed, 21 Jun 2017 11:27:23 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v3 09/11] x86/mm: Add nopcid to turn off PCID
In-Reply-To: <17c3a4f2e16aa83cbfea8ca9957ce75efbcf7f95.1498022414.git.luto@kernel.org>
Message-ID: <alpine.DEB.2.20.1706211127120.2328@nanos>
References: <cover.1498022414.git.luto@kernel.org> <17c3a4f2e16aa83cbfea8ca9957ce75efbcf7f95.1498022414.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, 20 Jun 2017, Andy Lutomirski wrote:

> The parameter is only present on x86_64 systems to save a few bytes,
> as PCID is always disabled on x86_32.
> 
> Signed-off-by: Andy Lutomirski <luto@kernel.org>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
