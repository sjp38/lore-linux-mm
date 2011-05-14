Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E4FA66B0025
	for <linux-mm@kvack.org>; Sat, 14 May 2011 07:12:32 -0400 (EDT)
Received: by wyf19 with SMTP id 19so3309295wyf.14
        for <linux-mm@kvack.org>; Sat, 14 May 2011 04:12:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1305311276.2680.34.camel@work-vm>
References: <1305241371-25276-1-git-send-email-john.stultz@linaro.org>
 <1305241371-25276-2-git-send-email-john.stultz@linaro.org>
 <4DCD1256.4070808@jp.fujitsu.com> <1305311276.2680.34.camel@work-vm>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Sat, 14 May 2011 20:12:10 +0900
Message-ID: <BANLkTin_MitzRUkWToj055AuAPdMC9msXQ@mail.gmail.com>
Subject: Re: [PATCH 1/3] comm: Introduce comm_lock seqlock to protect
 task->comm access
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Ted Ts'o <tytso@mit.edu>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

>> Can you please explain why we should use seqlock? That said,
>> we didn't use seqlock for /proc items. because, plenty seqlock
>> write may makes readers busy wait. Then, if we don't have another
>> protection, we give the local DoS attack way to attackers.
>
> So you're saying that heavy write contention can cause reader
> starvation?

Yes.

>> task->comm is used for very fundamentally. then, I doubt we can
>> assume write is enough rare. Why can't we use normal spinlock?
>
> I think writes are likely to be fairly rare. Tasks can only name
> themselves or sibling threads, so I'm not sure I see the risk here.

reader starvation may cause another task's starvation if reader have
an another lock.
And, "only sibling" don't make any security gurantee as I said past.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
