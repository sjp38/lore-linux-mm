Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id BF8E16B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 18:57:33 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id x5so8317067uai.9
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 15:57:33 -0700 (PDT)
Received: from mail-vk0-x236.google.com (mail-vk0-x236.google.com. [2607:f8b0:400c:c05::236])
        by mx.google.com with ESMTPS id r17si3217901uaa.404.2017.08.15.15.57.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 15:57:32 -0700 (PDT)
Received: by mail-vk0-x236.google.com with SMTP id d124so7169650vkf.2
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 15:57:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFyMkd8EaozxvAZo9i3ArKh7m6HLjsUB34xnDBzXz4gowg@mail.gmail.com>
References: <84c7f26182b7f4723c0fe3b34ba912a9de92b8b7.1502758114.git.tim.c.chen@linux.intel.com>
 <CA+55aFznC1wqBSfYr8=92LGqz5-F6fHMzdXoqM4aOYx8sT1Dhg@mail.gmail.com>
 <20170815022743.GB28715@tassilo.jf.intel.com> <CA+55aFyHVV=eTtAocUrNLymQOCj55qkF58+N+Tjr2YS9TrqFow@mail.gmail.com>
 <20170815031524.GC28715@tassilo.jf.intel.com> <CA+55aFw1A1C8qUeKPUzACrsqn97UDxTP3M2SRs80aEztfU=Qbg@mail.gmail.com>
 <20170815224728.GA1373@linux-80c1.suse> <CA+55aFyMkd8EaozxvAZo9i3ArKh7m6HLjsUB34xnDBzXz4gowg@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 15 Aug 2017 15:57:32 -0700
Message-ID: <CA+55aFw84Cu0VZdR_Rj6b03hMYBFgt9BCnSEx+OLXDsp4dDO=g@mail.gmail.com>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Kan Liang <kan.liang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Aug 15, 2017 at 3:56 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Except they really don't actually work for this case, exactly because
> they also simplify away "minor" details like exclusive vs
> non-exclusive etc.
>
> The page wait-queue very much has a mix of "wake all" and "wake one" semantics.

Oh, and the page wait-queue really needs that key argument too, which
is another thing that swait queue code got rid of in the name of
simplicity.

So no. The swait code is absolutely _entirely_ the wrong thing to use.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
