Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 851FF6B0269
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 03:17:04 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id l89so4900826lfi.3
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 00:17:04 -0700 (PDT)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id n5si3536006wja.24.2016.07.12.00.17.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 00:17:03 -0700 (PDT)
Received: by mail-wm0-f46.google.com with SMTP id f65so89466693wmi.0
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 00:17:03 -0700 (PDT)
Date: Tue, 12 Jul 2016 09:17:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: bug in memcg oom-killer results in a hung syscall in another
 process in the same cgroup
Message-ID: <20160712071701.GC14586@dhcp22.suse.cz>
References: <CABAubThf6gbi243BqYgoCjqRW36sXJuJ6e_8zAqzkYRiu0GVtQ@mail.gmail.com>
 <20160711064150.GB5284@dhcp22.suse.cz>
 <CABAubThHfngHTQW_AEuW71VCvLyD_9b5Z05tSud5bf8JKjuA9Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABAubThHfngHTQW_AEuW71VCvLyD_9b5Z05tSud5bf8JKjuA9Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shayan Pooya <shayan@liveve.org>
Cc: cgroups mailinglist <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon 11-07-16 10:40:55, Shayan Pooya wrote:
> >
> > Could you post the stack trace of the hung oom victim? Also could you
> > post the full kernel log?
> 
> Here is the stack of the process that lives (it is *not* the
> oom-victim) in a run with 100 processes and *without* strace:
> 
> # cat /proc/7688/stack
> [<ffffffff81100292>] futex_wait_queue_me+0xc2/0x120
> [<ffffffff811005a6>] futex_wait+0x116/0x280
> [<ffffffff81102d90>] do_futex+0x120/0x540
> [<ffffffff81103231>] SyS_futex+0x81/0x180
> [<ffffffff81825bf2>] entry_SYSCALL_64_fastpath+0x16/0x71
> [<ffffffffffffffff>] 0xffffffffffffffff

I am not sure I understand. Is this the hung task?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
