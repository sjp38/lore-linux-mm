Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 551816B0008
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 14:20:34 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id s19so40034733qke.20
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 11:20:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 128sor13208599qkf.63.2018.11.14.11.20.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Nov 2018 11:20:33 -0800 (PST)
Date: Wed, 14 Nov 2018 19:20:30 +0000
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Subject: Re: [PATCH v5 1/4] mm: reference totalram_pages and managed_pages
 once per function
Message-ID: <20181114192030.2iz3vrlppob73uio@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
References: <1542090790-21750-1-git-send-email-arunks@codeaurora.org>
 <1542090790-21750-2-git-send-email-arunks@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1542090790-21750-2-git-send-email-arunks@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>
Cc: keescook@chromium.org, khlebnikov@yandex-team.ru, minchan@kernel.org, getarunks@gmail.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vatsa@codeaurora.org, willy@infradead.org

On 18-11-13 12:03:07, Arun KS wrote:
> This patch is in preparation to a later patch which converts totalram_pages
> and zone->managed_pages to atomic variables. Please note that re-reading
> the value might lead to a different value and as such it could lead to
> unexpected behavior. There are no known bugs as a result of the current code
> but it is better to prevent from them in principle.
> 
> Signed-off-by: Arun KS <arunks@codeaurora.org>
> Reviewed-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
