Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id 22DC26B0031
	for <linux-mm@kvack.org>; Sat, 19 Apr 2014 05:18:02 -0400 (EDT)
Received: by mail-ee0-f51.google.com with SMTP id c13so2242968eek.38
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 02:18:01 -0700 (PDT)
Received: from mail-ee0-x22b.google.com (mail-ee0-x22b.google.com [2a00:1450:4013:c00::22b])
        by mx.google.com with ESMTPS id 43si44011799eei.205.2014.04.19.02.18.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 19 Apr 2014 02:18:00 -0700 (PDT)
Received: by mail-ee0-f43.google.com with SMTP id e53so2217313eek.16
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 02:18:00 -0700 (PDT)
Message-ID: <53523F41.2080601@gmail.com>
Date: Sat, 19 Apr 2014 11:17:53 +0200
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] ipc/shm: Increase the defaults for SHMALL, SHMMAX to
 infinity
References: <1397812720-5629-1-git-send-email-manfred@colorfullife.com> <1397890512.19331.21.camel@buesod1.americas.hpqcorp.net> <535235DE.5080304@colorfullife.com>
In-Reply-To: <535235DE.5080304@colorfullife.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>, Davidlohr Bueso <davidlohr@hp.com>
Cc: mtk.manpages@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <davidlohr.bueso@hp.com>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, gthelen@google.com, aswin@hp.com, linux-mm@kvack.org

On 04/19/2014 10:37 AM, Manfred Spraul wrote:
> On 04/19/2014 08:55 AM, Davidlohr Bueso wrote:
>> On Fri, 2014-04-18 at 11:18 +0200, Manfred Spraul wrote:
>>> - ULONG_MAX is not really infinity, but 18 Exabyte segment size and
>>>    75 Zettabyte total size. This should be enough for the next few weeks.
>>>    (assuming a 64-bit system with 4k pages)
> Note: I found three integer overflows, none of them critical.
> I will send patches, I just must get a 32-bit test setup first.
>>> Risks:
>>> - The patch breaks installations that use "take current value and increase
>>>    it a bit". [seems to exist, http://marc.info/?l=linux-mm&m=139638334330127]
>> This really scares me. The probability of occurrence is now much higher,
>> and not just theoretical. It would legitimately break userspace.
> That's why I mentioned it.
> For shmmax, there is a simple answer: Use TASK_SIZE instead of ULONG_MAX.
> - sufficiently far away from overflow.
> - values beyond TASK_SIZE are useless anyway, you can't map such segments.
> 
> I don't have a good answer for shmall. 1L<<(BITS_PER_LONG-1) is too ugly.
> Any proposals?

If shmmax is TASK_SIZE, would not the existing
#define SHMALL (SHMMAX/getpagesize()*(SHMMNI/16))
suffice?


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
