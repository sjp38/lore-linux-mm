Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 68F276B0087
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 10:39:42 -0500 (EST)
Received: by iwn40 with SMTP id 40so20309541iwn.14
        for <linux-mm@kvack.org>; Mon, 10 Jan 2011 07:39:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110106095647.GC29257@csn.ul.ie>
References: <cover.1292604745.git.minchan.kim@gmail.com>
	<08549e97645f7d6c2bcc5c760a24fde56dfed513.1292604745.git.minchan.kim@gmail.com>
	<20110106095647.GC29257@csn.ul.ie>
Date: Tue, 11 Jan 2011 00:39:39 +0900
Message-ID: <AANLkTin9RhCSf4YO2KYujV7T3W7D3vuecmGOq7XvFQGn@mail.gmail.com>
Subject: Re: [RFC 3/5] tlbfs: Remove unnecessary page release
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, William Irwin <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 6, 2011 at 6:56 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Sat, Dec 18, 2010 at 02:13:38AM +0900, Minchan Kim wrote:
>> This patch series changes remove_from_page_cache's page ref counting
>> rule. page cache ref count is decreased in remove_from_page_cache.
>> So we don't need call again in caller context.
>>
>> Cc: William Irwin <wli@holomorphy.com>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>
> Other than the subject calling hugetlbfs tlbfs, I did not see any problem
> with this assuming the first patch of the series is also applied.

Thanks, Mel.
Will fix.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
