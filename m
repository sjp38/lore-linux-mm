Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9638E6B0286
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 11:26:49 -0400 (EDT)
Received: by mail-lb0-f174.google.com with SMTP id qe11so165906616lbc.3
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 08:26:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 1si13939723wmr.14.2016.04.04.08.26.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Apr 2016 08:26:48 -0700 (PDT)
Subject: Re: [PATCH 0/3] mm/mmap.c: don't unmap the overlapping VMA(s)
References: <1459624654-7955-1-git-send-email-kwapulinski.piotr@gmail.com>
 <20160404073100.GA10272@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <570287B3.6050903@suse.cz>
Date: Mon, 4 Apr 2016 17:26:43 +0200
MIME-Version: 1.0
In-Reply-To: <20160404073100.GA10272@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Cc: akpm@linux-foundation.org, mtk.manpages@gmail.com, cmetcalf@mellanox.com, arnd@arndb.de, viro@zeniv.linux.org.uk, mszeredi@suse.cz, dave@stgolabs.net, kirill.shutemov@linux.intel.com, mingo@kernel.org, dan.j.williams@intel.com, dave.hansen@linux.intel.com, koct9i@gmail.com, hannes@cmpxchg.org, jack@suse.cz, xiexiuqi@huawei.com, iamjoonsoo.kim@lge.com, oleg@redhat.com, gang.chen.5i5j@gmail.com, aarcange@redhat.com, aryabinin@virtuozzo.com, rientjes@google.com, denc716@gmail.com, toshi.kani@hpe.com, ldufour@linux.vnet.ibm.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

On 04/04/2016 09:31 AM, Michal Hocko wrote:
> On Sat 02-04-16 21:17:31, Piotr Kwapulinski wrote:
>> Currently the mmap(MAP_FIXED) discards the overlapping part of the
>> existing VMA(s).
>> Introduce the new MAP_DONTUNMAP flag which forces the mmap to fail
>> with ENOMEM whenever the overlapping occurs and MAP_FIXED is set.
>> No existing mapping(s) is discarded.
>
> You forgot to tell us what is the use case for this new flag.

Exactly. Also, returning ENOMEM is strange, EINVAL might be a better 
match, otherwise how would you distinguish a "geunine" ENOMEM from 
passing a wrong address?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
