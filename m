Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 998BA800D8
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 05:51:29 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id b75so5695196pfk.22
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 02:51:29 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p2si1411715pgn.325.2018.01.25.02.51.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Jan 2018 02:51:28 -0800 (PST)
Subject: Re: Possible deadlock in v4.14.15 contention on shrinker_rwsem in
 shrink_slab()
References: <alpine.LRH.2.11.1801242349220.30642@mail.ewheeler.net>
 <20180125083516.GA22396@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <1ebda9d8-d3e9-db5c-7a06-dc16cbe80188@I-love.SAKURA.ne.jp>
Date: Thu, 25 Jan 2018 19:51:19 +0900
MIME-Version: 1.0
In-Reply-To: <20180125083516.GA22396@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Eric Wheeler <linux-mm@lists.ewheeler.net>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Minchan Kim <minchan@kernel.org>

On 2018/01/25 17:35, Michal Hocko wrote:
> Maybe something related with f80207727aac ("mm/memory.c: release locked
> page in do_swap_page()")

Commit f80207727aaca3aa ("mm/memory.c: release locked page in do_swap_page()")
was added in v4.15-rc9, and commit 0bcac06f27d75285 ("mm, swap: skip swapcache
for swapin of synchronous device") was added in v4.15-rc1. Since commit
0bcac06f27d75285 was not backported to 4.14-stable kernel, it is unlikely
unless Eric explicitly backported that commit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
