Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id EC2846B0003
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 08:20:34 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w71-v6so718692oia.20
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 05:20:34 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 98-v6si464166otv.398.2018.03.20.05.20.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 05:20:32 -0700 (PDT)
Subject: Re: KVM hang after OOM
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <178719aa-b669-c443-bf87-5728b71557c0@i-love.sakura.ne.jp>
	<CABXGCsNecgRN7mn4OxZY2rqa2N4kVBw3f0s6XEvLob4uy3LOug@mail.gmail.com>
	<201803171213.BFF21361.OOSFVFHLJQOtFM@I-love.SAKURA.ne.jp>
	<CABXGCsN8mN7bGNDx9Tb2sewuXWp6DbcyKpMFv0UzGATAMELxqA@mail.gmail.com>
	<20180320065339.GA23100@dhcp22.suse.cz>
In-Reply-To: <20180320065339.GA23100@dhcp22.suse.cz>
Message-Id: <201803202120.FDI17671.VQMLOFJFOStHFO@I-love.SAKURA.ne.jp>
Date: Tue, 20 Mar 2018 21:20:30 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, mikhail.v.gavrilov@gmail.com
Cc: linux-mm@kvack.org, kvm@vger.kernel.org, kirill@shutemov.name

Michal Hocko wrote:
> On Mon 19-03-18 21:23:12, Mikhail Gavrilov wrote:
> > using swap actively.
> > But I'm already satisfied with proposed patch.
> > 
> > I am attached dmesg when I triggering OOM three times. And every time
> > after it system survived.
> > I think this patch should be merged in mainline.
> 
> Could you be more specific what is _this_ patch, please?

I think it is
"[PATCH] mm/thp: Do not wait for lock_page() in deferred_split_scan()".

Unless the problem is something like commit 0b1d647a02c5a1b6
("[PATCH] dm: work around mempool_alloc, bio_alloc_bioset deadlocks"),
there should be no need to use io_schedule_timeout().

Mikhail, can you test with only
"[PATCH] mm/thp: Do not wait for lock_page() in deferred_split_scan()" and
"[PATCHv2] mm/shmem: Do not wait for lock_page() in shmem_unused_huge_shrink()"
applied? Because the last dmesg.txt was using io_schedule_timeout()...
