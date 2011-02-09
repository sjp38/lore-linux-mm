Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 625DD8D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 18:57:38 -0500 (EST)
Received: by iyi20 with SMTP id 20so748597iyi.14
        for <linux-mm@kvack.org>; Wed, 09 Feb 2011 15:57:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5c529b08-cf36-43c7-b368-f3f602faf358@default>
References: <AANLkTi=CEXiOdqPZgQZmQwatHqZ_nsnmnVhwpdt=7q3f@mail.gmail.com>
	<AANLkTimm8o6FnDon=eMTepDaoViU9tjteAYE9kmJhMsx@mail.gmail.com>
	<5c529b08-cf36-43c7-b368-f3f602faf358@default>
Date: Thu, 10 Feb 2011 08:57:36 +0900
Message-ID: <AANLkTinwZJrAWo_Fat3e6WwLn+MPdZyFVgT6sckLCUo3@mail.gmail.com>
Subject: Re: [PATCH V2 2/3] drivers/staging: zcache: host services and PAM services
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: gregkh@suse.de, Chris Mason <chris.mason@oracle.com>, akpm@linux-foundation.org, torvalds@linux-foundation.org, matthew@wil.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, riel@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com, sfr@canb.auug.org.au, wfg@mail.ustc.edu.cn, tytso@mit.edu, viro@zeniv.linux.org.uk, hughd@google.com, hannes@cmpxchg.org

On Thu, Feb 10, 2011 at 1:39 AM, Dan Magenheimer
<dan.magenheimer@oracle.com> wrote:
>
>
>> From: Minchan Kim [mailto:minchan.kim@gmail.com]
>
>> As I read your comment, I can't find the benefit of zram compared to
>> frontswap.
>
> Well, I am biased, but I agree that frontswap is a better technical
> solution than zram. ;-) =C2=A0But "dynamic-ity" is very important to
> me and may be less important to others.
>
> I thought of these other differences, both technical and
> non-technical:
>
> - Zram is minimally invasive to the swap subsystem, requiring only
> =C2=A0one hook which is already upstream (though see below) and is
> =C2=A0apparently already used by some Linux users. =C2=A0Frontswap is som=
ewhat

Yes. I think what someone is using it is a problem.

> =C2=A0more invasive and, UNTIL zcache-was-kztmem was posted a few weeks
> =C2=A0ago, had no non-Xen users (though some distros are already shipping
> =C2=A0the hooks in their kernels because Xen supports it); as a result,
> =C2=A0frontswap has gotten almost no review by kernel swap subsystem
> =C2=A0experts who I'm guessing weren't interested in anything that
> =C2=A0required Xen to use... hopefully that barrier is now resolved
> =C2=A0(but bottom line is frontswap is not yet upstream).

That's why I suggested to remove frontswap in this turn.
If any swap experts has a interest, maybe you can't receive any ack or
review about the part in this series. Maybe  maintainers ends up
hesitating the merge.

If zcache except frontswap is merged into mainline or receive enough
review, then you can try merging frontswap as further step.

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
