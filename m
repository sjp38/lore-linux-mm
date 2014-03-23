Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f170.google.com (mail-vc0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 9425A6B00B7
	for <linux-mm@kvack.org>; Sun, 23 Mar 2014 16:21:42 -0400 (EDT)
Received: by mail-vc0-f170.google.com with SMTP id hu19so4923856vcb.1
        for <linux-mm@kvack.org>; Sun, 23 Mar 2014 13:21:42 -0700 (PDT)
Received: from mail-vc0-f178.google.com (mail-vc0-f178.google.com [209.85.220.178])
        by mx.google.com with ESMTPS id b5si413810vej.29.2014.03.23.13.21.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 23 Mar 2014 13:21:41 -0700 (PDT)
Received: by mail-vc0-f178.google.com with SMTP id im17so4744618vcb.23
        for <linux-mm@kvack.org>; Sun, 23 Mar 2014 13:21:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140323122913.GC2813@quack.suse.cz>
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org>
	<1395436655-21670-3-git-send-email-john.stultz@linaro.org>
	<20140323122913.GC2813@quack.suse.cz>
Date: Sun, 23 Mar 2014 13:21:41 -0700
Message-ID: <CALAqxLVHrtDOtfkPUDgzwdt6eOG4rdykJq6zBFZmRWq+H7i3uA@mail.gmail.com>
Subject: Re: [PATCH 2/5] vrange: Add purged page detection on setting memory non-volatile
From: John Stultz <john.stultz@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sun, Mar 23, 2014 at 5:29 AM, Jan Kara <jack@suse.cz> wrote:
> On Fri 21-03-14 14:17:32, John Stultz wrote:
>> + *
>> + * Sets the vrange_walker.pages_purged to 1 if any were purged.
>                               ^^^ page_was_purged

Doh. Thanks for catching this! Fixed in my tree.

Thanks so much for the review!
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
