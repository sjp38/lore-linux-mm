Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id D29496B007E
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 10:03:25 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so95216ghr.14
        for <linux-mm@kvack.org>; Tue, 20 Mar 2012 07:03:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <op.wbgvn00x3l0zgt@mpn-glaptop>
References: <1332238884-6237-1-git-send-email-laijs@cn.fujitsu.com>
	<1332238884-6237-2-git-send-email-laijs@cn.fujitsu.com>
	<op.wbgvn00x3l0zgt@mpn-glaptop>
Date: Tue, 20 Mar 2012 16:03:24 +0200
Message-ID: <CACVxJT_UVRjkSK+kieYVpO4R+D-4S2bXaoK-apxMkuFAYsgi_A@mail.gmail.com>
Subject: Re: [RFC PATCH 1/6] kenrel.h: add ALIGN_OF_LAST_BIT()
From: Alexey Dobriyan <adobriyan@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Mar 20, 2012 at 2:32 PM, Michal Nazarewicz <mina86@mina86.com> wrot=
e:
> On Tue, 20 Mar 2012 11:21:19 +0100, Lai Jiangshan <laijs@cn.fujitsu.com>
> wrote:
>
>> Get the biggest 2**y that x % (2**y) =3D=3D 0 for the align value.

>> --- a/include/linux/kernel.h
>> +++ b/include/linux/kernel.h
>> @@ -44,6 +44,8 @@
>> =C2=A0#define PTR_ALIGN(p, a) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0((typeof(p))ALIGN((unsigned
>> long)(p), (a)))
>> =C2=A0#define IS_ALIGNED(x, a) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 (((x) & ((typeof(x))(a) - 1)) =3D=3D
>> 0)
>> +#define ALIGN_OF_LAST_BIT(x) =C2=A0 ((((x)^((x) - 1))>>1) + 1)
>
>
> Wouldn't ALIGNMENT() be less confusing? After all, that's what this macro=
 is
> calculating, right? Alignment of given address.

Bits do not have alignment because they aren't directly addressable.
Can you hardcode this sequence with comment, because it looks too
special for macro.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
