Received: by wa-out-1112.google.com with SMTP id m28so1426414wag.8
        for <linux-mm@kvack.org>; Mon, 18 Aug 2008 06:57:00 -0700 (PDT)
Message-ID: <84144f020808180657v2bdd5f76l4b0f1897c73ec0c0@mail.gmail.com>
Date: Mon, 18 Aug 2008 16:57:00 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch] mm: page allocator minor speedup
In-Reply-To: <20080818122957.GE9062@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080818122428.GA9062@wotan.suse.de>
	 <20080818122957.GE9062@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Nick,

On Mon, Aug 18, 2008 at 3:29 PM, Nick Piggin <npiggin@suse.de> wrote:
> Now that we don't put a ZERO_PAGE in the pagetables any more, and the
> "remove PageReserved from core mm" patch has had a long time to mature,
> let's remove the page reserved logic from the allocator.
>
> This saves several branches and about 100 bytes in some important paths.

Cool. Any numbers for this?

                             Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
