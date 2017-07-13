Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 21262440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 15:36:09 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id k192so79178302ith.0
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 12:36:09 -0700 (PDT)
Received: from mail-it0-x22d.google.com (mail-it0-x22d.google.com. [2607:f8b0:4001:c0b::22d])
        by mx.google.com with ESMTPS id t136si216963ita.41.2017.07.13.12.36.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 12:36:08 -0700 (PDT)
Received: by mail-it0-x22d.google.com with SMTP id k192so3097348ith.1
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 12:36:08 -0700 (PDT)
Date: Thu, 13 Jul 2017 20:36:04 +0100
From: Matt Fleming <matt@codeblueprint.co.uk>
Subject: Re: [PATCH v4 00/10] PCID and improved laziness
Message-ID: <20170713193604.GA10316@codeblueprint.co.uk>
References: <cover.1498751203.git.luto@kernel.org>
 <20170630124422.GA12077@codeblueprint.co.uk>
 <20170711113233.GA19177@codeblueprint.co.uk>
 <CALCETrVf87m6CRG3-m=i3wP5DyD5gfcMVJA4KDXb8TarCps2iA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVf87m6CRG3-m=i3wP5DyD5gfcMVJA4KDXb8TarCps2iA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, 11 Jul, at 08:00:47AM, Andy Lutomirski wrote:
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/luto/misc-tests.git/
> 
> I did:
> 
> $ ./context_switch_latency_64 0 process same

Ah, that's better. I see about a 3.3% speedup with your patches when
running the context-switch benchmark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
