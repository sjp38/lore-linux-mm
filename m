Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 75AA36B02B4
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 18:47:42 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id y206so3022854wmd.1
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 15:47:42 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o14si1891310wmi.240.2017.08.15.15.47.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 Aug 2017 15:47:40 -0700 (PDT)
Date: Tue, 15 Aug 2017 15:47:28 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Message-ID: <20170815224728.GA1373@linux-80c1.suse>
References: <84c7f26182b7f4723c0fe3b34ba912a9de92b8b7.1502758114.git.tim.c.chen@linux.intel.com>
 <CA+55aFznC1wqBSfYr8=92LGqz5-F6fHMzdXoqM4aOYx8sT1Dhg@mail.gmail.com>
 <20170815022743.GB28715@tassilo.jf.intel.com>
 <CA+55aFyHVV=eTtAocUrNLymQOCj55qkF58+N+Tjr2YS9TrqFow@mail.gmail.com>
 <20170815031524.GC28715@tassilo.jf.intel.com>
 <CA+55aFw1A1C8qUeKPUzACrsqn97UDxTP3M2SRs80aEztfU=Qbg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <CA+55aFw1A1C8qUeKPUzACrsqn97UDxTP3M2SRs80aEztfU=Qbg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andi Kleen <ak@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Kan Liang <kan.liang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, 14 Aug 2017, Linus Torvalds wrote:

>On Mon, Aug 14, 2017 at 8:15 PM, Andi Kleen <ak@linux.intel.com> wrote:
>> But what should we do when some other (non page) wait queue runs into the
>> same problem?
>
>Hopefully the same: root-cause it.

Or you can always use wake_qs; which exists _exactly_ for the issues you
are running into. Note that Linus does not want them in general wait:

https://lkml.org/lkml/2017/7/7/605

... but you can always use them on your own if you really need to (ie locks,
ipc, etc).

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
