Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 9B16F6B0068
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 11:48:47 -0400 (EDT)
Received: by wgbds1 with SMTP id ds1so360873wgb.2
        for <linux-mm@kvack.org>; Wed, 11 Jul 2012 08:48:46 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 04/13] rbtree: move some implementation details from
 rbtree.h to rbtree.c
References: <1341876923-12469-1-git-send-email-walken@google.com>
 <1341876923-12469-5-git-send-email-walken@google.com>
 <op.wg8ciikk3l0zgt@mpn-glaptop>
 <CANN689E8_5YPCu9WMfgSAbBFkQYhfQkoYejdGRd-NPSiFhVuTg@mail.gmail.com>
Date: Wed, 11 Jul 2012 17:48:37 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.whagvbgg3l0zgt@mpn-glaptop>
In-Reply-To: <CANN689E8_5YPCu9WMfgSAbBFkQYhfQkoYejdGRd-NPSiFhVuTg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, axboe@kernel.dk, ebiederm@xmission.com, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Wed, 11 Jul 2012 01:12:54 +0200, Michel Lespinasse <walken@google.com=
> wrote:

> On Tue, Jul 10, 2012 at 5:19 AM, Michal Nazarewicz <mina86@mina86.com>=
 wrote:
>> On Tue, 10 Jul 2012 01:35:14 +0200, Michel Lespinasse <walken@google.=
com> wrote:
>>> +#define        RB_RED          0
>>> +#define        RB_BLACK        1
>>
>> Interestingly, those are almost never used. RB_BLACK is used only onc=
e.
>> Should we get rid of those instead?  Or change the code (like rb_is_r=
ed())
>> to use them?
>
> I'm actually making heavier use of RB_RED / RB_BLACK later on in the p=
atch set.

Yeah, I've just noticed.  Disregard my comment.

> But agree, rb_is_red() / rb_is_black() could use these too.

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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
