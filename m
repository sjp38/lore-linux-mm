Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id D87706B0038
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 15:31:35 -0500 (EST)
Received: by wijp11 with SMTP id p11so59311976wij.0
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 12:31:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n140si24165743wmd.57.2015.11.02.12.31.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Nov 2015 12:31:34 -0800 (PST)
Date: Mon, 2 Nov 2015 12:31:28 -0800
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH 1/5] mm: add cond_resched() to the rmap walks
Message-ID: <20151102203128.GC1707@linux-uzut.site>
References: <1446483691-8494-1-git-send-email-aarcange@redhat.com>
 <1446483691-8494-2-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <1446483691-8494-2-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Petr Holasek <pholasek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 02 Nov 2015, Andrea Arcangeli wrote:

>The rmap walk must reach every possible mapping of the page, so if a
>page is heavily shared (no matter if it's KSM, anon, pagecache) there
>will be tons of entries to walk through. All optimizations with
>prio_tree, anon_vma chains, interval tree, helps to find the right
>virtual mapping faster, but if there are lots of virtual mappings, all
>mapping must still be walked through.
>
>The biggest cost is for the IPIs, but regardless of the IPIs, it's
>generally safer to keep these cond_resched() in all cases, as even if
>we massively reduce the number of IPIs, the number of entries to walk
>IPI-less may still be large and no entry can be possibly skipped in
>the page migration case.
>
>Acked-by: Hugh Dickins <hughd@google.com>
>Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Davidlohr Bueso <dbueso@suse.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
