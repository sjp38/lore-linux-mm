Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id C5DA96B0082
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 03:51:16 -0400 (EDT)
Received: by qwa26 with SMTP id 26so1827809qwa.14
        for <linux-mm@kvack.org>; Mon, 20 Jun 2011 00:51:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110620065907.GA29075@minime.bse>
References: <1308547333-27413-1-git-send-email-lliubbo@gmail.com>
	<20110620065907.GA29075@minime.bse>
Date: Mon, 20 Jun 2011 15:51:15 +0800
Message-ID: <BANLkTinEi9u7D9wm_KANNfZWQ=xVPBBHKg@mail.gmail.com>
Subject: Re: [PATCH] nommu: reimplement remap_pfn_range() to simply return 0
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Daniel_Gl=C3=B6ckner?= <daniel-gl@gmx.net>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, gerg@snapgear.com, dhowells@redhat.com, lethal@linux-sh.org, gerg@uclinux.org, walken@google.com, uclinux-dist-devel@blackfin.uclinux.org, geert@linux-m68k.org

On Mon, Jun 20, 2011 at 2:59 PM, Daniel Gl=C3=B6ckner <daniel-gl@gmx.net> w=
rote:
> On Mon, Jun 20, 2011 at 01:22:13PM +0800, Bob Liu wrote:
>> Function remap_pfn_range() means map physical address pfn<<PAGE_SHIFT to
>> user addr.
>>
>> For nommu arch it's implemented by vma->vm_start =3D pfn << PAGE_SHIFT w=
hich is
>> wrong acroding the original meaning of this function.
>>
>> Some driver developer using remap_pfn_range() with correct parameter wil=
l get
>> unexpected result because vm_start is changed.
>>
>> It should be implementd just like addr =3D pfn << PAGE_SHIFT which is me=
anless
>> on nommu arch, so this patch just make it simply return 0.
>
> I'd return -EINVAL if addr !=3D pfn << PAGE_SHIFT.

okay.

> And I can imagine architectures wanting to do something with the prot fla=
gs.
>

Actually it's just a fake function on nommu arch, so in my opinion
we'd better keep it simple
as current.

--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
