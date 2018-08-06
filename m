Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 926096B0003
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 15:46:00 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id n21-v6so9126134plp.9
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 12:46:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b59-v6si10810376plc.11.2018.08.06.12.45.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 12:45:58 -0700 (PDT)
Date: Mon, 6 Aug 2018 21:45:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: WARNING in try_charge
Message-ID: <20180806194553.GH10003@dhcp22.suse.cz>
References: <20180806185554.GG10003@dhcp22.suse.cz>
 <0000000000006986c30572c90de3@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000000000006986c30572c90de3@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>
Cc: cgroups@vger.kernel.org, dvyukov@google.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penguin-kernel@I-love.SAKURA.ne.jp, syzkaller-bugs@googlegroups.com, vdavydov.dev@gmail.com

[CCing Greg - the email thread starts here
http://lkml.kernel.org/r/0000000000005e979605729c1564@google.com]

On Mon 06-08-18 12:12:02, syzbot wrote:
> Hello,
> 
> syzbot has tested the proposed patch and the reproducer did not trigger
> crash:

OK, this is reassuring. Btw Greg has pointed out this potential case
http://lkml.kernel.org/r/xr93in62jy8k.fsf@gthelen.svl.corp.google.com
but I simply didn't get what he meant. He was suggesting MMF_OOM_SKIP
but I didn't get why that matters. I didn't think about a race.

So how about this patch:
