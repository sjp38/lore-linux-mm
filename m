Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 581A76B0279
	for <linux-mm@kvack.org>; Mon,  3 Jul 2017 06:56:57 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id z75so6255501wmc.5
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 03:56:57 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id p62si17528632wmp.45.2017.07.03.03.56.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 03 Jul 2017 03:56:55 -0700 (PDT)
Date: Mon, 3 Jul 2017 12:56:45 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v4 10/10] x86/mm: Try to preserve old TLB entries using
 PCID
In-Reply-To: <cf600d28712daa8e2222c08a10f6c914edab54f2.1498751203.git.luto@kernel.org>
Message-ID: <alpine.DEB.2.20.1707031255520.2188@nanos>
References: <cover.1498751203.git.luto@kernel.org> <cf600d28712daa8e2222c08a10f6c914edab54f2.1498751203.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; BOUNDARY="8323329-1251026268-1499079405=:2188"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1251026268-1499079405=:2188
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Thu, 29 Jun 2017, Andy Lutomirski wrote:
> ping-pong between two mms on the same CPU using eventfd:
>   patched:         1.22Aus
>   patched, nopcid: 1.33Aus
>   unpatched:       1.34Aus
> 
> Same ping-pong, but now touch 512 pages (all zero-page to minimize
> cache misses) each iteration.  dTLB misses are measured by
> dtlb_load_misses.miss_causes_a_walk:
>   patched:         1.8Aus  11M  dTLB misses
>   patched, nopcid: 6.2Aus, 207M dTLB misses
>   unpatched:       6.1Aus, 190M dTLB misses
> 
> Reviewed-by: Nadav Amit <nadav.amit@gmail.com>
> Signed-off-by: Andy Lutomirski <luto@kernel.org>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
--8323329-1251026268-1499079405=:2188--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
