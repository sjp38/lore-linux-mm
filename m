Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 23AB76B006A
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 19:48:18 -0500 (EST)
Received: by pwj10 with SMTP id 10so1940558pwj.6
        for <linux-mm@kvack.org>; Sun, 01 Nov 2009 16:48:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091102093517.32021780.minchan.kim@barrios-desktop>
References: <20091101234614.F401.A69D9226@jp.fujitsu.com>
	 <20091102093517.32021780.minchan.kim@barrios-desktop>
Date: Mon, 2 Nov 2009 09:48:16 +0900
Message-ID: <28c262360911011648r642ec104x9232303a7f355fdb@mail.gmail.com>
Subject: Re: [PATCHv2 1/5] vmscan: separate sc.swap_cluster_max and
	sc.nr_max_reclaim
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 2, 2009 at 9:35 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> Hi, Kosaki.
>
> On Mon, 2 Nov 2009 00:08:44 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>
>> Currently, sc.scap_cluster_max has double meanings.
>>
>> =A01) reclaim batch size as isolate_lru_pages()'s argument
>> =A02) reclaim baling out thresolds
>>
>> The two meanings pretty unrelated. Thus, Let's separate it.
>> this patch doesn't change any behavior.
>>
>> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Cc: Rafael J. Wysocki <rjw@sisk.pl>
>> Reviewed-by: Rik van Riel <riel@redhat.com>
>> ---
>> =A0mm/vmscan.c | =A0 21 +++++++++++++++------
>> =A01 files changed, 15 insertions(+), 6 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index f805958..6a3eb9f 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -55,6 +55,9 @@ struct scan_control {
>> =A0 =A0 =A0 /* Number of pages freed so far during a call to shrink_zone=
s() */
>> =A0 =A0 =A0 unsigned long nr_reclaimed;
>>
>> + =A0 =A0 /* How many pages shrink_list() should reclaim */
>> + =A0 =A0 unsigned long nr_to_reclaim;
>
> If you try to divide meaning of swap_cluster_max,
> How about changing 'swap_cluster_max', too?
>
> It has a meaning which represents 'batch size'. ;)
> I hope we change it in this chance.

I see the your 4th patch 'Kill sc.swap_cluster_max' now.
It's good to me. Forget this comment. :)


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
