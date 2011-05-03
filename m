Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E002E6B0012
	for <linux-mm@kvack.org>; Mon,  2 May 2011 20:54:00 -0400 (EDT)
Received: by qwa26 with SMTP id 26so4206363qwa.14
        for <linux-mm@kvack.org>; Mon, 02 May 2011 17:53:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110502191535.2D55.A69D9226@jp.fujitsu.com>
References: <20110501163542.GA3204@barrios-desktop>
	<20110501163737.GB3204@barrios-desktop>
	<20110502191535.2D55.A69D9226@jp.fujitsu.com>
Date: Tue, 3 May 2011 09:53:58 +0900
Message-ID: <BANLkTikA-oP9ftAE_TXQdU5yBObgn2KG=g@mail.gmail.com>
Subject: Re: [RFC][PATCH] mm: cut down __GFP_NORETRY page allocation failures
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Young <hidave.darkstar@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>

On Mon, May 2, 2011 at 7:14 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Mon, May 02, 2011 at 01:35:42AM +0900, Minchan Kim wrote:
>>
>> > Do you see my old patch? The patch want't incomplet but it's not bad f=
or showing an idea.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0^^^^^^^^^^^^^=
^^^
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 typo : wasn't complete
>
> I think your idea is eligible. Wu's approach may increase throughput but

Yes. it doesn't change many subtle things and make much fair but the
Wu's concern is order-0 pages with __GFP_NORETRY. By his experiment,
my patch doesn't help much his concern.
The problem I have is I don't have any infrastructure for reproducing
his experiment. :(

> may decrease latency. So, do you have a plan to finish the work?

I want it but the day would be after finishing inorder-putback series. :)
Maybe you have a environment(8core system). If you want it, go ahead. :)

Thanks, KOSAKI.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
