Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9A46B0038
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 08:14:16 -0500 (EST)
Received: by mail-la0-f45.google.com with SMTP id gd6so23510571lab.4
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 05:14:15 -0800 (PST)
Received: from forward-corp1g.mail.yandex.net (forward-corp1g.mail.yandex.net. [2a02:6b8:0:1402::10])
        by mx.google.com with ESMTPS id c7si3943699lae.46.2015.01.30.05.14.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Jan 2015 05:14:14 -0800 (PST)
From: Roman Gushchin <klamm@yandex-team.ru>
In-Reply-To: <20150129195735.GA9331@scruffy>
References: <1422536763-31325-1-git-send-email-klamm@yandex-team.ru> <20150129195735.GA9331@scruffy>
Subject: Re: [PATCH] mm: fix arithmetic overflow in __vm_enough_memory()
MIME-Version: 1.0
Message-Id: <66011422623650@webcorp02h.yandex-team.ru>
Date: Fri, 30 Jan 2015 16:14:10 +0300
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=koi8-r
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Shewmaker <agshew@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "stable@vger.kernel.org" <stable@vger.kernel.org>

29.01.2015, 22:57, "Andrew Shewmaker" <agshew@gmail.com>:
> On Thu, Jan 29, 2015 at 04:06:03PM +0300, Roman Gushchin wrote:
>> ?I noticed, that "allowed" can easily overflow by falling below 0,
>> ?because (total_vm / 32) can be larger than "allowed". The problem
>> ?occurs in OVERCOMMIT_NONE mode.
>>

> Makes sense to me. Please fix mm/nommu.c also.

Thanks!
I sent a patch for nommu.c.

>
> If a caller passes in a big negative value for pages,
> then vm_acct_memory() would decrement vm_committed_as, possibly
> causing percpu_counter_read_positive(&vm_committed_as) and
> __vm_enough_memory to return 0. Maybe that's okay? Callers
> won't be passing in a negative pages anyway. Is there a reason
> to let them, though?

I think, it isn't a problem, since no one will commit negative values (I hope).

R.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
