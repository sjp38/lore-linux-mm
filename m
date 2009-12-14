Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id F20CB6B003D
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 00:00:59 -0500 (EST)
Received: by pwi1 with SMTP id 1so2192579pwi.6
        for <linux-mm@kvack.org>; Sun, 13 Dec 2009 21:00:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4B25BF39.5020401@redhat.com>
References: <20091211164651.036f5340@annuminas.surriel.com>
	 <28c262360912131614h62d8e0f7qf6ea9ab882f446d4@mail.gmail.com>
	 <4B25BA6E.5010002@redhat.com>
	 <28c262360912132019u7c0b8efpf89b11a6cbe512b3@mail.gmail.com>
	 <4B25BF39.5020401@redhat.com>
Date: Mon, 14 Dec 2009 14:00:57 +0900
Message-ID: <28c262360912132100u689118fob4b72c40a1393846@mail.gmail.com>
Subject: Re: [PATCH v2] vmscan: limit concurrent reclaimers in shrink_zone
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: lwoodman@redhat.com, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Dec 14, 2009 at 1:29 PM, Rik van Riel <riel@redhat.com> wrote:
> On 12/13/2009 11:19 PM, Minchan Kim wrote:
>>
>> On Mon, Dec 14, 2009 at 1:09 PM, Rik van Riel<riel@redhat.com> =C2=A0wro=
te:
>
>>> A simpler solution may be to use sleep_on_interruptible, and
>>> simply have the process continue into shrink_zone() if it
>>> gets a signal.
>>
>> I thought it but I was not sure.
>> Okay. If it is possible, It' more simple.
>> Could you repost patch with that?
>
> Sure, not a problem.
>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 +The default value is 8.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 +
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>
>>
>> =C2=A0 =C2=A0 I like this. but why do you select default value as consta=
nt 8?
>> =C2=A0 =C2=A0 Do you have any reason?
>>
>> =C2=A0 =C2=A0 I think it would be better to select the number proportion=
al to
>> NR_CPU.
>> =C2=A0 =C2=A0 ex) NR_CPU * 2 or something.
>>
>> =C2=A0 =C2=A0 Otherwise looks good to me.
>>
>>
>> Pessimistically, I assume that the pageout code spends maybe
>> 10% of its time on locking (we have seen far, far worse than
>> this with thousands of processes in the pageout code). =C2=A0That
>> means if we have more than 10 threads in the pageout code,
>> we could end up spending more time on locking and less doing
>> real work - slowing everybody down.
>>
>> I rounded it down to the closest power of 2 to come up with
>> an arbitrary number that looked safe :)
>> =3D=3D=3D
>>
>> We discussed above.
>> I want to add your desciption into changelog.
>
> The thing is, I don't know if 8 is the best value for
> the default, which is a reason I made it tunable in
> the first place.
>
> There are a lot of assumptions in my reasoning, and
> they may be wrong. =C2=A0I suspect that documenting something
> wrong is probably worse than letting people wonder out
> the default (and maybe finding a better one).

Indeed. But whenever I see magic values in kernel, I have a question
about that.
Actually I used to doubt the value because I guess
"that value was determined by server or desktop experiments.
so probably it don't proper small system."
At least if we put the logical why which might be wrong,
later people can think that value is not proper any more now or his
system(ex, small or super computer and so on) by based on our
description.
so they can improve it.

I think it isn't important your reasoning is right or wrong.
Most important thing is which logical reason determines that value.

I want to not bother you if you mind my suggestion.
Pz, think it was just nitpick. :)


> --
> All rights reversed.
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
