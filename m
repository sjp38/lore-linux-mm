Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9D2408D0015
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 19:29:30 -0400 (EDT)
Received: by iwn38 with SMTP id 38so1973981iwn.14
        for <linux-mm@kvack.org>; Thu, 28 Oct 2010 16:29:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTi=VnTkuyYht8D+2MPO1d4mXR1ah-0aQeAjZsTaq@mail.gmail.com>
References: <20101028191523.GA14972@google.com>
	<20101028131029.ee0aadc0.akpm@linux-foundation.org>
	<20101028220331.GZ26494@google.com>
	<AANLkTi=VnTkuyYht8D+2MPO1d4mXR1ah-0aQeAjZsTaq@mail.gmail.com>
Date: Fri, 29 Oct 2010 08:29:29 +0900
Message-ID: <AANLkTi=f5-4rOcf8WwSnM4bwV-xBxQ_G++ZdYj_GL1ii@mail.gmail.com>
Subject: Re: [PATCH] RFC: vmscan: add min_filelist_kbytes sysctl for
 protecting the working set
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Mandeep Singh Baines <msb@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wad@chromium.org, olofj@chromium.org, hughd@chromium.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 29, 2010 at 8:28 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> I think this feature that "System response time doesn't allow but OOM allow".
I think we _need_ this feature that "System response time doesn't
allow but OOM allow".

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
