Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 99AEB6B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 13:51:09 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d17so1835762eek.1
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 10:51:08 -0700 (PDT)
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
        by mx.google.com with ESMTPS id u5si41276026een.173.2014.04.18.10.51.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 10:51:08 -0700 (PDT)
Received: by mail-ee0-f42.google.com with SMTP id d17so1835746eek.1
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 10:51:07 -0700 (PDT)
Message-ID: <53516608.8090409@colorfullife.com>
Date: Fri, 18 Apr 2014 19:51:04 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] ipc,shm: disable shmmax and shmall by default
References: <1397784345.2556.26.camel@buesod1.americas.hpqcorp.net> <5350EFAA.2030607@colorfullife.com> <CAKgNAkhY94Y5Nut9+Jj1gcnio81CEmE5sQL_gH_zFnHD-yNx2Q@mail.gmail.com>
In-Reply-To: <CAKgNAkhY94Y5Nut9+Jj1gcnio81CEmE5sQL_gH_zFnHD-yNx2Q@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mtk.manpages@gmail.com
Cc: Davidlohr Bueso <davidlohr@hp.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, aswin@hp.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>

On 04/18/2014 05:36 PM, Michael Kerrisk (man-pages) wrote:
> On Fri, Apr 18, 2014 at 11:26 AM, Manfred Spraul
> <manfred@colorfullife.com> wrote:
>> Obviously my patch has the opposite problem: 64-bit wrap-arounds.
> I know you alluded to a case in another thread, but I couldn't quite
> work out from the mail you referred to whether this was really the
> problem. (And I assume those folks were forced to fix their set-up
> scripts anyway.) So, it's not clear to me whether this is a real
> problem. (And your patch does not worsen things from the current
> situation, right?)
a) When I wrote the comment it was just an idea.
But now I think wrap-around could be an issue, e.g. 
find_vma_intersection(,addr,addr+ULONG_MAX) always returns false, even 
if there are vmas inbetween.

b) If we make ULONG_MAX the default, then it should work.

--
     Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
