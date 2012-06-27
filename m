Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 090BD6B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 07:42:52 -0400 (EDT)
Received: by ggm4 with SMTP id 4so959186ggm.14
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 04:42:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120626163147.93181e21.akpm@linux-foundation.org>
References: <1340463502-15341-1-git-send-email-akinobu.mita@gmail.com>
	<1340463502-15341-7-git-send-email-akinobu.mita@gmail.com>
	<20120626163147.93181e21.akpm@linux-foundation.org>
Date: Wed, 27 Jun 2012 20:42:51 +0900
Message-ID: <CAC5umygD5b3w1Fc6h5__cH-G6zrALZ4Ucvn-vazn+8yLXDw0JQ@mail.gmail.com>
Subject: Re: [PATCH -v4 6/6] fault-injection: add notifier error injection
 testing scripts
From: Akinobu Mita <akinobu.mita@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Pavel Machek <pavel@ucw.cz>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-pm@lists.linux-foundation.org, Greg KH <greg@kroah.com>, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, =?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>

2012/6/27 Andrew Morton <akpm@linux-foundation.org>:
> On Sat, 23 Jun 2012 23:58:22 +0900
> Akinobu Mita <akinobu.mita@gmail.com> wrote:
>
>> This adds two testing scripts with notifier error injection
>
> Can we move these into tools/testing/selftests/, so that a "make
> run_tests" runs these tests?
>
> Also, I don't think it's appropriate that "fault-injection" be in the
> path - that's an implementation detail. =A0What we're testing here is
> memory hotplug, pm, cpu hotplug, etc. =A0So each test would go into, say,
> tools/testing/selftests/cpu-hotplug.
>
> Now, your cpu-hotplug test only tests a tiny part of the cpu-hotplug
> code. =A0But it is a start, and creates the place where additional tests
> will be placed in the future.
>
>
> If the kernel configuration means that the tests cannot be run, the
> attempt should succeed so that other tests are not disrupted. =A0I guess
> that printing a warning in this case is useful.
>
> Probably the selftests will require root permissions - we haven't
> really thought about that much. =A0If these tests require root (I assume
> they do?) then a sensible approach would be to check for that and to
> emit a warning and return "success".

Thanks for your advice.

I'm going to make the following changes on these scripts

1. Change these paths to:
tools/testing/selftests/{cpu,memory}-hotplug/on-off-test.sh

2. Skip tests and exit(0) with a warning if no root or no sysfs
so that a "make run_tests" doesn't stop.

3. Add tests that simply online and offline cpus (or memory blocks)
and then tests with this notifier error injection features if the
kernel supports.

> My overall take on the fault-injection code is that there has been a
> disappointing amount of uptake: I don't see many developers using them
> for whitebox testing their stuff. =A0I guess this patchset addresses
> that, in a way.

I hope so. the impact of notifier error injection is restricted to
the particular kernel functionarity and these scripts are easy to run.

On the other hand, fault injection like failslab has a huge impact
on any kernel components and it often results catastrophe to userspace
even if no kernel bug.  I am confident that I can find a certain amount
of kernel bugs with failslab but it requires enough spare time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
