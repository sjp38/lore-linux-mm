Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 162FA6B0038
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 14:26:37 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id j85so13531138wmj.5
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 11:26:37 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id cl2si23427644wjc.149.2016.10.07.11.26.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Oct 2016 11:26:35 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id 123so4120581wmb.3
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 11:26:35 -0700 (PDT)
Date: Fri, 7 Oct 2016 19:26:33 +0100
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: Re: [PATCH] mm: check VMA flags to avoid invalid PROT_NONE NUMA
 balancing
Message-ID: <20161007182633.GB14350@lucifer>
References: <20160911225425.10388-1-lstoakes@gmail.com>
 <20160925184731.GA20480@lucifer>
 <CA+55aFwtHAT_ukyE=+s=3twW8v8QExLxpVcfEDyLihf+pn9qeA@mail.gmail.com>
 <1474842875.17726.38.camel@redhat.com>
 <CA+55aFyL+qFsJpxQufgRKgWeB6Yj0e1oapdu5mdU9_t+zwtBjg@mail.gmail.com>
 <20161007100720.GA14859@lucifer>
 <CA+55aFzOYk_1Jcr8CSKyqfkXaOApZvCkX0_27mZk7PvGSE4xSw@mail.gmail.com>
 <20161007162240.GA14350@lucifer>
 <alpine.LSU.2.11.1610071101410.7822@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1610071101410.7822@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, tbsaunde@tbsaunde.org, robert@ocallahan.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Oct 07, 2016 at 11:16:26AM -0700, Hugh Dickins wrote:
>
> Adding Jan Kara (and Dave Hansen) to the Cc list: I think they were
> pursuing get_user_pages() cleanups last year (which would remove the
> force option from most callers anyway), and I've lost track of where
> that all got to.  Lorenzo, please don't expend a lot of effort before
> checking with Jan.

Sure, no problem. I have the callers noted down + the surrounding code in my
wetware 'L3 cache' so it's not a huge effort to get a draft patch written, but
I'll hold off on sending anything until I hear from Jan.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
