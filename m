Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A66242802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 08:44:25 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 62so7011960wmw.13
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 05:44:25 -0700 (PDT)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id 65si541306wmt.41.2017.06.30.05.44.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Jun 2017 05:44:24 -0700 (PDT)
Received: by mail-wm0-x22b.google.com with SMTP id 70so5798890wmo.1
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 05:44:23 -0700 (PDT)
Date: Fri, 30 Jun 2017 13:44:22 +0100
From: Matt Fleming <matt@codeblueprint.co.uk>
Subject: Re: [PATCH v4 00/10] PCID and improved laziness
Message-ID: <20170630124422.GA12077@codeblueprint.co.uk>
References: <cover.1498751203.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1498751203.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Thu, 29 Jun, at 08:53:12AM, Andy Lutomirski wrote:
> *** Ingo, even if this misses 4.13, please apply the first patch before
> *** the merge window.
> 
> There are three performance benefits here:
> 
> 1. TLB flushing is slow.  (I.e. the flush itself takes a while.)
>    This avoids many of them when switching tasks by using PCID.  In
>    a stupid little benchmark I did, it saves about 100ns on my laptop
>    per context switch.  I'll try to improve that benchmark.
> 
> 2. Mms that have been used recently on a given CPU might get to keep
>    their TLB entries alive across process switches with this patch
>    set.  TLB fills are pretty fast on modern CPUs, but they're even
>    faster when they don't happen.
> 
> 3. Lazy TLB is way better.  We used to do two stupid things when we
>    ran kernel threads: we'd send IPIs to flush user contexts on their
>    CPUs and then we'd write to CR3 for no particular reason as an excuse
>    to stop further IPIs.  With this patch, we do neither.

Heads up, I'm gonna queue this for a run on SUSE's performance test
grid.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
