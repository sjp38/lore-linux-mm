Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C23806B01AC
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 02:23:36 -0400 (EDT)
Received: by bwz9 with SMTP id 9so1043872bwz.14
        for <linux-mm@kvack.org>; Wed, 30 Jun 2010 23:23:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1006291043070.16135@router.home>
References: <20100625212026.810557229@quilx.com>
	<20100625212106.384650677@quilx.com>
	<AANLkTikSzWZme6kioKJ7DJbS0nhYqeDTPas1D9rb_LY-@mail.gmail.com>
	<alpine.DEB.2.00.1006291043070.16135@router.home>
Date: Thu, 1 Jul 2010 09:23:33 +0300
Message-ID: <AANLkTiklCoCe8k3CaYHNK0P86t76RLb2rMUYg2xiE1Rm@mail.gmail.com>
Subject: Re: [S+Q 09/16] [percpu] make allocpercpu usable during early boot
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, tj@kernel.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

> On Mon, 28 Jun 2010, Pekka Enberg wrote:
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return kzalloc(size, GFP_KERNEL & gfp_al=
lowed_mask);
>> > =A0 =A0 =A0 =A0else {
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void *ptr =3D vmalloc(size);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ptr)
>>
>> This looks wrong to me. All slab allocators should do gfp_allowed_mask
>> magic under the hood. Maybe it's triggering kmalloc_large() path that
>> needs the masking too?

On Tue, Jun 29, 2010 at 6:45 PM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> They do gfp_allowed_mask magic. But the checks at function entry of the
> slabs do not mask the masks so we get false positives without this. All m=
y
> protest against the checks doing it this IMHO broken way were ignored.

Which checks are those? Are they in SLUB proper or are they introduced
in one of the SLEB patches? We definitely don't want to expose
gfp_allowed_mask here.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
