Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 91D146B0003
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 01:11:34 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id k1-v6so47767ljk.9
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 22:11:34 -0700 (PDT)
Received: from forwardcorp1g.cmail.yandex.net (forwardcorp1g.cmail.yandex.net. [87.250.241.190])
        by mx.google.com with ESMTPS id c4si202754lff.66.2018.10.22.22.11.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 22:11:32 -0700 (PDT)
Subject: Re: [PATCH] mm: convert totalram_pages, totalhigh_pages and
 managed_pages to atomic.
References: <1540229092-25207-1-git-send-email-arunks@codeaurora.org>
 <c57bcc584b3700c483b0311881ec3ae8786f88b1.camel@perches.com>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <15247f54-53f3-83d4-6706-e9264b90ca7a@yandex-team.ru>
Date: Tue, 23 Oct 2018 08:11:31 +0300
MIME-Version: 1.0
In-Reply-To: <c57bcc584b3700c483b0311881ec3ae8786f88b1.camel@perches.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>, Arun KS <arunks@codeaurora.org>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Arun Sudhilal <getarunks@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>

On 23.10.2018 7:15, Joe Perches wrote:> On Mon, 2018-10-22 at 22:53 +0530, Arun KS wrote:
 >> Remove managed_page_count_lock spinlock and instead use atomic
 >> variables.
 >
 > Perhaps better to define and use macros for the accesses
 > instead of specific uses of atomic_long_<inc/dec/read>
 >
 > Something like:
 >
 > #define totalram_pages()	(unsigned long)atomic_long_read(&_totalram_pages)

or proper static inline
this code isn't so low level for breaking include dependencies with macro

 > #define totalram_pages_inc()	(unsigned long)atomic_long_inc(&_totalram_pages)
 > #define totalram_pages_dec()	(unsigned long)atomic_long_dec(&_totalram_pages)

these are void


conversion zone->managed_pages should be split into separate patch


[dropped bloated cc - my server rejects this mess]
