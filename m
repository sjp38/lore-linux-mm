Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9EB3F6B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 15:42:34 -0500 (EST)
Received: by wibbs8 with SMTP id bs8so17926525wib.4
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 12:42:34 -0800 (PST)
Received: from mail-we0-x22f.google.com (mail-we0-x22f.google.com. [2a00:1450:400c:c03::22f])
        by mx.google.com with ESMTPS id mb10si20532799wic.0.2015.03.02.12.42.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 12:42:33 -0800 (PST)
Received: by wevl61 with SMTP id l61so35849180wev.2
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 12:42:32 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH v3 3/4] mm: cma: add list of currently allocated CMA buffers to debugfs
In-Reply-To: <54F48560.1090800@partner.samsung.com>
References: <cover.1424802755.git.s.strogin@partner.samsung.com> <1fe64ae6f12eeda1c2aa59daea7f89e57e0e35a9.1424802755.git.s.strogin@partner.samsung.com> <xa1toaojov0x.fsf@mina86.com> <54F48560.1090800@partner.samsung.com>
Date: Mon, 02 Mar 2015 21:42:28 +0100
Message-ID: <xa1tk2yz2ksr.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Strogin <s.strogin@partner.samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

On Mon, Mar 02 2015, Stefan Strogin <s.strogin@partner.samsung.com> wrote:
> My fault. You are right.
> I'm not sure how to do the output nice... I could use *ppos to point the
> number of next list entry to read (like that is used in
> read_page_owner()). But in this case the list could be changed before we
> finish reading, it's bad.
> Or we could use seq_files like in v1, iterating over buffer_list
> entries. But seq_print_stack_trace() has to be added.

I=E2=80=99m not that familiar with seq_* so my opinion may be ill-informed,=
 but
I feel that skipping some entries while (de)allocations happen is akin
to process reading a file while some other process modifies it.  This is
a debug function so perhaps it=E2=80=99s acceptable that it may return garb=
age
if not used carefully?

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
