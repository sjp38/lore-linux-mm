Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5888C6B0266
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 14:23:50 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id d196so39906206qkb.6
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 11:23:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m50sor26255365qtb.61.2018.11.14.11.23.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Nov 2018 11:23:49 -0800 (PST)
Date: Wed, 14 Nov 2018 19:23:46 +0000
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Subject: Re: [PATCH v5 4/4] mm: Remove managed_page_count spinlock
Message-ID: <20181114192346.vgqrricdb7to7hgr@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
References: <1542090790-21750-1-git-send-email-arunks@codeaurora.org>
 <1542090790-21750-5-git-send-email-arunks@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1542090790-21750-5-git-send-email-arunks@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>
Cc: keescook@chromium.org, khlebnikov@yandex-team.ru, minchan@kernel.org, getarunks@gmail.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vatsa@codeaurora.org, willy@infradead.org

On 18-11-13 12:03:10, Arun KS wrote:
> Now that totalram_pages and managed_pages are atomic varibles, no need
> of managed_page_count spinlock. The lock had really a weak consistency
> guarantee. It hasn't been used for anything but the update but no reader
> actually cares about all the values being updated to be in sync.
> 
> Signed-off-by: Arun KS <arunks@codeaurora.org>
> Reviewed-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
