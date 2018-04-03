Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9C26B0003
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 03:37:01 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id d37so8967888wrd.21
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 00:37:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r17si1494105wrg.64.2018.04.03.00.36.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Apr 2018 00:37:00 -0700 (PDT)
Date: Tue, 3 Apr 2018 09:36:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: limit a process RSS
Message-ID: <20180403073657.GA5501@dhcp22.suse.cz>
References: <1522655119-6317-1-git-send-email-lirongqing@baidu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522655119-6317-1-git-send-email-lirongqing@baidu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li RongQing <lirongqing@baidu.com>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, jglisse@redhat.com, minchan@kernel.org, linux-mm@kvack.org

On Mon 02-04-18 15:45:19, Li RongQing wrote:
> we cannot limit a process RSS although there is ulimit -m,
> not sure why and when ulimit -m is not working, make it work

Could you be more specific about why do you need this functionality?
The RSS limit has never been implemented AFAIK and the main reason is
that the semantic is quite weak to be useful (e.g. the shared memory
accounting, resident memory that is not mapped etc.).

We have memory cgroup controller as an alternative.
-- 
Michal Hocko
SUSE Labs
