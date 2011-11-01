Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8B66A6B006E
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 08:17:42 -0400 (EDT)
Received: by bkas6 with SMTP id s6so994029bka.14
        for <linux-mm@kvack.org>; Tue, 01 Nov 2011 05:17:24 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 1 Nov 2011 17:47:24 +0530
Message-ID: <CAGr+u+zkPiZpGefstcbJv_cj929icWKXbqFy1uR22Hns1hzFeQ@mail.gmail.com>
Subject: Issue with core dump
From: trisha yad <trisha1march@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, kamezawa.hiroyu@jp.fujitsu.com, oleg@redhat.com, mhocko@suse.cz, rientjes@google.com, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rusty Russell <rusty@rustcorp.com.au>, Tejun Heo <htejun@gmail.com>

Dear all,

I am running a multithreaded  application. So consider a global
variable x which is used by a, b and c thread.

In thread 'a' do abnormal operation(invalid memory access) and kernel
send signal kill to it. In the mean time Thread 'b' and Thread 'c'
got schedule and update
the variable x. when I got the core file, variable x  got updated, and
I am not  getting actual value that is present at time of crash of
thread a.
But In core file I got updated value of x. I want In core file exact
the same memory status as it at time of abnormal operation(invalid
memory access)

Is there any solution for such problem. ?

I want in core dump the same status  of memory as at time of abnormal
operation(invalid memory access).

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
