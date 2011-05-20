Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id EA8126B0011
	for <linux-mm@kvack.org>; Thu, 19 May 2011 20:06:57 -0400 (EDT)
Received: by qyk2 with SMTP id 2so4509362qyk.14
        for <linux-mm@kvack.org>; Thu, 19 May 2011 17:06:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1305804982.2145.6.camel@lenovo>
References: <1305295404-12129-5-git-send-email-mgorman@suse.de>
	<4DCFAA80.7040109@jp.fujitsu.com>
	<1305519711.4806.7.camel@mulgrave.site>
	<BANLkTi=oe4Ties6awwhHFPf42EXCn2U4MQ@mail.gmail.com>
	<20110516084558.GE5279@suse.de>
	<BANLkTinW4s6aT2bZ79sHNgdh5j8VYyJz2w@mail.gmail.com>
	<20110516102753.GF5279@suse.de>
	<BANLkTi=5ON_ttuwFFhFObfoP8EBKPdFgAA@mail.gmail.com>
	<20110517103840.GL5279@suse.de>
	<1305640239.2046.27.camel@lenovo>
	<20110517161508.GN5279@suse.de>
	<BANLkTimUJeTbWV_0BzgjrDjY=Wpc-PaG5Q@mail.gmail.com>
	<1305804982.2145.6.camel@lenovo>
Date: Fri, 20 May 2011 09:06:55 +0900
Message-ID: <BANLkTin0Qdp4S8RdkAGJD0L5zvHwftvZog@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: Correctly check if reclaimer should schedule
 during shrink_slab
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Ian King <colin.king@canonical.com>
Cc: Mel Gorman <mgorman@suse.de>, akpm@linux-foundation.org, James Bottomley <James.Bottomley@hansenpartnership.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, raghu.prabhu13@gmail.com, jack@suse.cz, chris.mason@oracle.com, cl@linux.com, penberg@kernel.org, riel@redhat.com, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org

On Thu, May 19, 2011 at 8:36 PM, Colin Ian King
<colin.king@canonical.com> wrote:
> On Thu, 2011-05-19 at 09:09 +0900, Minchan Kim wrote:
>> Hi Colin.
>>
>> Sorry for bothering you. :(
>
> No problem at all, I've very happy to re-test.
>
>> I hope this test is last.
>>
>> We(Mel, KOSAKI and me) finalized opinion.
>>
>> Could you test below patch with patch[1/4] of Mel's series(ie,
>> !pgdat_balanced =C2=A0of sleeping_prematurely)?
>> If it is successful, we will try to merge this version instead of
>> various cond_resched sprinkling version.
>
> tested with the patch below + patch[1/4] of Mel's series. =C2=A0300 cycle=
s,
> 2.5 hrs of soak testing: works OK.
>
> Colin

Thanks, Colin.
We are approaching the conclusion for  your help. :)

Mel, KOSAKI.
I will ask test to Andrew Lutomirski.
If he doesn't have a problem, let's go, then.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
