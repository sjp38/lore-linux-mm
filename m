Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E17336B007B
	for <linux-mm@kvack.org>; Sun, 17 Jan 2010 21:25:11 -0500 (EST)
Received: by pwj10 with SMTP id 10so1790596pwj.6
        for <linux-mm@kvack.org>; Sun, 17 Jan 2010 18:25:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4B53C466.4010103@redhat.com>
References: <20100118100359.AE22.A69D9226@jp.fujitsu.com>
	 <28c262361001171747w450c8fd8j4daf84b72fb68e1a@mail.gmail.com>
	 <20100118104910.AE2D.A69D9226@jp.fujitsu.com>
	 <28c262361001171810w544614b7rdd3df0f984692f35@mail.gmail.com>
	 <4B53C466.4010103@redhat.com>
Date: Mon, 18 Jan 2010 11:25:10 +0900
Message-ID: <28c262361001171825l59e8ecbemd30a628cd36aab01@mail.gmail.com>
Subject: Re: [PATCH 2/3][v2] vmstat: add anon_scan_ratio field to zoneinfo
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 18, 2010 at 11:16 AM, Rik van Riel <riel@redhat.com> wrote:
> On 01/17/2010 09:10 PM, Minchan Kim wrote:
>
>> Absoultely right. I missed that. Thanks.
>> get_scan_ratio used lru_lock to get reclaim_stat->recent_xxxx.
>> But, it doesn't used lru_lock to get ap/fp.
>>
>> Is it intentional? I think you or Rik know it. :)
>> I think if we want to get exact value, we have to use lru_lock until
>> getting ap/fp.
>> If it isn't, we don't need lru_lock when we get the
>> reclaim_stat->recent_xxxx.
>>
>> What do you think about it?
>
> This is definately not intentional.
>
> Getting race conditions in this code could throw off the
> statistics by a factor 2. =C2=A0I do not know how serious that
> would be for the VM or whether (and how quickly) it would
> self correct.

Okay. How about making patch to get exact ap/fp?
Although it were not serious or fast recoverable, I think it would be bette=
r
to protect lru_lock for consistency if lru_lock isn't big contention lock.

>
> --
> All rights reversed.
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
