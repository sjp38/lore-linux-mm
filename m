Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8DEF66B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 08:27:46 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id 128so10554180wmz.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 05:27:46 -0800 (PST)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id 1si4191021wmy.90.2016.01.28.05.27.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 05:27:45 -0800 (PST)
Received: by mail-wm0-x235.google.com with SMTP id l66so10918747wml.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 05:27:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAG_fn=Uxk-Y2gVfrdLxPRFf2SQ+1VnoWNUorcDw4E18D0+NBWQ@mail.gmail.com>
References: <cover.1453918525.git.glider@google.com>
	<a6491b8dfc46299797e67436cc1541370e9439c9.1453918525.git.glider@google.com>
	<20160128074051.GA15426@js1304-P5Q-DELUXE>
	<CAG_fn=Uxk-Y2gVfrdLxPRFf2SQ+1VnoWNUorcDw4E18D0+NBWQ@mail.gmail.com>
Date: Thu, 28 Jan 2016 14:27:44 +0100
Message-ID: <CAG_fn=VetOrSwqseiRwCFVr-nTTemczMixbbafgEJdqDRB4p7Q@mail.gmail.com>
Subject: Re: [PATCH v1 5/8] mm, kasan: Stackdepot implementation. Enable
 stackdepot for SLAB
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: kasan-dev@googlegroups.com, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, Dmitriy Vyukov <dvyukov@google.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, linux-mm@kvack.org, Andrey Konovalov <adech.fo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, rostedt@goodmis.org

On Thu, Jan 28, 2016 at 1:51 PM, Alexander Potapenko <glider@google.com> wr=
ote:
>
> On Jan 28, 2016 8:40 AM, "Joonsoo Kim" <iamjoonsoo.kim@lge.com> wrote:
>>
>> Hello,
>>
>> On Wed, Jan 27, 2016 at 07:25:10PM +0100, Alexander Potapenko wrote:
>> > Stack depot will allow KASAN store allocation/deallocation stack trace=
s
>> > for memory chunks. The stack traces are stored in a hash table and
>> > referenced by handles which reside in the kasan_alloc_meta and
>> > kasan_free_meta structures in the allocated memory chunks.
>>
>> Looks really nice!
>>
>> Could it be more generalized to be used by other feature that need to
>> store stack trace such as tracepoint or page owner?
> Certainly yes, but see below.
>
>> If it could be, there is one more requirement.
>> I understand the fact that entry is never removed from depot makes thing=
s
>> very simpler, but, for general usecases, it's better to use reference
>> count
>> and allow to remove. Is it possible?
> For our use case reference counting is not really necessary, and it would
> introduce unwanted contention.
> There are two possible options, each having its advantages and drawbacks:=
 we
> can let the clients store the refcounters directly in their stacks (more
> universal, but harder to use for the clients), or keep the counters in th=
e
> depot but add an API that does not change them (easier for the clients, b=
ut
> potentially error-prone).
>
> I'd say it's better to actually find at least one more user for the stack
> depot in order to understand the requirements, and refactor the code afte=
r
> that.
>> Thanks.
>>
(resending to linux-kernel@ because the previous mail bounced)


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
