Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DFA3E6B00EE
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 19:16:17 -0400 (EDT)
Received: by qyk27 with SMTP id 27so58855qyk.14
        for <linux-mm@kvack.org>; Thu, 11 Aug 2011 16:16:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1313094715-31187-1-git-send-email-jweiner@redhat.com>
References: <1313094715-31187-1-git-send-email-jweiner@redhat.com>
Date: Fri, 12 Aug 2011 08:16:15 +0900
Message-ID: <CAEwNFnBAHTTqJnzjpB9eAqUu=3SdP5r+DKJ6+kzcwxhc9fH-6g@mail.gmail.com>
Subject: Re: [patch 1/2] mm: vmscan: fix force-scanning small targets without swap
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, Balbir Singh <bsingharora@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Mel Gorman <mel@csn.ul.ie>

On Fri, Aug 12, 2011 at 5:31 AM, Johannes Weiner <jweiner@redhat.com> wrote=
:
> Without swap, anonymous pages are not scanned. =C2=A0As such, they should
> not count when considering force-scanning a small target if there is
> no swap.
>
> Otherwise, targets are not force-scanned even when their effective
> scan number is zero and the other conditions--kswapd/memcg--apply.
>
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Good catch!


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
