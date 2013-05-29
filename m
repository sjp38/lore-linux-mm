Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id B396C6B009F
	for <linux-mm@kvack.org>; Wed, 29 May 2013 03:58:50 -0400 (EDT)
Received: by mail-ee0-f51.google.com with SMTP id e51so5170897eek.38
        for <linux-mm@kvack.org>; Wed, 29 May 2013 00:58:49 -0700 (PDT)
Date: Wed, 29 May 2013 09:58:45 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: [regression] Re: [RFC][PATCH] mm: Fix RLIMIT_MEMLOCK
Message-ID: <20130529075845.GA24506@gmail.com>
References: <20130523104154.GA23650@twins.programming.kicks-ass.net>
 <0000013ed1b8d0cc-ad2bb878-51bd-430c-8159-629b23ed1b44-000000@email.amazonses.com>
 <20130523152458.GD23650@twins.programming.kicks-ass.net>
 <0000013ed2297ba8-467d474a-7068-45b3-9fa3-82641e6aa363-000000@email.amazonses.com>
 <20130523163901.GG23650@twins.programming.kicks-ass.net>
 <0000013ed28b638a-066d7dc7-b590-49f8-9423-badb9537b8b6-000000@email.amazonses.com>
 <20130524140114.GK23650@twins.programming.kicks-ass.net>
 <0000013ed732b615-748f574f-ccb8-4de7-bbe4-d85d1cbf0c9d-000000@email.amazonses.com>
 <20130527064834.GA2781@laptop>
 <0000013eec0006ee-0f8caf7b-cc94-4f54-ae38-0ca6623b7841-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013eec0006ee-0f8caf7b-cc94-4f54-ae38-0ca6623b7841-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>, Vince Weaver <vincent.weaver@maine.edu>, linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>, trinity@vger.kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, roland@kernel.org, infinipath@qlogic.com, linux-mm@kvack.org, linux-rdma@vger.kernel.org, Or Gerlitz <or.gerlitz@gmail.com>, Hugh Dickins <hughd@google.com>


* Christoph Lameter <cl@linux.com> wrote:

> On Mon, 27 May 2013, Peter Zijlstra wrote:
> 
> > Before your patch pinned was included in locked and thus RLIMIT_MEMLOCK
> > had a single resource counter. After your patch RLIMIT_MEMLOCK is
> > applied separately to both -- more or less.
> 
> Before the patch the count was doubled since a single page was counted 
> twice: Once because it was mlocked (marked with PG_mlock) and then again 
> because it was also pinned (the refcount was increased). Two different 
> things.

Christoph, why are you *STILL* arguing??

You caused a *regression* in a userspace ABI plain and simple, and a 
security relevant one. Furtermore you modified kernel/events/core.c yet 
you never even Cc:-ed the parties involved ...

All your excuses, obfuscation and attempts to redefine the universe to 
your liking won't change reality: it worked before, it does not now. Take 
responsibility for your action for christ's sake and move forward towards 
a resolution , okay?

When can we expect a fix from you for the breakage you caused? Or at least 
a word that acknowledges that you broke a user ABI carelessly?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
