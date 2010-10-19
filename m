Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 586206B00CE
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 22:24:48 -0400 (EDT)
Received: by qwd6 with SMTP id 6so5866qwd.14
        for <linux-mm@kvack.org>; Mon, 18 Oct 2010 19:24:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101018191840.89b39aa3.akpm@linux-foundation.org>
References: <20101016043331.GA3177@darkstar>
	<20101018164647.bc928c78.akpm@linux-foundation.org>
	<AANLkTikVueTjihngtC2rsoeqkUb5Wg-zeEFH1HKgcuuo@mail.gmail.com>
	<AANLkTi=t2U5wa_7pqcb1pAq6p_x7VqYKbfMDZ10q+Geq@mail.gmail.com>
	<20101018191840.89b39aa3.akpm@linux-foundation.org>
Date: Tue, 19 Oct 2010 10:24:44 +0800
Message-ID: <AANLkTik_yrUkbY+UpA0A9CJcDDXc9kd-MFVhqCNdK_JP@mail.gmail.com>
Subject: Re: [PATCH 1/2] Add vzalloc shortcut
From: Dave Young <hidave.darkstar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 19, 2010 at 10:18 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue, 19 Oct 2010 09:55:17 +0800 Dave Young <hidave.darkstar@gmail.com>=
 wrote:
>
>> On Tue, Oct 19, 2010 at 9:27 AM, Dave Young <hidave.darkstar@gmail.com> =
wrote:
>> > On Tue, Oct 19, 2010 at 7:46 AM, Andrew Morton
>> >>
>> >> Also, a slightly better implementation would be
>> >>
>> >> static inline void * vmalloc_node_flags(unsigned long size, gfp_t fla=
gs)
>> >> {
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0return =C2=A0vmalloc_node(size, 1, flags, =
PAGE_KERNEL, -1,
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 builtin_return_address(0));
>> >> }
>>
>> Is this better? might =C2=A0vmalloc_node_flags would be used by other th=
an vmalloc?
>>
>> static inline void * vmalloc_node_flags(unsigned long size, int node,
>> gfp_t flags)
>
> I have no strong opinions, really. =C2=A0If we add more and more argument=
s
> to vmalloc_node_flags() it ends up looking like vmalloc_node(), so we
> may as well just call vmalloc_node(). =C2=A0Do whatever feels good ;)

Ok, thanks.

Then I would prefer add 'node' argument due to the function name of
vmalloc_node_flags

--=20
Regards
dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
