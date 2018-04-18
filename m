Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 143A36B0007
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 14:19:14 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id n4so1018103pgn.9
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 11:19:14 -0700 (PDT)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id v14si1537875pfm.198.2018.04.18.11.19.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 11:19:12 -0700 (PDT)
Subject: Re: [v4 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
References: <1523730291-109696-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180418080555.GR17484@dhcp22.suse.cz> <20180418090217.GG19578@uranus.lan>
 <20180418090314.GU17484@dhcp22.suse.cz> <20180418094019.GH19578@uranus.lan>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <2712b594-91b6-24be-e88f-012c8f844f27@linux.alibaba.com>
Date: Wed, 18 Apr 2018 11:18:51 -0700
MIME-Version: 1.0
In-Reply-To: <20180418094019.GH19578@uranus.lan>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, Michal Hocko <mhocko@kernel.org>
Cc: adobriyan@gmail.com, willy@infradead.org, mguzik@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 4/18/18 2:40 AM, Cyrill Gorcunov wrote:
> On Wed, Apr 18, 2018 at 11:03:14AM +0200, Michal Hocko wrote:
>>>> What about something like the following?
>>>> "
>>>> arg_lock protects concurent updates but we still need mmap_sem for read
>>>> to exclude races with do_brk.
>>>> "
>>>> Acked-by: Michal Hocko <mhocko@suse.com>
>>> Yes, thanks! Andrew, could you slightly update the changelog please?
>> No, I meant it to be a comment in the _code_.
> Ah, I see. Then small patch on top should do the trick.

Will send out an incremental patch soon.
