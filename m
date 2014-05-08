Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 17CF26B0103
	for <linux-mm@kvack.org>; Thu,  8 May 2014 12:39:54 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id v10so2549192pde.29
        for <linux-mm@kvack.org>; Thu, 08 May 2014 09:39:53 -0700 (PDT)
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
        by mx.google.com with ESMTPS id dh1si788934pbc.112.2014.05.08.09.39.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 May 2014 09:39:53 -0700 (PDT)
Received: by mail-pa0-f45.google.com with SMTP id ey11so3112999pad.32
        for <linux-mm@kvack.org>; Thu, 08 May 2014 09:39:52 -0700 (PDT)
Message-ID: <536BB354.2070402@linaro.org>
Date: Thu, 08 May 2014 09:39:48 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] MADV_VOLATILE: Add page purging logic & SIGBUS trap
References: <1398806483-19122-1-git-send-email-john.stultz@linaro.org> <1398806483-19122-5-git-send-email-john.stultz@linaro.org> <20140508051559.GC5282@bbox>
In-Reply-To: <20140508051559.GC5282@bbox>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Keith Packard <keithp@keithp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 05/07/2014 10:16 PM, Minchan Kim wrote:
> On Tue, Apr 29, 2014 at 02:21:23PM -0700, John Stultz wrote:
>> +	update_hiwater_rss(mm);
>> +	if (PageAnon(page))
>> +		dec_mm_counter(mm, MM_ANONPAGES);
>> +	else
>> +		dec_mm_counter(mm, MM_FILEPAGES);
> We can add file-backed page part later when we move to suppport vrange-file.

Fair enough. That bit is easy to drop for now.

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
