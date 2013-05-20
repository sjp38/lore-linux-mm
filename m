Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id BB7736B0002
	for <linux-mm@kvack.org>; Mon, 20 May 2013 05:42:11 -0400 (EDT)
Received: by mail-lb0-f174.google.com with SMTP id u10so4292125lbi.33
        for <linux-mm@kvack.org>; Mon, 20 May 2013 02:42:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130509225833.C37A55A41D4@corp2gmr1-2.hot.corp.google.com>
References: <20130509225833.C37A55A41D4@corp2gmr1-2.hot.corp.google.com>
Date: Mon, 20 May 2013 11:42:09 +0200
Message-ID: <CAFTL4hwvP7GsrNTc4knQRMV1YHXnZRes=E_NpLAKSOgqTeou5g@mail.gmail.com>
Subject: Re: mmotm 2013-05-09-15-57 uploaded
From: Frederic Weisbecker <fweisbec@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

Hi Andrew,

2013/5/10  <akpm@linux-foundation.org>:
[...]
> * posix_cpu_timer-consolidate-expiry-time-type.patch
> * posix_cpu_timers-consolidate-timer-list-cleanups.patch
> * posix_cpu_timers-consolidate-expired-timers-check.patch
> * selftests-add-basic-posix-timers-selftests.patch
> * posix-timers-correctly-get-dying-task-time-sample-in-posix_cpu_timer_schedule.patch
> * posix_timers-fix-racy-timer-delta-caching-on-task-exit.patch

Do you have any plans concerning these patches? These seem to have
missed this merge window.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
