Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9C9856B0047
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 11:34:06 -0400 (EDT)
Received: by iwn33 with SMTP id 33so846892iwn.14
        for <linux-mm@kvack.org>; Thu, 02 Sep 2010 08:34:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4C7FBFE6.7060600@redhat.com>
References: <1283440333-14451-1-git-send-email-minchan.kim@gmail.com>
	<4C7FBFE6.7060600@redhat.com>
Date: Fri, 3 Sep 2010 00:34:03 +0900
Message-ID: <AANLkTikWok_3ANHuxVs=muTVKi3AbcQTphxAfBT613u2@mail.gmail.com>
Subject: Re: [PATCH v2] vmscan: prevent background aging of anon page in no
 swap system
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

Will fix.
Thanks for the quick response. Rik.

On Fri, Sep 3, 2010 at 12:16 AM, Rik van Riel <riel@redhat.com> wrote:
> On 09/02/2010 11:12 AM, Minchan Kim wrote:
>
>> + =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0* If we don't have enough swap space, anonymous page de=
activation
>> + =A0 =A0 =A0 =A0* is pointless.
>> + =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 if (!nr_swap_pages)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>
> It may be better to test !total_swap_pages and change the
> comment to:
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * If we don't have swap space, anonymous page deactivatio=
n
> =A0 =A0 =A0 =A0 * is pointless.
> =A0 =A0 =A0 =A0 */
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
