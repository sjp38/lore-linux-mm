Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 49E576B0033
	for <linux-mm@kvack.org>; Thu, 30 May 2013 15:59:48 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id n57so601361wev.22
        for <linux-mm@kvack.org>; Thu, 30 May 2013 12:59:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0000013eec0006ee-0f8caf7b-cc94-4f54-ae38-0ca6623b7841-000000@email.amazonses.com>
References: <alpine.DEB.2.10.1305222344060.12929@vincent-weaver-1.um.maine.edu>
	<20130523044803.GA25399@ZenIV.linux.org.uk>
	<20130523104154.GA23650@twins.programming.kicks-ass.net>
	<0000013ed1b8d0cc-ad2bb878-51bd-430c-8159-629b23ed1b44-000000@email.amazonses.com>
	<20130523152458.GD23650@twins.programming.kicks-ass.net>
	<0000013ed2297ba8-467d474a-7068-45b3-9fa3-82641e6aa363-000000@email.amazonses.com>
	<20130523163901.GG23650@twins.programming.kicks-ass.net>
	<0000013ed28b638a-066d7dc7-b590-49f8-9423-badb9537b8b6-000000@email.amazonses.com>
	<20130524140114.GK23650@twins.programming.kicks-ass.net>
	<0000013ed732b615-748f574f-ccb8-4de7-bbe4-d85d1cbf0c9d-000000@email.amazonses.com>
	<20130527064834.GA2781@laptop>
	<0000013eec0006ee-0f8caf7b-cc94-4f54-ae38-0ca6623b7841-000000@email.amazonses.com>
Date: Thu, 30 May 2013 22:59:46 +0300
Message-ID: <CAOJsxLEXgO3bMek8Mus9K6_vA5-H7wnoPyhVqCkm8uO9z526BQ@mail.gmail.com>
Subject: Re: [RFC][PATCH] mm: Fix RLIMIT_MEMLOCK
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, Vince Weaver <vincent.weaver@maine.edu>, LKML <linux-kernel@vger.kernel.org>, Paul Mackerras <paulus@samba.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>, trinity@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, roland@kernel.org, infinipath@qlogic.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-rdma@vger.kernel.org, Or Gerlitz <or.gerlitz@gmail.com>, Hugh Dickins <hughd@google.com>

On Mon, 27 May 2013, Peter Zijlstra wrote:
>> Before your patch pinned was included in locked and thus RLIMIT_MEMLOCK
>> had a single resource counter. After your patch RLIMIT_MEMLOCK is
>> applied separately to both -- more or less.

On Tue, May 28, 2013 at 7:37 PM, Christoph Lameter <cl@linux.com> wrote:
> Before the patch the count was doubled since a single page was counted
> twice: Once because it was mlocked (marked with PG_mlock) and then again
> because it was also pinned (the refcount was increased). Two different things.

Pinned vs. mlocked counting isn't the problem here. You changed
RLIMIT_MEMLOCK userspace ABI and that needs to be restored. So the
question is how can we preserve the old RLIMIT_MEMLOCK semantics while
avoiding the double accounting issue.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
