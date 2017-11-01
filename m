Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7FB326B026B
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 04:31:26 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id r18so1890140pgu.9
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 01:31:26 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id u66si93841pfa.109.2017.11.01.01.31.24
        for <linux-mm@kvack.org>;
        Wed, 01 Nov 2017 01:31:25 -0700 (PDT)
Date: Wed, 1 Nov 2017 17:31:16 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: possible deadlock in lru_add_drain_all
Message-ID: <20171101083116.GA3172@X58A-UD3R>
References: <089e0825eec8955c1f055c83d476@google.com>
 <20171027093418.om5e566srz2ztsrk@dhcp22.suse.cz>
 <CACT4Y+Y=NCy20_k4YcrCF2Q0f16UPDZBVAF=RkkZ0uSxZq5XaA@mail.gmail.com>
 <20171027134234.7dyx4oshjwd44vqx@dhcp22.suse.cz>
 <20171030082203.4xvq2af25shfci2z@dhcp22.suse.cz>
 <20171030100921.GA18085@X58A-UD3R>
 <20171030151009.ip4k7nwan7muouca@hirez.programming.kicks-ass.net>
 <20171031131333.pr2ophwd2bsvxc3l@dhcp22.suse.cz>
 <20171031152532.uah32qiftjerc3gx@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171031152532.uah32qiftjerc3gx@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, syzbot <bot+e7353c7141ff7cbb718e4c888a14fa92de41ebaa@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, jglisse@redhat.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, shli@fb.com, syzkaller-bugs@googlegroups.com, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kernel-team@lge.com

On Tue, Oct 31, 2017 at 04:25:32PM +0100, Peter Zijlstra wrote:
> But this report only includes a single (cpu-up) part and therefore is

Thanks for fixing me, Peter. I thought '#1 -> #2' and '#2 -> #3', where
#2 is 'cpuhp_state', should have been built with two different classes
of #2 as the latest code. Sorry for confusing Michal.

> not affected by that change other than a lock name changing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
