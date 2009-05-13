Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 031736B00F5
	for <linux-mm@kvack.org>; Wed, 13 May 2009 07:40:43 -0400 (EDT)
Received: by gxk20 with SMTP id 20so1081953gxk.14
        for <linux-mm@kvack.org>; Wed, 13 May 2009 04:41:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090513113817.GO19296@one.firstfloor.org>
References: <20090513172904.7234.A69D9226@jp.fujitsu.com>
	 <87r5ytl0nn.fsf@basil.nowhere.org>
	 <2f11576a0905130418w1782f85j12cb938e92d256ff@mail.gmail.com>
	 <20090513113817.GO19296@one.firstfloor.org>
Date: Wed, 13 May 2009 20:41:21 +0900
Message-ID: <28c262360905130441q8c904faq1d3e5152fada7a85@mail.gmail.com>
Subject: Re: [PATCH] Kconfig: CONFIG_UNEVICTABLE_LRU move into EMBEDDED
	submenu
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Minchan@firstfloor.org
List-ID: <linux-mm.kvack.org>

Hi, Andi.

On Wed, May 13, 2009 at 8:38 PM, Andi Kleen <andi@firstfloor.org> wrote:
>> In past days, I proposed this. but Minchan found this config bloat kerne=
l 7kb
>> and he claim embedded guys should have selectable chance. I agreed it.
>
> Well there's lots of code in the kernel and 7k doesn't seem worth botheri=
ng.
> If you just save two pages of memory somewhere you can save more.
>
>> Is this enough explanation?
>
> It's not a very good one.
>
> I would propose to just remove it or at least hide it completely
> and only make it dependent on CONFIG_MMU inside Kconfig.

I thought this feature don't have a big impact on embedded.
At First, 7K is not important but as time goes by, it could be huge
with very small size feature for server or desktop.

So I wanted to add it with optionally. :)

In future, embedded also have a big ram then we can remove optional
config completely, I think.


> -Andi
>
> --
> ak@linux.intel.com -- Speaking for myself only.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
