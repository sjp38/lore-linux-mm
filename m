Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 62EA26B0003
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 14:56:05 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c187-v6so19612705pfa.20
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 11:56:05 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id l4-v6si47304835plb.213.2018.06.04.11.56.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jun 2018 11:56:03 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [QUESTION] About VM_LOCKONFAULT for file page
Message-ID: <aff10e88-8755-b163-8965-3f8065c0c971@linux.alibaba.com>
Date: Mon, 4 Jun 2018 11:55:56 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: emunson@akamai.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Hi folks,


I did a quick test with mlock2 + VM_LOCKONFAULT flag. The test just does 
an 1MB anonymous map and 1MB file map with VM_LOCKONFAULT respectively. 
Then it tries to access one page of each mapping.


 From /proc/meminfo, I can see 1 page marked mlocked from anonymous 
mapping. But, the page from file mapping is *not* marked as mlocked.


I can see the do_anonymous_page() calls 
lru_cache_add_active_or_unevictable() to set the page's PG_mlocked flag. 
But, do_read_fault()/do_shared_fault()/do_cow_fault() don't do it, it 
looks they just do it for COW page.


I'm a little bit confused. Does VM_LOCKONFAULT work for anonymous map 
only? Or did I miss something? Any hint is appreciated.


Thanks,

Yang
