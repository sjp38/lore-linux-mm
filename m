Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4DD7B6B0078
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 04:08:54 -0500 (EST)
Received: by pwj10 with SMTP id 10so3343065pwj.6
        for <linux-mm@kvack.org>; Wed, 13 Jan 2010 01:08:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100113172143.B3E8.A69D9226@jp.fujitsu.com>
References: <20100113171734.B3E2.A69D9226@jp.fujitsu.com>
	 <20100113172143.B3E8.A69D9226@jp.fujitsu.com>
Date: Wed, 13 Jan 2010 14:38:52 +0530
Message-ID: <661de9471001130108w2891dc5es16ec3bbca56fa9f0@mail.gmail.com>
Subject: Re: [PATCH 3/3] [v2] memcg: add anon_scan_ratio to memory.stat file
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 13, 2010 at 1:52 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Changelog
> =A0since v1: cancel to remove "recent_xxx" debug statistics as bilbir's
> =A0mention
>
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
> anon_scan_ratio feature doesn't only useful for global VM pressure
> analysis, but it also useful for memcg memroy pressure analysis.
>
> Then, this patch add anon_scan_ratio field to memory.stat file too.
>
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

[snip]

Looks good to me

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
