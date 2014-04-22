Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f179.google.com (mail-ve0-f179.google.com [209.85.128.179])
	by kanga.kvack.org (Postfix) with ESMTP id 431D66B0035
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 06:32:53 -0400 (EDT)
Received: by mail-ve0-f179.google.com with SMTP id db12so9172212veb.38
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 03:32:53 -0700 (PDT)
Received: from mail-ve0-x236.google.com (mail-ve0-x236.google.com [2607:f8b0:400c:c01::236])
        by mx.google.com with ESMTPS id i19si908965vco.55.2014.04.22.03.32.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 03:32:52 -0700 (PDT)
Received: by mail-ve0-f182.google.com with SMTP id jw12so9484166veb.13
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 03:32:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <000001417f6834f1-32b83f22-8bde-4b9e-b591-bc31329660e4-000000@email.amazonses.com>
References: <000001417f6834f1-32b83f22-8bde-4b9e-b591-bc31329660e4-000000@email.amazonses.com>
Date: Tue, 22 Apr 2014 16:02:52 +0530
Message-ID: <CAOh2x==yrBdFDcObdz+La0y=jDERj=sxOBMvU-Kk6eGEvvwZQw@mail.gmail.com>
Subject: Re: vmstat: On demand vmstat workers V3
From: Viresh Kumar <viresh.kumar@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu, Oct 3, 2013 at 11:10 PM, Christoph Lameter <cl@linux.com> wrote:
> V2->V3:
> - Introduce a new tick_get_housekeeping_cpu() function. Not sure
>   if that is exactly what we want but it is a start. Thomas?
> - Migrate the shepherd task if the output of
>   tick_get_housekeeping_cpu() changes.
> - Fixes recommended by Andrew.

Hi Christoph,

This vmstat interrupt is disturbing my core isolation :), have you got
any far with this patchset?

--
viresh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
