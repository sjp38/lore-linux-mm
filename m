Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 955DC6B0033
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 04:41:48 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id t1so808556ite.5
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 01:41:48 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id m82si16094252iom.191.2017.11.15.01.41.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Nov 2017 01:41:46 -0800 (PST)
Date: Wed, 15 Nov 2017 10:41:32 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 18/30] x86, kaiser: map virtually-addressed performance
 monitoring buffers
Message-ID: <20171115094132.ur4evzvsxvxdlivl@hirez.programming.kicks-ass.net>
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
 <20171110193139.B039E97B@viggo.jf.intel.com>
 <20171114182009.jbhobwxlkfjb2t6i@hirez.programming.kicks-ass.net>
 <30655167-963f-09e3-f88f-600bb95407e8@linux.intel.com>
 <alpine.LSU.2.11.1711141057510.2433@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1711141057510.2433@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, x86@kernel.org

On Tue, Nov 14, 2017 at 11:10:23AM -0800, Hugh Dickins wrote:
> I was about to agree, but now I'm not so sure.  I don't know much
> about these PMC things, but at a glance it looks like what is reserved
> by x86_reserve_hardware() may later be released by x86_release_hardware(),
> and then later reserved again by x86_reserve_hardware().  And although
> the static per-cpu area would be zeroed the first time, the second time
> it will contain data left over from before, so really needs the memset?

Ah, yes. It does get reused. I think its still fine, but yes lets keep
it. Better safe than sorry and its not a hot path in any case.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
