Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id D0A816B0038
	for <linux-mm@kvack.org>; Mon, 26 Oct 2015 20:32:12 -0400 (EDT)
Received: by wijp11 with SMTP id p11so190436190wij.0
        for <linux-mm@kvack.org>; Mon, 26 Oct 2015 17:32:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id az3si14151670wjb.67.2015.10.26.17.32.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 26 Oct 2015 17:32:11 -0700 (PDT)
Date: Mon, 26 Oct 2015 17:32:02 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH 2/6] ksm: add cond_resched() to the rmap_walks
Message-ID: <20151027003202.GG27292@linux-uzut.site>
References: <1444925065-4841-1-git-send-email-aarcange@redhat.com>
 <1444925065-4841-3-git-send-email-aarcange@redhat.com>
 <alpine.LSU.2.11.1510251634410.1923@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1510251634410.1923@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Petr Holasek <pholasek@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Sun, 25 Oct 2015, Hugh Dickins wrote:

>On Thu, 15 Oct 2015, Andrea Arcangeli wrote:
>
>> While at it add it to the file and anon walks too.
>>
>> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
>
>Subject really should be "mm: add cond_resched() to the rmap walks",
>then body "Add cond_resched() to the ksm and anon and file rmap walks."
>
>Acked-by: Hugh Dickins <hughd@google.com>
>but I think we need a blessing from Davidlohr too, if not more.

Perhaps I'm lost in the context, but by the changelog alone I cannot
see the reasoning for the patch. Are latencies really that high? Maybe,
at least the changelog needs some love.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
