Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id E89556B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 09:43:50 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id s23-v6so19144664plr.15
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 06:43:50 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j11si4181235pff.363.2018.04.05.06.43.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 06:43:49 -0700 (PDT)
Date: Thu, 5 Apr 2018 09:43:46 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] ring-buffer: Add set/clear_current_oom_origin() during
 allocations
Message-ID: <20180405094346.104cf288@gandalf.local.home>
In-Reply-To: <CAJWu+opM6RjK-Z1dr35XvQ5cLKaV=cLG5uMu-rLkoO=X03c+FA@mail.gmail.com>
References: <20180404115310.6c69e7b9@gandalf.local.home>
	<20180404120002.6561a5bc@gandalf.local.home>
	<CAJWu+orC-1JDYHDTQU+DFckGq5ZnXBCCq9wLG-gNK0Nc4-vo7w@mail.gmail.com>
	<20180404121326.6eca4fa3@gandalf.local.home>
	<CAJWu+op5-sr=2xWDYcd7FDBeMtrM9Zm96BgGzb4Q31UGBiU3ew@mail.gmail.com>
	<CAJWu+opM6RjK-Z1dr35XvQ5cLKaV=cLG5uMu-rLkoO=X03c+FA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joelaf@google.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>

On Wed, 4 Apr 2018 16:59:18 -0700
Joel Fernandes <joelaf@google.com> wrote:

> Happy to try anything else, BTW when the si_mem_available check
> enabled, this doesn't happen and the buffer_size_kb write fails
> normally without hurting anything else.

Can you remove the RETRY_MAYFAIL and see if you can try again? It may
be that we just remove that, and if si_mem_available() is wrong, it
will kill the process :-/ My original code would only add MAYFAIL if it
was a kernel thread (which is why I created the mflags variable).

-- Steve
