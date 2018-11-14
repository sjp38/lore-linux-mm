Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id D82E66B0010
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 14:23:14 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id l7-v6so39977599qkd.5
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 11:23:14 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x24sor18149663qvc.47.2018.11.14.11.23.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Nov 2018 11:23:14 -0800 (PST)
Date: Wed, 14 Nov 2018 19:23:10 +0000
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Subject: Re: [PATCH v5 3/4] mm: convert totalram_pages and totalhigh_pages
 variables to atomic
Message-ID: <20181114192310.mleekpniomfrbibf@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
References: <1542090790-21750-1-git-send-email-arunks@codeaurora.org>
 <1542090790-21750-4-git-send-email-arunks@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1542090790-21750-4-git-send-email-arunks@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>
Cc: keescook@chromium.org, khlebnikov@yandex-team.ru, minchan@kernel.org, getarunks@gmail.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vatsa@codeaurora.org, willy@infradead.org

On 18-11-13 12:03:09, Arun KS wrote:
> totalram_pages and totalhigh_pages are made static inline function.
> 
> Main motivation was that managed_page_count_lock handling was
> complicating things. It was discussed in lenght here,
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
