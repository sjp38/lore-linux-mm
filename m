Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2962F6B0087
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 10:45:54 -0500 (EST)
Received: by iwn40 with SMTP id 40so20315250iwn.14
        for <linux-mm@kvack.org>; Mon, 10 Jan 2011 07:45:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110108222838.GE23189@cmpxchg.org>
References: <cover.1293031046.git.minchan.kim@gmail.com>
	<4c25f88c476520c47e3b0217e09b6b2d58638685.1293031046.git.minchan.kim@gmail.com>
	<20110108222838.GE23189@cmpxchg.org>
Date: Tue, 11 Jan 2011 00:45:51 +0900
Message-ID: <AANLkTim=+aofmFG=OHTz6fuBC27+Mto31c75Tp_bYrph@mail.gmail.com>
Subject: Re: [PATCH 4/7] swap: Change remove_from_page_cache
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Sun, Jan 9, 2011 at 7:28 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Thu, Dec 23, 2010 at 12:32:46AM +0900, Minchan Kim wrote:
>> This patch series changes remove_from_page_cache's page ref counting
>> rule. Page cache ref count is decreased in delete_from_page_cache.
>> So we don't need decreasing page reference by caller.
>>
>> Cc:Hugh Dickins <hughd@google.com>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> ---
>> =A0mm/shmem.c | =A0 =A03 +--
>
> Patch subject should probably say 'shmem' instead of 'swap'.

Thanks, Hannes.
Will fix.

>
> Otherwise,
> Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
