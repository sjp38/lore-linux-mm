Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 610296B7120
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 17:50:39 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 82so9393750pfs.20
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 14:50:39 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d8si14990631pgl.386.2018.12.04.14.50.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 14:50:38 -0800 (PST)
Date: Tue, 4 Dec 2018 14:50:34 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] mm: use the cached page for filemap_fault
Message-Id: <20181204145034.4b69bdea36506be45946f8c9@linux-foundation.org>
In-Reply-To: <20181130195812.19536-5-josef@toxicpanda.com>
References: <20181130195812.19536-1-josef@toxicpanda.com>
	<20181130195812.19536-5-josef@toxicpanda.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, david@fromorbit.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, jack@suse.cz

On Fri, 30 Nov 2018 14:58:12 -0500 Josef Bacik <josef@toxicpanda.com> wrote:

> If we drop the mmap_sem we have to redo the vma lookup which requires
> redoing the fault handler.  Chances are we will just come back to the
> same page, so save this page in our vmf->cached_page and reuse it in the
> next loop through the fault handler.
> 

Is this really worthwhile?  Rerunning the fault handler is rare (we
hope) and a single pagecache lookup is fast.

Some performance testing results would be helpful here.  It's
practically obligatory when claiming a performance improvement.
