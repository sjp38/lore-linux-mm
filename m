Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9C6046B02CB
	for <linux-mm@kvack.org>; Tue, 15 May 2018 17:12:43 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id l85-v6so909965pfb.18
        for <linux-mm@kvack.org>; Tue, 15 May 2018 14:12:43 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p3-v6si997476pfb.171.2018.05.15.14.12.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 May 2018 14:12:42 -0700 (PDT)
Date: Tue, 15 May 2018 14:12:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5] mm: don't allow deferred pages with NEED_PER_CPU_KM
Message-Id: <20180515141240.c7587ed53a0ff32ff984e3d2@linux-foundation.org>
In-Reply-To: <20180515175124.1770-1-pasha.tatashin@oracle.com>
References: <20180515175124.1770-1-pasha.tatashin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, tglx@linutronix.de, mhocko@suse.com, linux-mm@kvack.org, mgorman@techsingularity.net, mingo@kernel.org, peterz@infradead.org, rostedt@goodmis.org, fengguang.wu@intel.com, dennisszhou@gmail.com

On Tue, 15 May 2018 13:51:24 -0400 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> It is unsafe to do virtual to physical translations before mm_init() is
> called if struct page is needed in order to determine the memory section
> number (see SECTION_IN_PAGE_FLAGS). This is because only in mm_init() we
> initialize struct pages for all the allocated memory when deferred struct
> pages are used.
> 
> My recent fix exposed this problem,

"my recent fix" isn't very useful.  I changed this to identify
c9e97a1997 ("mm: initialize pages on demand during boot"), yes?

> 
> Fixes: 3a80a7fa7989 ("mm: meminit: initialise a subset of struct pages if CONFIG_DEFERRED_STRUCT_PAGE_INIT is set")
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>

And I added cc:stable.
