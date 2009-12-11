Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 99DAB6B003D
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 19:07:55 -0500 (EST)
Received: by pxi2 with SMTP id 2so89367pxi.11
        for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:07:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.0912101126480.5481@router.home>
References: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com>
	 <20091210163326.28bb7eb8.kamezawa.hiroyu@jp.fujitsu.com>
	 <alpine.DEB.2.00.0912101126480.5481@router.home>
Date: Fri, 11 Dec 2009 09:07:53 +0900
Message-ID: <28c262360912101607s1d55a14q74ffe161dbad5de5@mail.gmail.com>
Subject: Re: [RFC mm][PATCH 1/5] mm counter cleanup
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Fri, Dec 11, 2009 at 2:30 AM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> On Thu, 10 Dec 2009, KAMEZAWA Hiroyuki wrote:
>
>> This patch modifies it to
>> =C2=A0 - Define them in mm.h as inline functions
>> =C2=A0 - Use array instead of macro's name creation. For making easier t=
o add
>> =C2=A0 =C2=A0 new coutners.
>
> Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Except Christoph pointed out, it looks good to me.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
