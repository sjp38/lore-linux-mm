Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3BF3C8D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 17:52:16 -0500 (EST)
Received: by iyj17 with SMTP id 17so5650548iyj.14
        for <linux-mm@kvack.org>; Mon, 31 Jan 2011 14:52:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1296482635-13421-4-git-send-email-hannes@cmpxchg.org>
References: <1296482635-13421-1-git-send-email-hannes@cmpxchg.org>
	<1296482635-13421-4-git-send-email-hannes@cmpxchg.org>
Date: Tue, 1 Feb 2011 07:52:14 +0900
Message-ID: <AANLkTin5qvaHy2=6gE1W_MEA88GXsCvtxBS2kjxG2x23@mail.gmail.com>
Subject: Re: [patch 3/3] memcg: never OOM when charging huge pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 31, 2011 at 11:03 PM, Johannes Weiner <hannes@cmpxchg.org> wrot=
e:
> Huge page coverage should obviously have less priority than the
> continued execution of a process.
>
> Never kill a process when charging it a huge page fails. =C2=A0Instead,
> give up after the first failed reclaim attempt and fall back to
> regular pages.
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
