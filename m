Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2C4CC6B0085
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 19:01:47 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id z10so10203283pdj.4
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 16:01:46 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id tx1si40128pbc.64.2014.04.01.16.01.43
        for <linux-mm@kvack.org>;
        Tue, 01 Apr 2014 16:01:44 -0700 (PDT)
Message-ID: <533B4555.3000608@sr71.net>
Date: Tue, 01 Apr 2014 16:01:41 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] Volatile Ranges (v12) & LSF-MM discussion fodder
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org> <20140401212102.GM4407@cmpxchg.org> <533B313E.5000403@zytor.com>
In-Reply-To: <533B313E.5000403@zytor.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Johannes Weiner <hannes@cmpxchg.org>, John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 04/01/2014 02:35 PM, H. Peter Anvin wrote:
> On 04/01/2014 02:21 PM, Johannes Weiner wrote:
>> Either way, optimistic volatile pointers are nowhere near as
>> transparent to the application as the above description suggests,
>> which makes this usecase not very interesting, IMO.
> 
> ... however, I think you're still derating the value way too much.  The
> case of user space doing elastic memory management is more and more
> common, and for a lot of those applications it is perfectly reasonable
> to either not do system calls or to have to devolatilize first.

The SIGBUS is only in cases where the memory is set as volatile and
_then_ accessed, right?

John, this was something that the Mozilla guys asked for, right?  Any
idea why this isn't ever a problem for them?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
