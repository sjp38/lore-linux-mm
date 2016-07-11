Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 521826B0005
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 14:33:22 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id o80so32008997wme.1
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 11:33:22 -0700 (PDT)
Received: from mail-lf0-x22f.google.com (mail-lf0-x22f.google.com. [2a00:1450:4010:c07::22f])
        by mx.google.com with ESMTPS id n83si1523637lfd.198.2016.07.11.11.33.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jul 2016 11:33:20 -0700 (PDT)
Received: by mail-lf0-x22f.google.com with SMTP id q132so79846083lfe.3
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 11:33:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CABAubThHfngHTQW_AEuW71VCvLyD_9b5Z05tSud5bf8JKjuA9Q@mail.gmail.com>
References: <CABAubThf6gbi243BqYgoCjqRW36sXJuJ6e_8zAqzkYRiu0GVtQ@mail.gmail.com>
 <20160711064150.GB5284@dhcp22.suse.cz> <CABAubThHfngHTQW_AEuW71VCvLyD_9b5Z05tSud5bf8JKjuA9Q@mail.gmail.com>
From: Shayan Pooya <shayan@liveve.org>
Date: Mon, 11 Jul 2016 11:33:19 -0700
Message-ID: <CABAubTjGhUXMeAnFgW8LGck1tgvtu12Zb9fx5BRhDWNjZ7SYLQ@mail.gmail.com>
Subject: Re: bug in memcg oom-killer results in a hung syscall in another
 process in the same cgroup
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: cgroups mailinglist <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

>> Could you post the stack trace of the hung oom victim? Also could you
>> post the full kernel log?

With strace, when running 500 concurrent mem-hog tasks on the same
kernel, 33 of them failed with:

strace: ../sysdeps/nptl/fork.c:136: __libc_fork: Assertion
`THREAD_GETMEM (self, tid) != ppid' failed.

Which is: https://sourceware.org/bugzilla/show_bug.cgi?id=15392
And discussed before at: https://lkml.org/lkml/2015/2/6/470 but that
patch was not accepted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
