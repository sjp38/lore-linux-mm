Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0DC396B0038
	for <linux-mm@kvack.org>; Tue, 30 Dec 2014 09:41:11 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id n12so20550302wgh.6
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 06:41:10 -0800 (PST)
Received: from mail-wi0-x22b.google.com (mail-wi0-x22b.google.com. [2a00:1450:400c:c05::22b])
        by mx.google.com with ESMTPS id o10si23495439wjf.33.2014.12.30.06.41.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 30 Dec 2014 06:41:10 -0800 (PST)
Received: by mail-wi0-f171.google.com with SMTP id bs8so24133643wib.4
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 06:41:10 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 3/3] cma: add functions to get region pages counters
In-Reply-To: <20141230022625.GA4588@js1304-P5Q-DELUXE>
References: <cover.1419602920.git.s.strogin@partner.samsung.com> <dfddb08aba9a05e6e7b43e9861ab09b7ac1c89cd.1419602920.git.s.strogin@partner.samsung.com> <20141230022625.GA4588@js1304-P5Q-DELUXE>
Date: Tue, 30 Dec 2014 15:41:05 +0100
Message-ID: <xa1th9wdtd32.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Stefan I. Strogin" <s.strogin@partner.samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Safonov <d.safonov@partner.samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>

> On Fri, Dec 26, 2014 at 05:39:04PM +0300, Stefan I. Strogin wrote:
>> From: Dmitry Safonov <d.safonov@partner.samsung.com>
>> @@ -591,6 +621,10 @@ static int s_show(struct seq_file *m, void *p)
>>  	struct cma_buffer *cmabuf;
>>  	struct stack_trace trace;
>>=20=20
>> +	seq_printf(m, "CMARegion stat: %8lu kB total, %8lu kB used, %8lu kB ma=
x contiguous chunk\n\n",
>> +		   cma_get_size(cma) >> 10,
>> +		   cma_get_used(cma) >> 10,
>> +		   cma_get_maxchunk(cma) >> 10);
>>  	mutex_lock(&cma->list_lock);
>>=20=20
>>  	list_for_each_entry(cmabuf, &cma->buffers_list, list) {

On Tue, Dec 30 2014, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> How about changing printing format like as meminfo or zoneinfo?
>
> CMARegion #
> Total: XXX
> Used: YYY
> MaxContig: ZZZ

+1.  I was also thinking about this actually.

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
