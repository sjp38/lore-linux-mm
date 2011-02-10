Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CA87D8D003B
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 21:44:13 -0500 (EST)
Received: by iwc10 with SMTP id 10so827822iwc.14
        for <linux-mm@kvack.org>; Wed, 09 Feb 2011 18:44:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1297248362-23579-1-git-send-email-hannes@cmpxchg.org>
References: <1297248362-23579-1-git-send-email-hannes@cmpxchg.org>
Date: Thu, 10 Feb 2011 11:44:11 +0900
Message-ID: <AANLkTimKqORYc+fjX2hQbMAatdwR1zF43MBgnGfmTYVW@mail.gmail.com>
Subject: Re: [patch] memcg: remove memcg->reclaim_param_lock
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Feb 9, 2011 at 7:46 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> The reclaim_param_lock is only taken around single reads and writes to
> integer variables and is thus superfluous. =C2=A0Drop it.
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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
