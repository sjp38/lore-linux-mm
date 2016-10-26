Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7F5D36B027C
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 15:12:14 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id p53so8416428qtp.1
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 12:12:14 -0700 (PDT)
Received: from mx6-phx2.redhat.com (mx6-phx2.redhat.com. [209.132.183.39])
        by mx.google.com with ESMTPS id o71si2007803qka.310.2016.10.26.12.12.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 12:12:13 -0700 (PDT)
Date: Wed, 26 Oct 2016 15:11:42 -0400 (EDT)
From: Bob Peterson <rpeterso@redhat.com>
Message-ID: <1536202752.13054466.1477509102622.JavaMail.zimbra@redhat.com>
In-Reply-To: <CA+55aFzVmppmua4U0pesp2moz7vVPbH1NP264EKeW3YqOzFc3A@mail.gmail.com>
References: <CAHc6FU4e5sueLi7pfeXnSbuuvnc5PaU3xo5Hnn=SvzmQ+ZOEeg@mail.gmail.com> <CALCETrUt+4ojyscJT1AFN5Zt3mKY0rrxcXMBOUUJzzLMWXFXHg@mail.gmail.com> <CA+55aFzB2C0aktFZW3GquJF6dhM1904aDPrv4vdQ8=+mWO7jcg@mail.gmail.com> <CA+55aFww1iLuuhHw=iYF8xjfjGj8L+3oh33xxUHjnKKnsR-oHg@mail.gmail.com> <CA+55aFyRv0YttbLUYwDem=-L5ZAET026umh6LOUQ6hWaRur_VA@mail.gmail.com> <996124132.13035408.1477505043741.JavaMail.zimbra@redhat.com> <CA+55aFzVmppmua4U0pesp2moz7vVPbH1NP264EKeW3YqOzFc3A@mail.gmail.com>
Subject: Re: CONFIG_VMAP_STACK, on-stack struct, and wake_up_bit
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

----- Original Message -----
| On Wed, Oct 26, 2016 at 11:04 AM, Bob Peterson <rpeterso@redhat.com> wrote:
| >
| > I can test it for you, if you give me about an hour.

Sorry. I guess I underestimated the time it takes to build a kernel
on my test box. It will take a little longer, but it's compiling now.
 
| I can definitely wait an hour, it would be lovely to see more testing.
| Especially if you have a NUMA machine and an interesting workload.

I'll see what I can cook up.
 
| And if you actually have that NUMA machine and a load that shows the
| page_waietutu effects, it would also be lovely if you can then
| _additionally_ test the patch that PeterZ wrote a few weeks ago, it
| was on the mm list about a month ago:
| 
|   Date: Thu, 29 Sep 2016 15:08:27 +0200
|   From: Peter Zijlstra <peterz@infradead.org>
|   Subject: Re: page_waitqueue() considered harmful
|   Message-ID: <20160929130827.GX5016@twins.programming.kicks-ass.net>
| 
| and if you don't find it I can forward it to you (Peter had a few
| versions, that latest one is the one that looked best).

I'll see what I can do, but first I'll check basic functionality
and report back.
 
Bob Peterson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
