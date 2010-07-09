Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id AD4B96B02A6
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 04:26:01 -0400 (EDT)
Received: by iwn2 with SMTP id 2so2238141iwn.14
        for <linux-mm@kvack.org>; Fri, 09 Jul 2010 01:26:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100709155108.3D2A.A69D9226@jp.fujitsu.com>
References: <20100709155108.3D2A.A69D9226@jp.fujitsu.com>
Date: Fri, 9 Jul 2010 17:26:00 +0900
Message-ID: <AANLkTinhGeX1_YazJn8PHOFsPboTRmry17qHAENfZVbK@mail.gmail.com>
Subject: Re: [PATCH] vmscan: protect to read reclaim_stat by lru_lock
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 9, 2010 at 3:52 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Rik van Riel pointed out reading reclaim_stat should be protected
> lru_lock, otherwise vmscan might sweep 2x much pages.
>
> This fault was introduced by followint commit.
>
> =A0commit 4f98a2fee8acdb4ac84545df98cccecfd130f8db
> =A0Author: Rik van Riel <riel@redhat.com>
> =A0Date: =A0 Sat Oct 18 20:26:32 2008 -0700
>
> =A0 =A0vmscan: split LRU lists into anon & file sets
>
> =A0 =A0Split the LRU lists in two, one set for pages that are backed by r=
eal file
> =A0 =A0systems ("file") and one for pages that are backed by memory and s=
wap
> =A0 =A0("anon"). =A0The latter includes tmpfs.
>
> =A0 =A0The advantage of doing this is that the VM will not have to scan o=
ver lots
> =A0 =A0of anonymous pages (which we generally do not want to swap out), j=
ust to
> =A0 =A0find the page cache pages that it should evict.
>
> =A0 =A0This patch has the infrastructure and a basic policy to balance ho=
w much
> =A0 =A0we scan the anon lists and how much we scan the file lists. =A0The=
 big
> =A0 =A0policy changes are in separate patches.
>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Thanks, Kosaki. I have forgotten this issue.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
