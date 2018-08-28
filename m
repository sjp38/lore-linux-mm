Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 46C566B486A
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 18:29:33 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id e3-v6so2647764qkj.17
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 15:29:33 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id j49-v6si2148423qtf.239.2018.08.28.15.29.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 15:29:32 -0700 (PDT)
Subject: Re: [PATCH 2/2] fs/dcache: Make negative dentries easier to be
 reclaimed
References: <1535476780-5773-1-git-send-email-longman@redhat.com>
 <1535476780-5773-3-git-send-email-longman@redhat.com>
 <20180828221352.GC11400@bombadil.infradead.org>
From: Waiman Long <longman@redhat.com>
Message-ID: <6873378b-3202-e738-2366-5fb818b4a013@redhat.com>
Date: Tue, 28 Aug 2018 18:29:29 -0400
MIME-Version: 1.0
In-Reply-To: <20180828221352.GC11400@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>

On 08/28/2018 06:13 PM, Matthew Wilcox wrote:
> On Tue, Aug 28, 2018 at 01:19:40PM -0400, Waiman Long wrote:
>> @@ -134,7 +135,7 @@ bool list_lru_add(struct list_lru *lru, struct list_head *item)
>>  	spin_lock(&nlru->lock);
>>  	if (list_empty(item)) {
>>  		l = list_lru_from_kmem(nlru, item, &memcg);
>> -		list_add_tail(item, &l->list);
>> +		(add_tail ? list_add_tail : list_add)(item, &l->list);
>>  		/* Set shrinker bit if the first element was added */
>>  		if (!l->nr_items++)
>>  			memcg_set_shrinker_bit(memcg, nid,
> That's not OK.  Write it out properly, ie:
>
> 		if (add_tail)
> 			list_add_tail(item, &l->list);
> 		else
> 			list_add(item, &l->list);
>
Yes, I can rewrite it. What is the problem with the abbreviated form?

Cheers,
Longman
