Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 05E546B00E2
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 07:48:04 -0500 (EST)
Received: by wgbds13 with SMTP id ds13so9306833wgb.26
        for <linux-mm@kvack.org>; Mon, 12 Dec 2011 04:48:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1112111520510.2297@eggly>
References: <CAJd=RBB_AoJmyPd7gfHn+Kk39cn-+Wn-pFvU0ZWRZhw2fxoihw@mail.gmail.com>
	<alpine.LSU.2.00.1112111520510.2297@eggly>
Date: Mon, 12 Dec 2011 20:48:02 +0800
Message-ID: <CAJd=RBBKsRYq3Y4gaGJMHM3kMJUH_jggf3pFVJK+noD-vpCRCg@mail.gmail.com>
Subject: Re: [PATCH] mm: memcg: keep root group unchanged if fail to create new
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Balbir Singh <bsingharora@gmail.com>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hello Hugh

On Mon, Dec 12, 2011 at 7:39 AM, Hugh Dickins <hughd@google.com> wrote:
> On Sun, 11 Dec 2011, Hillf Danton wrote:
>
>> If the request is not to create root group and we fail to meet it,
>> we'd leave the root unchanged.
>
> I didn't understand that at first: please say "we should" rather
> than "we'd", which I take to be an abbreviation for "we would".
>

Thanks for correcting me.

>
> I wonder what was going through the author's mind when he wrote it
> that way? =C2=A0I wonder if it's one of those bugs that creeps in when
> you start from a perfectly functional patch, then make refinements
> to suit feedback from reviewers.
>

Actually no such a perfectly functional patch, but I also wonder if
you are likely to post and/or share your current todo list if any,
then many could learn the right direction, and in turn you comment
and pull acceptable works in that direction, like Linus.

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
