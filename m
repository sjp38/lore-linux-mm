Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id A7CAB6B0038
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 01:23:02 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so164428076pdn.0
        for <linux-mm@kvack.org>; Sun, 29 Mar 2015 22:23:02 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id p5si13215122par.19.2015.03.29.22.23.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Mar 2015 22:23:01 -0700 (PDT)
Received: by patj18 with SMTP id j18so380527pat.2
        for <linux-mm@kvack.org>; Sun, 29 Mar 2015 22:23:01 -0700 (PDT)
Date: Mon, 30 Mar 2015 14:22:50 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 4/4] mm: make every pte dirty on do_swap_page
Message-ID: <20150330052250.GA3008@blaptop>
References: <1426036838-18154-1-git-send-email-minchan@kernel.org>
 <1426036838-18154-4-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1426036838-18154-4-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Yalin.Wang@sonymobile.com, Hugh Dickins <hughd@google.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Pavel Emelyanov <xemul@parallels.com>

2nd description trial.
