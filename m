Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id BCCAE8D0039
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 18:37:28 -0500 (EST)
Received: by iwl42 with SMTP id 42so5483510iwl.14
        for <linux-mm@kvack.org>; Wed, 23 Feb 2011 15:37:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110223144445.86d0ca2b.akpm@linux-foundation.org>
References: <1297355626-5152-1-git-send-email-minchan.kim@gmail.com>
	<20110219234121.GA2546@barrios-desktop>
	<20110223144445.86d0ca2b.akpm@linux-foundation.org>
Date: Thu, 24 Feb 2011 08:37:27 +0900
Message-ID: <AANLkTik47+rots2XsouMiCnefmxeC_n=Q9mwBSyE9YjC@mail.gmail.com>
Subject: Re: [PATCH] mm: optimize replace_page_cache_page
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <mszeredi@suse.cz>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>

On Thu, Feb 24, 2011 at 7:44 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Sun, 20 Feb 2011 08:41:21 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> Resend.
>
> Reignore.
>
>> he patch is based on mmotm-2011-02-04 +
>> mm-add-replace_page_cache_page-function-add-freepage-hook.patch.
>>
>> On Fri, Feb 11, 2011 at 01:33:46AM +0900, Minchan Kim wrote:
>> > This patch optmizes replace_page_cache_page.
>> >
>> > 1) remove radix_tree_preload
>> > 2) single radix_tree_lookup_slot and replace radix tree slot
>> > 3) page accounting optimization if both pages are in same zone.
>> >
>> > Cc: Miklos Szeredi <mszeredi@suse.cz>
>> > Cc: Rik van Riel <riel@redhat.com>
>> > Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> > Cc: Mel Gorman <mel@csn.ul.ie>
>> > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> > ---
>> > =C2=A0mm/filemap.c | =C2=A0 61 +++++++++++++++++++++++++++++++++++++++=
+++++++++---------
>> > =C2=A01 files changed, 51 insertions(+), 10 deletions(-)
>> >
>> > Hi Miklos,
>> > This patch is totally not tested.
>> > Could you test this patch?
>
> ^^^ Because of this.
>
> Is it tested yet?
>

Miklos. Could you test this?
If you are busy, let me know how to test it. I will.
Thanks.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
