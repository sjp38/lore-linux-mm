Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 625C86B0009
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 10:32:32 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id b205so115336557wmb.1
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 07:32:32 -0800 (PST)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id pp7si49515910wjc.122.2016.02.16.07.32.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Feb 2016 07:32:31 -0800 (PST)
Received: by mail-wm0-x22c.google.com with SMTP id g62so113573529wme.1
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 07:32:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160129094520.274a860f@gandalf.local.home>
References: <cover.1453918525.git.glider@google.com>
	<99939a92dd93dc5856c4ec7bf32dbe0035cdc689.1453918525.git.glider@google.com>
	<20160128095349.6f771f14@gandalf.local.home>
	<CAG_fn=Ujxs6bv7ovPuOEtwRQGVSe-c3N3pGvWPHA_4oF3zqbFA@mail.gmail.com>
	<CAG_fn=V0-mAPiHS35JJMfrNgB2TFLiGwdbo4S1P_Pw_XR0sETw@mail.gmail.com>
	<20160129094520.274a860f@gandalf.local.home>
Date: Tue, 16 Feb 2016 16:32:30 +0100
Message-ID: <CAG_fn=XTgMkvN7vcBBgMpMHkSGXHeZfkPxZjdR0h9m5GL5PUGw@mail.gmail.com>
Subject: Re: [PATCH v1 4/8] arch, ftrace: For KASAN put hard/soft IRQ entries
 into separate sections
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Ok, interrupt.h sounds good.

On Fri, Jan 29, 2016 at 3:45 PM, Steven Rostedt <rostedt@goodmis.org> wrote=
:
> On Fri, 29 Jan 2016 12:59:13 +0100
> Alexander Potapenko <glider@google.com> wrote:
>
>> On the other hand, this will require including <linux/irq.h> into
>> various files that currently use __irq_section.
>> But that header has a comment saying:
>>
>> /*
>>  * Please do not include this file in generic code.  There is currently
>>  * no requirement for any architecture to implement anything held
>>  * within this file.
>>  *
>>  * Thanks. --rmk
>>  */
>>
>> Do we really want to put anything into that header?
>>
>
> What about interrupt.h?
>
> It's just weird to have KSAN needing to pull in ftrace.h for irq work.
>
> -- Steve



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

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
