Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8C1A46B0035
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 12:50:26 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so931454pdj.8
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 09:50:26 -0700 (PDT)
Received: from sabertooth01.qualcomm.com (sabertooth01.qualcomm.com. [65.197.215.72])
        by mx.google.com with ESMTPS id ic8si941726pad.300.2014.04.23.09.50.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 23 Apr 2014 09:50:25 -0700 (PDT)
Message-ID: <5357EF4D.6080302@qti.qualcomm.com>
Date: Wed, 23 Apr 2014 09:50:21 -0700
From: Max Krasnyansky <maxk@qti.qualcomm.com>
MIME-Version: 1.0
Subject: Re: vmstat: On demand vmstat workers V3
References: <000001417f6834f1-32b83f22-8bde-4b9e-b591-bc31329660e4-000000@email.amazonses.com> <CAOh2x==yrBdFDcObdz+La0y=jDERj=sxOBMvU-Kk6eGEvvwZQw@mail.gmail.com>
In-Reply-To: <CAOh2x==yrBdFDcObdz+La0y=jDERj=sxOBMvU-Kk6eGEvvwZQw@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viresh Kumar <viresh.kumar@linaro.org>, Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qti.qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hi Viresh,

On 04/22/2014 03:32 AM, Viresh Kumar wrote:
> On Thu, Oct 3, 2013 at 11:10 PM, Christoph Lameter <cl@linux.com> wrote:
>> V2->V3:
>> - Introduce a new tick_get_housekeeping_cpu() function. Not sure
>>   if that is exactly what we want but it is a start. Thomas?
>> - Migrate the shepherd task if the output of
>>   tick_get_housekeeping_cpu() changes.
>> - Fixes recommended by Andrew.
> 
> Hi Christoph,
> 
> This vmstat interrupt is disturbing my core isolation :), have you got
> any far with this patchset?

You don't mean an interrupt, right?
The updates are done via the regular priority workqueue.

I'm playing with isolation as well (has been more or less a background thing
for the last 6+ years). Our threads that run on the isolated cores are SCHED_FIFO
and therefor low prio workqueue stuff, like vmstat, doesn't get in the way.
I do have a few patches for the workqueues to make things better for isolation.

Max

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
