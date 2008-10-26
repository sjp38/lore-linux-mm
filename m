Received: by rv-out-0708.google.com with SMTP id f25so1447861rvb.26
        for <linux-mm@kvack.org>; Sun, 26 Oct 2008 06:37:50 -0700 (PDT)
Message-ID: <2f11576a0810260637q21eaec62q4e2662742541e771@mail.gmail.com>
Date: Sun, 26 Oct 2008 22:37:50 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] lru_add_drain_all() don't use schedule_on_each_cpu()
In-Reply-To: <1225019176.32713.5.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <2f11576a0810210851g6e0d86benef5d801871886dd7@mail.gmail.com>
	 <2f11576a0810211018g5166c1byc182f1194cfdd45d@mail.gmail.com>
	 <20081023235425.9C40.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <1225019176.32713.5.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Gautham Shenoy <ego@in.ibm.com>, Oleg Nesterov <oleg@tv-sign.ru>, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

Hi Peter,

>> @@ -611,4 +613,8 @@ void __init swap_setup(void)
>>  #ifdef CONFIG_HOTPLUG_CPU
>>       hotcpu_notifier(cpu_swap_callback, 0);
>>  #endif
>> +
>> +     vm_wq = create_workqueue("vm_work");
>> +     BUG_ON(!vm_wq);
>> +
>>  }
>
> While I really hate adding yet another per-cpu thread for this, I don't
> see another way out atm.

Can I ask the reason of your hate?
if I don't know it, making improvement patch is very difficult to me.


> Oleg, Rusty, ego, you lot were discussing a similar extra per-cpu
> workqueue, can we merge these two?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
