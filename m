Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B11A88D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 17:27:38 -0500 (EST)
Received: by iwn40 with SMTP id 40so6202755iwn.14
        for <linux-mm@kvack.org>; Mon, 31 Jan 2011 14:27:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1296482635-13421-2-git-send-email-hannes@cmpxchg.org>
References: <1296482635-13421-1-git-send-email-hannes@cmpxchg.org>
	<1296482635-13421-2-git-send-email-hannes@cmpxchg.org>
Date: Tue, 1 Feb 2011 07:27:36 +0900
Message-ID: <AANLkTikB+_Qgb0OA8mkEhftAvH3eZz_PCTqrzCoZUqEy@mail.gmail.com>
Subject: Re: [patch 1/3] memcg: prevent endless loop when charging huge pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 31, 2011 at 11:03 PM, Johannes Weiner <hannes@cmpxchg.org> wrot=
e:
> The charging code can encounter a charge size that is bigger than a
> regular page in two situations: one is a batched charge to fill the
> per-cpu stocks, the other is a huge page charge.
>
> This code is distributed over two functions, however, and only the
> outer one is aware of huge pages. =C2=A0In case the charging fails, the
> inner function will tell the outer function to retry if the charge
> size is bigger than regular pages--assuming batched charging is the
> only case. =C2=A0And the outer function will retry forever charging a hug=
e
> page.
>
> This patch makes sure the inner function can distinguish between batch
> charging and a single huge page charge. =C2=A0It will only signal another
> attempt if batch charging failed, and go into regular reclaim when it
> is called on behalf of a huge page.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
