Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6BF0D6B00A7
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 21:33:45 -0500 (EST)
Received: by gyf2 with SMTP id 2so1003556gyf.14
        for <linux-mm@kvack.org>; Mon, 08 Mar 2010 18:33:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100309095830.7d4a744d.kamezawa.hiroyu@jp.fujitsu.com>
References: <30859.1268056796@redhat.com> <20100309095830.7d4a744d.kamezawa.hiroyu@jp.fujitsu.com>
From: Mike Frysinger <vapier.adi@gmail.com>
Date: Mon, 8 Mar 2010 21:33:22 -0500
Message-ID: <8bd0f97a1003081833s2e8527d7pd1e0b427ae76020@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH] fix sync_mm_rss in nommu (Was Re: sync_mm_rss()
	issues
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Howells <dhowells@redhat.com>, torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 8, 2010 at 19:58, KAMEZAWA Hiroyuki wrote:
> David-san, could you check this ?
> =3D=3D
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Fix breakage in NOMMU build
>
> commit 34e55232e59f7b19050267a05ff1226e5cd122a5 added sync_mm_rss()
> for syncing loosely accounted rss counters. It's for CONFIG_MMU but
> sync_mm_rss is called even in NOMMU enviroment (kerne/exit.c, fs/exec.c).
> Above commit doesn't handle it well.
>
> This patch changes
> =C2=A0SPLIT_RSS_COUNTING depends on SPLIT_PTLOCKS && CONFIG_MMU
>
> And for avoid unnecessary function calls, sync_mm_rss changed to be inlin=
ed
> noop function in header file.

fixes Blackfin systems ...

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
-mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
