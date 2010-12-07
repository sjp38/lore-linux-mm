Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BB7616B0087
	for <linux-mm@kvack.org>; Mon,  6 Dec 2010 19:17:22 -0500 (EST)
Received: by iwn5 with SMTP id 5so350886iwn.14
        for <linux-mm@kvack.org>; Mon, 06 Dec 2010 16:17:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4CFC52D7.8040003@redhat.com>
References: <cover.1291568905.git.minchan.kim@gmail.com>
	<a11d438e09af9808ac0cb0aba3e74c8a8deb4076.1291568905.git.minchan.kim@gmail.com>
	<4CFC52D7.8040003@redhat.com>
Date: Tue, 7 Dec 2010 09:17:21 +0900
Message-ID: <AANLkTi=KQxRyHnT+mqrGg3-XWrD_R=b3wuEVBzdsVwaV@mail.gmail.com>
Subject: Re: [PATCH v4 3/7] move memcg reclaimable page into tail of inactive list
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 6, 2010 at 12:04 PM, Rik van Riel <riel@redhat.com> wrote:
> On 12/05/2010 12:29 PM, Minchan Kim wrote:
>>
>> Golbal page reclaim moves reclaimalbe pages into inactive list
>> to reclaim asap. This patch apply the rule in memcg.
>> It can help to prevent unnecessary working page eviction of memcg.
>
> The patch is right, but the description is wrong.
>
> The rotate_reclaimable_page function moves just written out
> pages, which the VM wanted to reclaim, to the end of the
> inactive list. =A0That way the VM will find those pages first
> next time it needs to free memory.

Will fix.

>
>> Cc: Balbir Singh<balbir@linux.vnet.ibm.com>
>> Cc: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>> Cc: Rik van Riel<riel@redhat.com>
>> Cc: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
>> Signed-off-by: Minchan Kim<minchan.kim@gmail.com>
>
> Reviewed-by: Rik van Riel <riel@redhat.com>

Thanks, Rik.

>
> --
> All rights reversed
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
