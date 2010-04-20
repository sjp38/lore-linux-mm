Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 849D86B01F0
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 05:50:26 -0400 (EDT)
Received: by qyk15 with SMTP id 15so1144632qyk.26
        for <linux-mm@kvack.org>; Tue, 20 Apr 2010 02:50:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100420084454.GD19264@csn.ul.ie>
References: <201004152210.o3FMA7KV001909@imap1.linux-foundation.org>
	 <20100419190133.50a13021.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100419181442.GA19264@csn.ul.ie> <20100419193919.GB19264@csn.ul.ie>
	 <s2v28c262361004191939we64e5490ld59b21dc4fa5bc8d@mail.gmail.com>
	 <20100420082057.GC19264@csn.ul.ie>
	 <x2h28c262361004200132q39fe5d5ex79251643a80d28b3@mail.gmail.com>
	 <20100420084454.GD19264@csn.ul.ie>
Date: Tue, 20 Apr 2010 18:50:23 +0900
Message-ID: <x2u28c262361004200250h2c38894i9adbd85d8fb7b1d8@mail.gmail.com>
Subject: Re: error at compaction (Re: mmotm 2010-04-15-14-42 uploaded
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 20, 2010 at 5:44 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Tue, Apr 20, 2010 at 05:32:13PM +0900, Minchan Kim wrote:
>>
>> Yes. Then, Let's add comment like split_page. :)
>> =C2=A0/*
>> =C2=A0* Note: this is probably too low level an operation for use in dri=
vers.
>> =C2=A0* Please consult with lkml before using this in your driver.
>> =C2=A0*/
>>
>
> I can, but the comment that was there says it's like split_page except th=
e
> page is already free. This also covers not using it in a driver.

I see. In addition, you already mentioned "As this is only being used
for migration".
I missed one.
I don't have any against one.
Will you repost v2 which move split_free_pages out of compaction.c?
Anyway, feel free to add my reviewed-by sign.
Thanks, Mel.

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

>
> --
> Mel Gorman
> Part-time Phd Student =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Linux Technology Center
> University of Limerick =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 IBM Dublin Software Lab
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
