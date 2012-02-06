Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 4B56D6B002C
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 07:51:56 -0500 (EST)
Received: by wera13 with SMTP id a13so5710507wer.14
        for <linux-mm@kvack.org>; Mon, 06 Feb 2012 04:51:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <op.v87mpive3l0zgt@mpn-glaptop>
References: <1328271538-14502-1-git-send-email-m.szyprowski@samsung.com>
	<1328271538-14502-13-git-send-email-m.szyprowski@samsung.com>
	<CAJd=RBBPOwftZJUfe3xc6y24=T8un5hPk0wEOT_5v6WMCbDSag@mail.gmail.com>
	<op.v87mpive3l0zgt@mpn-glaptop>
Date: Mon, 6 Feb 2012 20:51:54 +0800
Message-ID: <CAJd=RBCqw=4AEDZU5aPexX2+xVKVhB+uo-ta2hviSAJO63axvw@mail.gmail.com>
Subject: Re: [PATCH 12/15] drivers: add Contiguous Memory Allocator
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

2012/2/5 Michal Nazarewicz <mina86@mina86.com>:
> On Sun, 05 Feb 2012 05:25:40 +0100, Hillf Danton <dhillf@gmail.com> wrote=
:
>>
>> Without boot mem reservation, what is the successful rate of CMA to
>> serve requests of 1MiB, 2MiB, 4MiB and 8MiB chunks?
>
>
> CMA will work as long as you manage to get some pageblocks marked as
> MIGRATE_CMA and move all non-movable pages away. =C2=A0You might try and =
get it
> done after system has booted but we have not tried nor tested it.

Better to include whatever test results in change log.

And no more questions ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
