Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6B3FF8E0014
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 14:43:45 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id w15so1657004edl.21
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 11:43:45 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r9-v6si994896ejp.209.2018.12.13.11.43.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 11:43:44 -0800 (PST)
Subject: Re: [PATCH] mm: Replace verify_mm_writelocked() by
 lockdep_assert_held_exclusive()
References: <1544729885-30702-1-git-send-email-longman@redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f874f3d6-2f84-cd3a-a227-43496d8175a7@suse.cz>
Date: Thu, 13 Dec 2018 20:40:44 +0100
MIME-Version: 1.0
In-Reply-To: <1544729885-30702-1-git-send-email-longman@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yang Shi <yang.shi@linux.alibaba.com>

On 12/13/18 8:38 PM, Waiman Long wrote:
> Using down_read_trylock() to check if a task holds a write lock on
> a rwsem is not reliable. A task can hold a read lock on a rwsem and
> down_read_trylock() can fail if a writer is waiting in the wait queue.
>
> So use lockdep_assert_held_exclusive() instead which can do the right
> check when CONFIG_LOCKDEP is on.
> 
> Signed-off-by: Waiman Long <longman@redhat.com>

There's already a patch in mmotm removing this completely:
https://www.ozlabs.org/~akpm/mmots/broken-out/mm-mmap-remove-verify_mm_writelocked.patch

Vlastimil
