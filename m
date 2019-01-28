Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id ADB8B8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 05:51:54 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id bj3so11521377plb.17
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 02:51:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 73sor45444474plf.73.2019.01.28.02.51.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 02:51:53 -0800 (PST)
Date: Mon, 28 Jan 2019 19:51:48 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [linux-next] kcompactd0 stuck in a CPU-burning loop
Message-ID: <20190128105148.GA15887@jagdpanzerIV>
References: <20190128085747.GA14454@jagdpanzerIV>
 <5e98c5e9-9a8a-70db-c991-a5ca9c501e83@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5e98c5e9-9a8a-70db-c991-a5ca9c501e83@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jan Kara <jack@suse.cz>

On (01/28/19 10:18), Vlastimil Babka wrote:
> On 1/28/19 9:57 AM, Sergey Senozhatsky wrote:
> > Hello,
> > 
> > next-20190125
> > 
> > kcompactd0 is spinning on something, burning CPUs in the meantime:
> 
> Hi, could you check/add this to the earlier thread? Thanks.
> 
> https://lore.kernel.org/lkml/20190126200005.GB27513@amd/T/#u

Hi,

Will reply here.
Thanks for  the link, Vlastimil.

Will "test" Jan's patch (don't have a reproducer yet).
So far, I can confirm that

	echo 3 > /proc/sys/vm/drop_caches

mentioned in that thread does "solve" the issue.

	-ss
