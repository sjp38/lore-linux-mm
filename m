Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id DF8A76B004A
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 10:51:16 -0400 (EDT)
Received: by vcbfk14 with SMTP id fk14so2816775vcb.14
        for <linux-mm@kvack.org>; Wed, 14 Mar 2012 07:51:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1203140908010.5485@router.home>
References: <CAOtvUMdVrjUHLx2jZ2xbpBoDBMCX8sdCASEkmXCtBrU-gQ3EhQ@mail.gmail.com>
	<alpine.DEB.2.00.1203140908010.5485@router.home>
Date: Wed, 14 Mar 2012 16:51:15 +0200
Message-ID: <CAOtvUMcPEbG0_CTazCgf0Tb4kinzP+nmhjWQL=Juok_Bxc-r5A@mail.gmail.com>
Subject: Re: [PATCH] mm: fix vmstat_update to keep scheduling itself on all cores
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <ak@linux.intel.com>, Linux-MM <linux-mm@kvack.org>

On Wed, Mar 14, 2012 at 4:09 PM, Christoph Lameter <cl@linux.com> wrote:
> On Wed, 14 Mar 2012, Gilad Ben-Yossef wrote:
>
>> We set up per-cpu work structures for vmstat and schedule them on
>> each cpu when they go online only to re-schedule them on the general
>> work queue when they first run.
>
> schedule_delayed_work queues on the current cpu unless the
> WQ_UNBOUND flag is set. Which is not set for vmstat_work.

I've missed that. My bad. Sorry for the noise.

Gilad



--=20
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
=A0-- Jean-Baptiste Queru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
