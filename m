Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3D1A58D0039
	for <linux-mm@kvack.org>; Sun, 27 Feb 2011 18:38:54 -0500 (EST)
Received: by iyf13 with SMTP id 13so3261420iyf.14
        for <linux-mm@kvack.org>; Sun, 27 Feb 2011 15:38:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110227210951.GZ25382@cmpxchg.org>
References: <1298821765-3167-1-git-send-email-minchan.kim@gmail.com>
	<20110227210951.GZ25382@cmpxchg.org>
Date: Mon, 28 Feb 2011 08:38:50 +0900
Message-ID: <AANLkTin6ypqWf7xCufFru1rB_MBptk5o9RSxPC-S9_a3@mail.gmail.com>
Subject: Re: [PATCH] memcg: clean up migration
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, Feb 28, 2011 at 6:09 AM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Mon, Feb 28, 2011 at 12:49:25AM +0900, Minchan Kim wrote:
>> This patch cleans up unncessary BUG_ON check and confusing
>> charge variable.
>>
>> That's because memcg charge/uncharge could be handled by
>> mem_cgroup_[prepare/end] migration itself so charge local variable
>> in unmap_and_move lost the role since we introduced 01b1ae63c2.
>>
>> And mem_cgroup_prepare_migratio return 0 if only it is successful.
>> Otherwise, it jumps to unlock label to clean up so BUG_ON(charge)
>> isn;t meaningless.
>>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
>> Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>
> Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
>
> Thanks, Minchan!
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Hannes
>
> PS: Btw, people sometimes refer to commits by hashes from trees other
> than Linus's, so it's nice to include the subject as well:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A001b1ae6 memcg: simple migration handling
>
> You get this easily by taking the first line of
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0git show --oneline <commithash>
>
> though there are probably other ways.
>

I forgot adding the name with old comment's copy & paste. I will
resend with fixing some typo.

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
