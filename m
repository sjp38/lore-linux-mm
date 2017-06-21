Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id AF8176B0421
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 13:06:36 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 4so16984780wrc.15
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 10:06:36 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id f29si17856428wra.26.2017.06.21.10.06.34
        for <linux-mm@kvack.org>;
        Wed, 21 Jun 2017 10:06:34 -0700 (PDT)
Date: Wed, 21 Jun 2017 19:06:22 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v3 04/11] x86/mm: Give each mm TLB flush generation a
 unique ID
Message-ID: <20170621170622.wi74cttjw7rtklcl@pd.tnic>
References: <cover.1498022414.git.luto@kernel.org>
 <e2903f555bd23f8cf62f34b91895c42f7d4e40e3.1498022414.git.luto@kernel.org>
 <20170621103322.pwi6koe7jee7hd63@pd.tnic>
 <CALCETrVoRjSL2HncTGQ-PJ_1ycUAV3UcDVMEGw=-f7AbqtEN6w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CALCETrVoRjSL2HncTGQ-PJ_1ycUAV3UcDVMEGw=-f7AbqtEN6w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, Jun 21, 2017 at 08:23:07AM -0700, Andy Lutomirski wrote:
> It's stated explicitly in the comment where it's declared in the same file.

Doh, it says "zero" there. I should learn how to read.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
