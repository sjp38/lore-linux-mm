Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 2BFE36B0044
	for <linux-mm@kvack.org>; Wed,  4 Apr 2012 08:22:46 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so273856pbc.14
        for <linux-mm@kvack.org>; Wed, 04 Apr 2012 05:22:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1204032348470.3865@chino.kir.corp.google.com>
References: <4EE6F24B.7050204@gmail.com>
	<alpine.DEB.2.00.1203071331150.15255@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1204032348470.3865@chino.kir.corp.google.com>
Date: Wed, 4 Apr 2012 20:22:45 +0800
Message-ID: <CAJd=RBB0+TpK6Y+VrWgisAJ9J0xOOCYuuFo2vBTw-i2Huj4uKw@mail.gmail.com>
Subject: Re: [PATCH] mm/hugetlb.c: cleanup to use long vars instead of int in region_count
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wang Sheng-Hui <shhuiw@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hillf Danton <dhillf@gmail.com>

On Wed, Apr 4, 2012 at 2:49 PM, David Rientjes <rientjes@google.com> wrote:
> On Wed, 7 Mar 2012, David Rientjes wrote:
>
>> On Tue, 13 Dec 2011, Wang Sheng-Hui wrote:
>>
>> > args f & t and fields from & to of struct file_region are defined
>> > as long. Use long instead of int to type the temp vars.
>> >
>> > Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
>> > ---
>> > =C2=A0mm/hugetlb.c | =C2=A0 =C2=A04 ++--
>> > =C2=A01 files changed, 2 insertions(+), 2 deletions(-)
>> >
>> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> > index dae27ba..e666287 100644
>> > --- a/mm/hugetlb.c
>> > +++ b/mm/hugetlb.c
>> > @@ -195,8 +195,8 @@ static long region_count(struct list_head *head, l=
ong f, long t)
>> >
>> > =C2=A0 =C2=A0 /* Locate each segment we overlap with, and count that o=
verlap. */
>> > =C2=A0 =C2=A0 list_for_each_entry(rg, head, link) {
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int seg_from;
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int seg_to;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 long seg_from;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 long seg_to;
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (rg->to <=3D f)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
continue;
>>
>> Acked-by: David Rientjes <rientjes@google.com>
>>

Acked-by: Hillf Danton <dhillf@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
