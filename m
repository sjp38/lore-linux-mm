Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8AABA6B0038
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 12:03:52 -0500 (EST)
Received: by wikq8 with SMTP id q8so55792264wik.1
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 09:03:52 -0800 (PST)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id pe3si28379919wjb.62.2015.11.02.09.03.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Nov 2015 09:03:51 -0800 (PST)
Received: by wmec75 with SMTP id c75so66044086wme.1
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 09:03:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56332924.20107@gmail.com>
References: <1446050357-40105-1-git-send-email-glider@google.com>
	<56332924.20107@gmail.com>
Date: Mon, 2 Nov 2015 09:03:51 -0800
Message-ID: <CAG_fn=XErzKCg-PyggqAhjr4xePJ8k9UbUwy-yu7qFaR+WGd0A@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm, kasan: Added GFP flags to KASAN API
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Fair enough. These are only used in
https://github.com/steelannelida/kasan/commit/7c9b30f499dfd5f48b39fbbd0006c=
788bd72f72a
I think I'd better send them for review as part of that change.

On Fri, Oct 30, 2015 at 1:24 AM, Andrey Ryabinin <ryabinin.a.a@gmail.com> w=
rote:
> On 10/28/2015 07:39 PM, Alexander Potapenko wrote:
>> Add GFP flags to KASAN hooks for future patches to use.
>
> Really? These flags are still not used in the next patch (unless I missed=
 something).
>
>> This is the first part of the "mm: kasan: unified support for SLUB and
>> SLAB allocators" patch originally prepared by Dmitry Chernenkov.
>>
>> Signed-off-by: Dmitry Chernenkov <dmitryc@google.com>
>> Signed-off-by: Alexander Potapenko <glider@google.com>



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Dienerstra=C3=9Fe 12
80331 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
Diese E-Mail ist vertraulich. Wenn Sie nicht der richtige Adressat sind,
leiten Sie diese bitte nicht weiter, informieren Sie den
Absender und l=C3=B6schen Sie die E-Mail und alle Anh=C3=A4nge. Vielen Dank=
.
This e-mail is confidential. If you are not the right addressee please
do not forward it, please inform the sender, and please erase this
e-mail including any attachments. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
