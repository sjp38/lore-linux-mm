Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 542916B002C
	for <linux-mm@kvack.org>; Sun,  5 Feb 2012 09:34:22 -0500 (EST)
Received: by eaag11 with SMTP id g11so2431540eaa.14
        for <linux-mm@kvack.org>; Sun, 05 Feb 2012 06:34:20 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 05/15] mm: compaction: export some of the functions
References: <1328271538-14502-1-git-send-email-m.szyprowski@samsung.com>
 <1328271538-14502-6-git-send-email-m.szyprowski@samsung.com>
 <CAJd=RBBsTxV4bM_QEbKaU=uKkFTNgPEK4yTiLjbE0TaEp4KA7w@mail.gmail.com>
Date: Sun, 05 Feb 2012 15:34:15 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v87mrdg83l0zgt@mpn-glaptop>
In-Reply-To: <CAJd=RBBsTxV4bM_QEbKaU=uKkFTNgPEK4yTiLjbE0TaEp4KA7w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Hillf Danton <dhillf@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> On Fri, Feb 3, 2012 at 8:18 PM, Marek Szyprowski
> <m.szyprowski@samsung.com> wrote:
>> From: Michal Nazarewicz <mina86@mina86.com>
>>
>> This commit exports some of the functions from compaction.c file
>> outside of it adding their declaration into internal.h header
>> file so that other mm related code can use them.
>>
>> This forced compaction.c to always be compiled (as opposed to being
>> compiled only if CONFIG_COMPACTION is defined) but as to avoid
>> introducing code that user did not ask for, part of the compaction.c
>> is now wrapped in on #ifdef.

On Sun, 05 Feb 2012 08:40:08 +0100, Hillf Danton <dhillf@gmail.com> wrot=
e:
> What if both compaction and CMA are not enabled?

What about it?  If both are enabled, both will be compiled and usable.

-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
