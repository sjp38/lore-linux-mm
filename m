Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 356E06B005D
	for <linux-mm@kvack.org>; Wed, 20 May 2009 06:52:42 -0400 (EDT)
Received: by gxk20 with SMTP id 20so785277gxk.14
        for <linux-mm@kvack.org>; Wed, 20 May 2009 03:53:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090520104739.GD12433@csn.ul.ie>
References: <20090520161853.1bfd415c.minchan.kim@barrios-desktop>
	 <20090520085416.GA27056@csn.ul.ie>
	 <20090520185803.e5b0698a.minchan.kim@barrios-desktop>
	 <20090520102129.GA12433@csn.ul.ie>
	 <20090520193045.2070f7fa.minchan.kim@barrios-desktop>
	 <20090520104739.GD12433@csn.ul.ie>
Date: Wed, 20 May 2009 19:53:30 +0900
Message-ID: <28c262360905200353x60af7141gc73e491c2c7d17a3@mail.gmail.com>
Subject: Re: [PATCH 1/3] clean up setup_per_zone_pages_min
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 20, 2009 at 7:47 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Wed, May 20, 2009 at 07:30:45PM +0900, Minchan Kim wrote:
>> On Wed, 20 May 2009 11:21:29 +0100
>> Mel Gorman <mel@csn.ul.ie> wrote:
>>
>> > On Wed, May 20, 2009 at 06:58:03PM +0900, Minchan Kim wrote:
>> > > Hi, Mel.
>> > >
>> > > On Wed, 20 May 2009 09:54:16 +0100
>> > > Mel Gorman <mel@csn.ul.ie> wrote:
>> > >
>> > > > On Wed, May 20, 2009 at 04:18:53PM +0900, Minchan Kim wrote:
>> > > > >
>> > > > > Mel changed zone->pages_[high/low/min] with zone->watermark arra=
y.
>> > > > > So, setup_per_zone_pages_min also have to be changed.
>> > > > >
>> > > >
>> > > > Just to be clear, this is a function renaming to match the new zon=
e
>> > > > field name, not something I missed. As the function changes min, l=
ow and
>> > > > max, a better name might have been setup_per_zone_watermarks but w=
hether
>> > >
>> > > At first, I thouht, too. But It's handle of min_free_kbytes.
>> > > Documentation said, it's to compute a watermark[WMARK_MIN].
>> > > I think many people already used that knob to contorl pages_min to k=
eep the
>> > > low pages.
>> >
>> > Which documentation?
>>
>> Documentation/sysctl/vm.txt - min_free_kbytes.
>>
>
> That documentation states
>
> =3D=3D=3D=3D
> This is used to force the Linux VM to keep a minimum number
> of kilobytes free. =C2=A0The VM uses this number to compute a pages_min
> value for each lowmem zone in the system. =C2=A0Each lowmem zone gets
> a number of reserved free pages based proportionally on its size.
> =3D=3D=3D=3D
>
> This is true. It just happens in the implementation that sets pages_min
> (or it's renamed value) also sets the low and high watermarks are also se=
t
> based on the value of the minimum value. It doesn't need to be updated.
>

Okay.
I will modify function name with setup_per_zone_watermarks at next version.
Thanks for careful review, Mel.


--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
