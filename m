Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 5D12B6B016B
	for <linux-mm@kvack.org>; Thu, 30 May 2013 02:32:10 -0400 (EDT)
Received: by mail-we0-f171.google.com with SMTP id t59so7228343wes.30
        for <linux-mm@kvack.org>; Wed, 29 May 2013 23:32:08 -0700 (PDT)
Date: Thu, 30 May 2013 08:32:05 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC][PATCH] mm: Fix RLIMIT_MEMLOCK
Message-ID: <20130530063205.GA5310@gmail.com>
References: <20130523152458.GD23650@twins.programming.kicks-ass.net>
 <0000013ed2297ba8-467d474a-7068-45b3-9fa3-82641e6aa363-000000@email.amazonses.com>
 <20130523163901.GG23650@twins.programming.kicks-ass.net>
 <0000013ed28b638a-066d7dc7-b590-49f8-9423-badb9537b8b6-000000@email.amazonses.com>
 <20130524140114.GK23650@twins.programming.kicks-ass.net>
 <0000013ed732b615-748f574f-ccb8-4de7-bbe4-d85d1cbf0c9d-000000@email.amazonses.com>
 <20130527064834.GA2781@laptop>
 <0000013eec0006ee-0f8caf7b-cc94-4f54-ae38-0ca6623b7841-000000@email.amazonses.com>
 <20130529075845.GA24506@gmail.com>
 <51A65CC0.3050800@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51A65CC0.3050800@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>, Vince Weaver <vincent.weaver@maine.edu>, linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>, trinity@vger.kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, roland@kernel.org, infinipath@qlogic.com, linux-mm@kvack.org, linux-rdma@vger.kernel.org, Or Gerlitz <or.gerlitz@gmail.com>, Hugh Dickins <hughd@google.com>


* KOSAKI Motohiro <kosaki.motohiro@gmail.com> wrote:

> Hi
> 
> I'm unhappy you guys uses offensive word so much. Please cool down all 
> you guys. :-/ In fact, _BOTH_ the behavior before and after Cristoph's 
> patch doesn't have cleaner semantics.

Erm, this feature _regressed_ after the patch. All other concerns are 
secondary. What's so difficult to understand about that?

> And PeterZ proposed make new cleaner one rather than revert. No need to 
> hassle.

Sorry, that's not how we deal with regressions upstream...

I've been pretty polite in fact, compared to say Linus - someone should 
put a politically correct summary of:

   https://lkml.org/lkml/2013/2/22/456
   https://lkml.org/lkml/2013/3/26/1113

into Documentation/, people keep forgetting about it.

I'm sorry if being direct and to the point offends you [no, not really], 
this discussion got _way_ off the real track it should be on: that this is 
a _regression_.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
