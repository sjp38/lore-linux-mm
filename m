Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2A3D86B0003
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 08:51:48 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c1-v6so24617653eds.15
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 05:51:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g13-v6si3661017edp.57.2018.10.22.05.51.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 05:51:46 -0700 (PDT)
Date: Mon, 22 Oct 2018 14:51:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/2] improve vmalloc allocation
Message-ID: <20181022125142.GD18839@dhcp22.suse.cz>
References: <20181019173538.590-1-urezki@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181019173538.590-1-urezki@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Thomas Garnier <thgarnie@google.com>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>

Hi,
I haven't read through the implementation yet but I have say that I
really love this cover letter. It is clear on intetion, it covers design
from high level enough to start discussion and provides a very nice
testing coverage. Nice work!

I also think that we need a better performing vmalloc implementation
long term because of the increasing number of kvmalloc users.

I just have two mostly workflow specific comments.

> A test-suite patch you can find here, it is based on 4.18 kernel.
> ftp://vps418301.ovh.net/incoming/0001-mm-vmalloc-stress-test-suite-v4.18.patch

Can you fit this stress test into the standard self test machinery?

> It is fixed by second commit in this series. Please see more description in
> the commit message of the patch.

Bug fixes should go first and new functionality should be built on top.
A kernel crash sounds serious enough to have a fix marked for stable. If
the fix is too hard/complex then we might consider a revert of the
faulty commit.
> 
> 3) This one is related to PCPU allocator(see pcpu_alloc_test()). In that
> stress test case i see that SUnreclaim(/proc/meminfo) parameter gets increased,
> i.e. there is a memory leek somewhere in percpu allocator. It sounds like
> a memory that is allocated by pcpu_get_vm_areas() sometimes is not freed.
> Resulting in memory leaking or "Kernel panic":
> 
> ---[ end Kernel panic - not syncing: Out of memory and no killable processes...

It would be great to pin point this one down before the rework as well.

Thanks a lot!
-- 
Michal Hocko
SUSE Labs
