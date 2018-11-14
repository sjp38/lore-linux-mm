Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 27F286B000D
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 14:22:00 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id 67so39287914qkj.18
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 11:22:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p20sor13142680qkh.9.2018.11.14.11.21.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Nov 2018 11:21:59 -0800 (PST)
Date: Wed, 14 Nov 2018 19:21:54 +0000
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Subject: Re: [PATCH v5 2/4] mm: convert zone->managed_pages to atomic variable
Message-ID: <20181114192154.cf2kz5pqcokpzpyt@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
References: <1542090790-21750-1-git-send-email-arunks@codeaurora.org>
 <1542090790-21750-3-git-send-email-arunks@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1542090790-21750-3-git-send-email-arunks@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>
Cc: keescook@chromium.org, khlebnikov@yandex-team.ru, minchan@kernel.org, getarunks@gmail.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vatsa@codeaurora.org, willy@infradead.org

On 18-11-13 12:03:08, Arun KS wrote:
> totalram_pages, zone->managed_pages and totalhigh_pages updates
> are protected by managed_page_count_lock, but readers never care
> about it. Convert these variables to atomic to avoid readers
> potentially seeing a store tear.
> 
> This patch converts zone->managed_pages. Subsequent patches will
> convert totalram_panges, totalhigh_pages and eventually
> managed_page_count_lock will be removed.
> 
> Main motivation was that managed_page_count_lock handling was
> complicating things. It was discussed in length here,
> https://lore.kernel.org/patchwork/patch/995739/#1181785
> So it seemes better to remove the lock and convert variables
> to atomic, with preventing poteintial store-to-read tearing as
> a bonus.
> 
> Suggested-by: Michal Hocko <mhocko@suse.com>
> Suggested-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Arun KS <arunks@codeaurora.org>
> Reviewed-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
