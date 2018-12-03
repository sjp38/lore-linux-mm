Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0E4496B698D
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 09:35:33 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id t18so13624003qtj.3
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 06:35:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r129sor6948763qke.130.2018.12.03.06.35.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Dec 2018 06:35:31 -0800 (PST)
Subject: Re: [PATCH v2] mm: prototype: rid swapoff of quadratic complexity
From: Vineeth Remanan Pillai <vpillai@digitalocean.com>
References: <20181126165521.19777-1-vpillai@digitalocean.com>
 <20181126172255.GK3065@bombadil.infradead.org>
 <21acdf55-dbcb-1c8f-4783-9bb496dcbca3@digitalocean.com>
Message-ID: <8ec7fc5f-3c14-5faa-541e-45f5b980a98d@digitalocean.com>
Date: Mon, 3 Dec 2018 09:35:24 -0500
MIME-Version: 1.0
In-Reply-To: <21acdf55-dbcb-1c8f-4783-9bb496dcbca3@digitalocean.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kelley Nielsen <kelleynnn@gmail.com>, Rik van Riel <riel@surriel.com>

Hi Matthew,


>> This seems terribly complicated.  You run through i_pages, record the
>> indices of the swap entries, then go back and look them up again by
>> calling shmem_getpage() which calls the incredibly complex 300 line
>> shmem_getpage_gfp().
>>
>> Can we refactor shmem_getpage_gfp() to skip some of the checks which
>> aren't necessary when called from this path, and turn this into a nice
>> simple xas_for_each() loop which works one entry at a time?
>
> I shall investigate this and make this simpler as you suggested.

I have looked into this deeper. I think it would be very difficult to 
consolidate the whole logic into a single xas_for_each() loop because, 
we do disk io and might sleep. I have refactored the code such that it 
much more readable now and I am using the same format used by 
find_get_entries.

Will send out the next revision later today.


Thanks,

Vineeth
