Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 5894C6B003C
	for <linux-mm@kvack.org>; Tue, 28 May 2013 12:19:27 -0400 (EDT)
Date: Tue, 28 May 2013 16:19:25 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH] mm: Fix RLIMIT_MEMLOCK
In-Reply-To: <CAHGf_=r4sqQKELPh48z=KPyuyAM3uz5Az9RpssUwnK4QRoamHQ@mail.gmail.com>
Message-ID: <0000013eebefddd4-ace0f251-cfba-41cf-b48e-266cb13bcebd-000000@email.amazonses.com>
References: <alpine.DEB.2.10.1305221523420.9944@vincent-weaver-1.um.maine.edu> <alpine.DEB.2.10.1305221953370.11450@vincent-weaver-1.um.maine.edu> <alpine.DEB.2.10.1305222344060.12929@vincent-weaver-1.um.maine.edu> <20130523044803.GA25399@ZenIV.linux.org.uk>
 <20130523104154.GA23650@twins.programming.kicks-ass.net> <0000013ed1b8d0cc-ad2bb878-51bd-430c-8159-629b23ed1b44-000000@email.amazonses.com> <20130523152458.GD23650@twins.programming.kicks-ass.net> <0000013ed2297ba8-467d474a-7068-45b3-9fa3-82641e6aa363-000000@email.amazonses.com>
 <20130523163901.GG23650@twins.programming.kicks-ass.net> <0000013ed28b638a-066d7dc7-b590-49f8-9423-badb9537b8b6-000000@email.amazonses.com> <20130524140114.GK23650@twins.programming.kicks-ass.net> <0000013ed732b615-748f574f-ccb8-4de7-bbe4-d85d1cbf0c9d-000000@email.amazonses.com>
 <CAHGf_=r4sqQKELPh48z=KPyuyAM3uz5Az9RpssUwnK4QRoamHQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, Vince Weaver <vincent.weaver@maine.edu>, LKML <linux-kernel@vger.kernel.org>, Paul Mackerras <paulus@samba.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>, trinity@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Roland Dreier <roland@kernel.org>, infinipath@qlogic.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-rdma@vger.kernel.org, Or Gerlitz <or.gerlitz@gmail.com>

On Sat, 25 May 2013, KOSAKI Motohiro wrote:

> If pinned and mlocked are totally difference intentionally, why IB uses
> RLIMIT_MEMLOCK. Why don't IB uses IB specific limit and why only IB raise up
> number of pinned pages and other gup users don't.
> I can't guess IB folk's intent.

True another limit would be better. The reason that IB raises the
pinned pages is because IB permanently pins those pages. Other users of
gup do that temporarily.

If there are other users that pin pages permanently should also account
for it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
