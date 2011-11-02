Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8B6B96B0069
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 02:33:42 -0400 (EDT)
Received: by bkas6 with SMTP id s6so2024169bka.14
        for <linux-mm@kvack.org>; Tue, 01 Nov 2011 23:33:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20111101152320.GA30466@redhat.com>
References: <CAGr+u+zkPiZpGefstcbJv_cj929icWKXbqFy1uR22Hns1hzFeQ@mail.gmail.com>
	<20111101152320.GA30466@redhat.com>
Date: Wed, 2 Nov 2011 12:03:39 +0530
Message-ID: <CAGr+u+wgAYVWgdcG6o+6F0mDzuyNzoOxvsFwq0dMsR3JNnZ-cA@mail.gmail.com>
Subject: Re: Issue with core dump
From: trisha yad <trisha1march@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, rientjes@google.com, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rusty Russell <rusty@rustcorp.com.au>, Tejun Heo <htejun@gmail.com>

Thanks all for your answer.

In loaded embedded system the time at with code hit do_user_fault()
and core_dump_wait() is bit
high, I check on my  system it took 2.7 sec. so it is very much
possible that core dump is not correct.
It  contain global value updated.

So is it possible at time of send_signal() we can stop modification of
faulty thread memory ?


Thanks



On Tue, Nov 1, 2011 at 8:53 PM, Oleg Nesterov <oleg@redhat.com> wrote:
> On 11/01, trisha yad wrote:
>>
>> Dear all,
>>
>> I am running a multithreaded =A0application. So consider a global
>> variable x which is used by a, b and c thread.
>>
>> In thread 'a' do abnormal operation(invalid memory access) and kernel
>> send signal kill to it. In the mean time Thread 'b' and Thread 'c'
>> got schedule and update
>> the variable x. when I got the core file, variable x =A0got updated, and
>> I am not =A0getting actual value that is present at time of crash of
>> thread a.
>> But In core file I got updated value of x. I want In core file exact
>> the same memory status as it at time of abnormal operation(invalid
>> memory access)
>
> Yes, this is possible.
>
>> Is there any solution for such problem. ?
>>
>> I want in core dump the same status =A0of memory as at time of abnormal
>> operation(invalid memory access).
>
> I don't think we can "fix" this.
>
> We can probably change complete_signal() to notify other threads
> "immediately", but this is not simple and obviously can not close
> the window completely.
>
> Whatever we do, we can't "stop" other threads at the time when
> thread 'a' traps. All we can do is to try to shrink the window.
>
> Oleg.
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
