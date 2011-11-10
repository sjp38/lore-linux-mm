Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C456D6B0073
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 15:31:01 -0500 (EST)
Received: by vcbfo11 with SMTP id fo11so2286276vcb.14
        for <linux-mm@kvack.org>; Thu, 10 Nov 2011 12:30:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1111101218140.21036@chino.kir.corp.google.com>
References: <1320912260.22361.247.camel@sli10-conroe>
	<alpine.DEB.2.00.1111101218140.21036@chino.kir.corp.google.com>
Date: Thu, 10 Nov 2011 22:30:57 +0200
Message-ID: <CAOJsxLH7Fss8bBR+ERBOsb=1ZbwbLi+EkS-7skC1CbBmkMpvKA@mail.gmail.com>
Subject: Re: [patch] slub: fix a code merge error
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Shaohua Li <shaohua.li@intel.com>, linux-mm <linux-mm@kvack.org>, cl@linux-foundation.org

On Thu, Nov 10, 2011 at 10:18 PM, David Rientjes <rientjes@google.com> wrot=
e:
> On Thu, 10 Nov 2011, Shaohua Li wrote:
>
>> Looks there is a merge error in the slub tree. DEACTIVATE_TO_TAIL !=3D 1=
.
>> And this will cause performance regression.
>>
>> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
>>
>> diff --git a/mm/slub.c b/mm/slub.c
>> index 7d2a996..60e16c4 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -1904,7 +1904,8 @@ static void unfreeze_partials(struct kmem_cache *s=
)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (l =3D=3D=
 M_PARTIAL)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 remove_partial(n, page);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 add_partial(n, page, 1);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 add_partial(n, page,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 DEACTIVATE_TO_TAIL);
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 l =3D m;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>
> Acked-by: David Rientjes <rientjes@google.com>
>
> Not sure where the "merge error" is, though, this is how it was proposed
> on linux-mm each time the patch was posted. =A0Probably needs a better ti=
tle
> and changelog.

Indeed. Please resend with proper subject and changelog with
Christoph's and David's ACKs included.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
