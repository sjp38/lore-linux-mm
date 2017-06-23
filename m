Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 15B5E6B03CB
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 05:34:39 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 4so11178392wrc.15
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 02:34:39 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id i194si3506705wmf.128.2017.06.23.02.34.37
        for <linux-mm@kvack.org>;
        Fri, 23 Jun 2017 02:34:37 -0700 (PDT)
Date: Fri, 23 Jun 2017 11:34:23 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v3 09/11] x86/mm: Add nopcid to turn off PCID
Message-ID: <20170623093423.ibhq7cyd5pta3cyi@pd.tnic>
References: <cover.1498022414.git.luto@kernel.org>
 <17c3a4f2e16aa83cbfea8ca9957ce75efbcf7f95.1498022414.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <17c3a4f2e16aa83cbfea8ca9957ce75efbcf7f95.1498022414.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, Jun 20, 2017 at 10:22:15PM -0700, Andy Lutomirski wrote:
> The parameter is only present on x86_64 systems to save a few bytes,
> as PCID is always disabled on x86_32.
> 
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
>  Documentation/admin-guide/kernel-parameters.txt |  2 ++
>  arch/x86/kernel/cpu/common.c                    | 18 ++++++++++++++++++
>  2 files changed, 20 insertions(+)

Reviewed-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
