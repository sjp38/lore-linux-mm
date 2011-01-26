Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 451858D0039
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 18:21:49 -0500 (EST)
Received: by iwn40 with SMTP id 40so1487114iwn.14
        for <linux-mm@kvack.org>; Wed, 26 Jan 2011 15:21:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110126150612.cf288843.akpm@linux-foundation.org>
References: <f60d811fd1abcb68d40ac19af35881d700a97cd2.1295539829.git.minchan.kim@gmail.com>
	<20110126150612.cf288843.akpm@linux-foundation.org>
Date: Thu, 27 Jan 2011 08:21:46 +0900
Message-ID: <AANLkTi=-TBzqGvq9poMDAEq1wu1NHHi_yqje33pEYxk-@mail.gmail.com>
Subject: Re: [PATCH 1/3] When migrate_pages returns 0, all pages must have
 been released
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 27, 2011 at 8:06 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri, 21 Jan 2011 01:17:05 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> From: Andrea Arcangeli <aarcange@redhat.com>
>>
>> From: Andrea Arcangeli <aarcange@redhat.com>
>>
>> In some cases migrate_pages could return zero while still leaving a
>> few pages in the pagelist (and some caller wouldn't notice it has to
>> call putback_lru_pages after commit
>> cf608ac19c95804dc2df43b1f4f9e068aa9034ab).
>>
>> Add one missing putback_lru_pages not added by commit
>> cf608ac19c95804dc2df43b1f4f9e068aa9034ab.
>>
>> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
>> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
>
> Some patch administrivia:
>
> a) you were on the delivery path for this patch, so you should have
> =A0 added your signed-off-by:. =A0I have made that change to my copy.
>
> =A0 There's no harm in also having a Reviewed-by:, but Signed-off-by:
> =A0 does imply that, we hope.
>
> b) Andrea's From: line appeared twice.
>
> c) Please choose patch titles which identify the subsystem which is
> =A0 being patched. =A0Plain old "mm:" will suit, although "mm:
> =A0 compaction:" or "mm/compaction" would be nicer.
>
> =A0 For some weird reason people keep on sending me patches with titles l=
ike
>
> =A0 =A0 =A0 =A0drivers: mmc: host: omap.c: frob the nozzle
>
> =A0 or similar. =A0I think there might be some documentation file which
> =A0 (mis)leads them to do this. =A0I simply do the utterly obvious and
> =A0 convert it to
>
> =A0 =A0 =A0 =A0drivers/mmc/host/omap.c: frob the nozzle
>
> =A0 duh.
>
> d) Please don't identify patches via bare commit IDs. =A0Because
> =A0 commits can have different IDs in different trees. =A0Instead use the
> =A0 form cf608ac19c95 ("mm: compaction: fix COMPACTPAGEFAILED
> =A0 counting"). =A0I end up having to do this operation multiple times a
> =A0 day and it's dull. =A0And sometimes I don't even have that commit ID
> =A0 in any of my trees, because they were working against some other
> =A0 tree.
>
> =A0 Also note that the 40-character commit ID has been trimmed to 12
> =A0 characters or so.
>
> Thanks.
>

I should have read SubmittingPatches, again.
Thanks!!


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
