Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id AF7FA6B0003
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 05:32:31 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c26-v6so24054047eda.7
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 02:32:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s27-v6si4296770edm.206.2018.10.22.02.32.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 02:32:30 -0700 (PDT)
Date: Mon, 22 Oct 2018 11:32:26 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Message-ID: <20181022093226.nn5h7ohuzcyeezyt@pathway.suse.cz>
References: <CAJmjG2-RrG5XKeW1-+rN3C=F6bZ-L3=YKhCiQ_muENDTzm_Ofg@mail.gmail.com>
 <20181002212327.7aab0b79@vmware.local.home>
 <20181003091400.rgdjpjeaoinnrysx@pathway.suse.cz>
 <CAJmjG2_4JFA=qL-d2Pb9umUEcPt9h13w-g40JQMbdKsZTRSZww@mail.gmail.com>
 <20181003133704.43a58cf5@gandalf.local.home>
 <CAJmjG291w2ZPRiAevSzxGNcuR6vTuqyk6z4SG3xRsbaQh5U3zQ@mail.gmail.com>
 <20181004074442.GA12879@jagdpanzerIV>
 <20181004083609.kcziz2ynwi2w7lcm@pathway.suse.cz>
 <20181004085515.GC12879@jagdpanzerIV>
 <CAJmjG2-e6f6p=pE5uDECMc=W=81SYyGCmoabrC1ePXwL5DFdSw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJmjG2-e6f6p=pE5uDECMc=W=81SYyGCmoabrC1ePXwL5DFdSw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Wang <wonderfly@google.com>
Cc: sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, stable@vger.kernel.org, Alexander.Levin@microsoft.com, akpm@linux-foundation.org, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Mel Gorman <mgorman@suse.de>, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@i-love.sakura.ne.jp, peterz@infradead.org, tj@kernel.org, torvalds@linux-foundation.org, vbabka@suse.cz, Cong Wang <xiyou.wangcong@gmail.com>, Peter Feiner <pfeiner@google.com>

On Sun 2018-10-21 11:09:22, Daniel Wang wrote:
> Just got back from vacation. Thanks for the continued discussion. Just so
> I understand the current state. Looks like we've got a pretty good explanation
> of what's going on (though not completely sure), and backporting Steven's
> patches is still the way to go? I see that Sergey had sent an RFC series
> for similar things. Are those trying to solve the deadlock problem in a
> different way?On Thu, Oct 4, 2018 at 1:55 AM Sergey Senozhatsky

I suggest to go with backporting Steven's patchset. We do not have
anything better at the moment.

Best Regards,
Petr
