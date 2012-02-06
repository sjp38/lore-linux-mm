Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id D68F76B002C
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 07:46:54 -0500 (EST)
Received: by wera13 with SMTP id a13so5705794wer.14
        for <linux-mm@kvack.org>; Mon, 06 Feb 2012 04:46:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <op.v87mrdg83l0zgt@mpn-glaptop>
References: <1328271538-14502-1-git-send-email-m.szyprowski@samsung.com>
	<1328271538-14502-6-git-send-email-m.szyprowski@samsung.com>
	<CAJd=RBBsTxV4bM_QEbKaU=uKkFTNgPEK4yTiLjbE0TaEp4KA7w@mail.gmail.com>
	<op.v87mrdg83l0zgt@mpn-glaptop>
Date: Mon, 6 Feb 2012 20:46:51 +0800
Message-ID: <CAJd=RBAsRA-yggVSmijJPTLM2kKiLKWrTS9RjtESgPDc3pYTug@mail.gmail.com>
Subject: Re: [PATCH 05/15] mm: compaction: export some of the functions
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

2012/2/5 Michal Nazarewicz <mina86@mina86.com>:
>> On Fri, Feb 3, 2012 at 8:18 PM, Marek Szyprowski
>> <m.szyprowski@samsung.com> wrote:
>>>
>>> From: Michal Nazarewicz <mina86@mina86.com>
>>>
>>> This commit exports some of the functions from compaction.c file
>>> outside of it adding their declaration into internal.h header
>>> file so that other mm related code can use them.
>>>
>>> This forced compaction.c to always be compiled (as opposed to being
>>> compiled only if CONFIG_COMPACTION is defined) but as to avoid
>>> introducing code that user did not ask for, part of the compaction.c
>>> is now wrapped in on #ifdef.
>
>
> On Sun, 05 Feb 2012 08:40:08 +0100, Hillf Danton <dhillf@gmail.com> wrote=
:
>>
>> What if both compaction and CMA are not enabled?
>
>
> What about it? =C2=A0If both are enabled, both will be compiled and usabl=
e.
>

Better if enforced compilation of compaction is addressed in separate
patch in the patchset, according to the rule that one patch is delivered
with one issue concerned.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
