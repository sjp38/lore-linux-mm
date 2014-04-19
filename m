Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id 451C66B0031
	for <linux-mm@kvack.org>; Sat, 19 Apr 2014 05:15:10 -0400 (EDT)
Received: by mail-ee0-f52.google.com with SMTP id e49so2184950eek.25
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 02:15:09 -0700 (PDT)
Received: from mail-ee0-x229.google.com (mail-ee0-x229.google.com [2a00:1450:4013:c00::229])
        by mx.google.com with ESMTPS id 43si43973193eei.295.2014.04.19.02.15.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 19 Apr 2014 02:15:08 -0700 (PDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so2261013eei.28
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 02:15:08 -0700 (PDT)
Message-ID: <53523E93.4060702@gmail.com>
Date: Sat, 19 Apr 2014 11:14:59 +0200
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] ipc/shm: Increase the defaults for SHMALL, SHMMAX to
 infinity
References: <1397812720-5629-1-git-send-email-manfred@colorfullife.com> <1397890512.19331.21.camel@buesod1.americas.hpqcorp.net> <CAKgNAkgMrWhSky8Cys2gxiS_s0=ya=wi=R5ehuT0bdjEBpDgdg@mail.gmail.com> <535237AA.7080000@colorfullife.com>
In-Reply-To: <535237AA.7080000@colorfullife.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>, Davidlohr Bueso <davidlohr@hp.com>
Cc: mtk.manpages@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <davidlohr.bueso@hp.com>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, aswin@hp.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 04/19/2014 10:45 AM, Manfred Spraul wrote:
> On 04/19/2014 09:10 AM, Michael Kerrisk (man-pages) wrote:
>> On Sat, Apr 19, 2014 at 8:55 AM, Davidlohr Bueso <davidlohr@hp.com> wrote:
>>> On Fri, 2014-04-18 at 11:18 +0200, Manfred Spraul wrote:
>>>> Risks:
>>>> - The patch breaks installations that use "take current value and increase
>>>>    it a bit". [seems to exist, http://marc.info/?l=linux-mm&m=139638334330127]
>>> This really scares me. The probability of occurrence is now much higher,
>>> and not just theoretical. It would legitimately break userspace.
>> I'm missing something. Manfred's patch doesn't actually change the
>> behavior on this point does it? If the problem is more than
>> theoretical, then it _already_ affects users, right? (And they would
>> therefore already be working around the problem.)
> The current default is 32 MB. if some increases it by 1 MB, then the 
> result is 33 MB.
> The new default would be ULONG_MAX. If someone increases it by 1 MB, 
> then the result is 1 MB - 1 byte.

Ahh. Got it now--sorry for being slow.


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
