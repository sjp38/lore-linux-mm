Received: by wa-out-1112.google.com with SMTP id j37so1070434waf.22
        for <linux-mm@kvack.org>; Sun, 26 Oct 2008 08:51:41 -0700 (PDT)
Message-ID: <2f11576a0810260851h15cb7e1ahb454b70a2e99e1a8@mail.gmail.com>
Date: Mon, 27 Oct 2008 00:51:41 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] lru_add_drain_all() don't use schedule_on_each_cpu()
In-Reply-To: <1225028946.32713.16.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <2f11576a0810210851g6e0d86benef5d801871886dd7@mail.gmail.com>
	 <2f11576a0810211018g5166c1byc182f1194cfdd45d@mail.gmail.com>
	 <20081023235425.9C40.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <1225019176.32713.5.camel@twins>
	 <2f11576a0810260637q21eaec62q4e2662742541e771@mail.gmail.com>
	 <1225028946.32713.16.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Gautham Shenoy <ego@in.ibm.com>, Oleg Nesterov <oleg@tv-sign.ru>, Rusty Russell <rusty@rustcorp.com.au>, mpm <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

>> >> @@ -611,4 +613,8 @@ void __init swap_setup(void)
>> >>  #ifdef CONFIG_HOTPLUG_CPU
>> >>       hotcpu_notifier(cpu_swap_callback, 0);
>> >>  #endif
>> >> +
>> >> +     vm_wq = create_workqueue("vm_work");
>> >> +     BUG_ON(!vm_wq);
>> >> +
>> >>  }
>> >
>> > While I really hate adding yet another per-cpu thread for this, I don't
>> > see another way out atm.
>>
>> Can I ask the reason of your hate?
>> if I don't know it, making improvement patch is very difficult to me.
>
> There seems to be no drive to keep them down, ps -def output it utterly
> dominated by kernel threads on a freshly booted machine with many cpus.

True. but I don't think it is big problem. because

1. people can use grep filter easily.
2. that is just "sense of beauty" issue. not real pain.
3. current ps output is already utterly filled by kernel thread on
large server :)
    the patch doesn't introduce new problem.

> And while they are not _that_ expensive to have around, they are not
> free either, I imagine the tiny-linux folks having an interest in
> keeping these down too.

In my embedded job experience, I don't hear that.
Their folks strongly interest to memory size and cpu usage, but don't
interest # of thread so much.

Yes, too many thread spent many memory by stack. but the patch
introduce only one thread on embedded device.


Perhaps, I misunderstand your intension. so can you point your
previous discussion url?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
