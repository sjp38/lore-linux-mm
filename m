Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C2E106B0087
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 17:19:36 -0500 (EST)
Received: by iwn1 with SMTP id 1so505251iwn.37
        for <linux-mm@kvack.org>; Tue, 07 Dec 2010 14:19:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101207135301.49898964.akpm@linux-foundation.org>
References: <1291734086-1405-1-git-send-email-minchan.kim@gmail.com>
	<20101207135301.49898964.akpm@linux-foundation.org>
Date: Wed, 8 Dec 2010 07:19:35 +0900
Message-ID: <AANLkTi=qr4GV8Uh6Rk76FkDUtr=NqydERmWqcxDn8HT0@mail.gmail.com>
Subject: Re: [PATCH] compaction: Remove mem_cgroup_del_lru
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 8, 2010 at 6:53 AM, Andrew Morton <akpm@linux-foundation.org> w=
rote:
> On Wed, =A08 Dec 2010 00:01:26 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> del_page_from_lru_list alreay called mem_cgroup_del_lru.
>> So we need to call it again. It makes wrong stat of memcg and
>> even happen VM_BUG_ON hit.
>>
>> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
>> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Cc: Mel Gorman <mel@csn.ul.ie>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> ---
>> =A0mm/compaction.c | =A0 =A01 -
>> =A01 files changed, 0 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index 50b0a90..b0fbfdf 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -302,7 +302,6 @@ static unsigned long isolate_migratepages(struct zon=
e *zone,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Successfully isolated */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_page_from_lru_list(zone, page, page_lru(=
page));
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_add(&page->lru, migratelist);
>> - =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_del_lru(page);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 cc->nr_migratepages++;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_isolated++;
>>
>
> err, yes, that looks bad.
>
> This bug is present in 2.6.35 and 2.6.36 afaict, so I tagged the fix
> for -stable backporting.

Thanks, Andrew.

>
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
