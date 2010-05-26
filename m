Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 112C46B01B2
	for <linux-mm@kvack.org>; Wed, 26 May 2010 19:27:51 -0400 (EDT)
Received: by gyg4 with SMTP id 4so3735505gyg.14
        for <linux-mm@kvack.org>; Wed, 26 May 2010 16:27:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4BFDAC75.5070906@cesarb.net>
References: <4BF81D87.6010506@cesarb.net>
	<20100523140348.GA10843@barrios-desktop>
	<4BF974D5.30207@cesarb.net>
	<AANLkTil1kwOHAcBpsZ_MdtjLmCAFByvF4xvm8JJ7r7dH@mail.gmail.com>
	<4BF9CF00.2030704@cesarb.net>
	<AANLkTin_BV6nWlmX6aXTaHvzH-DnsFIVxP5hz4aZYlqH@mail.gmail.com>
	<4BFA59F7.2020606@cesarb.net>
	<AANLkTikMTwzXt7-vQf9AG2VhwFIGs1jX-1uFoYAKSco7@mail.gmail.com>
	<4BFCF645.2050400@cesarb.net>
	<20100526153144.GA3650@barrios-desktop>
	<22942.1274909335@localhost>
	<AANLkTikwxCvxHI0-d1hGctEmfGRuDUlZ7wAbEXbrS1WA@mail.gmail.com>
	<4BFDAC75.5070906@cesarb.net>
Date: Thu, 27 May 2010 08:27:50 +0900
Message-ID: <AANLkTikQ5ROn-mbhdguMcitmL19WVFSwdD00W0tz0Z2W@mail.gmail.com>
Subject: Re: [PATCH 0/3] mm: Swap checksum
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: Valdis.Kletnieks@vt.edu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, May 27, 2010 at 8:19 AM, Cesar Eduardo Barros <cesarb@cesarb.net> w=
rote:
> Em 26-05-2010 19:45, Minchan Kim escreveu:
>>
>> On Thu, May 27, 2010 at 6:28 AM,<Valdis.Kletnieks@vt.edu> =C2=A0wrote:
>>>
>>> On Thu, 27 May 2010 00:31:44 +0900, Minchan Kim said:
>>>>
>>>> On Wed, May 26, 2010 at 07:21:57AM -0300, Cesar Eduardo Barros wrote:
>>>>>
>>>>> far as I can see, does nothing against the disk simply failing to
>>>>> write and later returning stale data, since the stale checksum would
>>>>> match the stale data.
>>>>
>>>> Sorry. I can't understand your point.
>>>> Who makes stale data? If any layer makes data as stale, integrity is u=
p
>>>> to
>>>> the layer. Maybe I am missing your point.
>>>> Could you explain more detail?
>>>
>>> I'm pretty sure that what Cesar meant was that the following could
>>> happen:
>>>
>>> 1) Write block 11983 on the disk, checksum 34FE9B72.
>>> (... time passes.. maybe weeks)
>>> 2) Attempt to write block 11983 on disk with checksum AE9F3581. The wri=
te
>>> fails
>>> due to a power failure or something.
>>> (... more time passes...)
>>> 3) Read block 11983, get back data with checksum 34FE9B72. Checksum
>>> matches,
>>> and there's no indication that the write in (2) ever failed. The progra=
m
>>> proceeds thinking it's just read back the most recently written data,
>>> when in
>>> fact it's just read an older version of that block. Problems can ensue =
if
>>> the
>>> data just read is now out of sync with *other* blocks of data - instant
>>> data
>>> corruption.
>>
>> Oh, doesn't normal disk support atomicity of sector write?
>> I have been thought disk must support atomicity of sector write at least=
.
>
> It is called a "high fly write" (a write where the disk head was flying t=
oo
> high and the data did not get written at all). There are other causes tha=
n
> high fly writes for this, of course, but the symptom is the same: whateve=
r
> you were trying to write was not written at all, and the old contents are
> still there.

It means that disk return _success_ even though data isn't written at
all on disk?

>
> The write is still atomic: it either did happen completely or did not hap=
pen
> at all (in this case, it did not happen at all). You *can* have a partial
> write (with a well-timed power loss, for instance), but the disk's own EC=
C
> will detect this as a corrupted sector and return an error on read.

Yes. still disk support atomicity as I expect.
Thanks.

>
> --
> Cesar Eduardo Barros
> cesarb@cesarb.net
> cesar.barros@gmail.com
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
