Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id A119F6B02A8
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 01:06:52 -0400 (EDT)
Received: by lbbyj8 with SMTP id yj8so55180215lbb.0
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 22:06:51 -0700 (PDT)
Received: from mail-la0-x232.google.com (mail-la0-x232.google.com. [2a00:1450:4010:c03::232])
        by mx.google.com with ESMTPS id n4si8876242lbc.63.2015.07.16.22.06.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jul 2015 22:06:50 -0700 (PDT)
Received: by lagw2 with SMTP id w2so54962917lag.3
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 22:06:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150716175139.GB2561@suse.de>
References: <20150714000910.GA8160@wfg-t540p.sh.intel.com>
	<20150714103108.GA6812@suse.de>
	<CALYGNiMUXMvvvi-+64Nd6Qb8Db2EiGZ26jbP8yotUHWS4uF1jg@mail.gmail.com>
	<20150716175139.GB2561@suse.de>
Date: Fri, 17 Jul 2015 08:06:49 +0300
Message-ID: <CALYGNiMMeyW7GXHpdAONn4CckE5Q4cn64wwekZfk18q_W7xMsQ@mail.gmail.com>
Subject: Re: [mminit] [ INFO: possible recursive locking detected ]
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Nicolai Stange <nicstange@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>

On Thu, Jul 16, 2015 at 8:51 PM, Mel Gorman <mgorman@suse.de> wrote:
> On Thu, Jul 16, 2015 at 08:13:38PM +0300, Konstantin Khlebnikov wrote:
>> > @@ -1187,14 +1195,14 @@ void __init page_alloc_init_late(void)
>> >  {pgdat_init_rwsempgdat_init_rwsempgdat_init_rwsem
>> >         int nid;
>> >
>> > +       /* There will be num_node_state(N_MEMORY) threads */
>> > +       atomic_set(&pgdat_init_n_undone, num_node_state(N_MEMORY));
>> >         for_each_node_state(nid, N_MEMORY) {
>> > -               down_read(&pgdat_init_rwsem);
>>
>> Rw-sem have special "non-owner" mode for keeping lockdep away.
>> This should be enough:
>>
>
> I think in this case that the completions look nicer though so I think
> I'll keep them.

Ok. Not a big deal, they are anyway in init sections.

BTW there's another option: wait_on_atomic_t / wake_up_atomic_t
like wait_on_bit but atomic_t

>
> --
> Mel Gorman
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
