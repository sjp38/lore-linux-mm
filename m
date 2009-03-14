Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BAD566B0047
	for <linux-mm@kvack.org>; Sat, 14 Mar 2009 07:17:41 -0400 (EDT)
Received: by wf-out-1314.google.com with SMTP id 28so820172wfa.11
        for <linux-mm@kvack.org>; Sat, 14 Mar 2009 04:17:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090313173353.10169.23515.stgit@warthog.procyon.org.uk>
References: <20090313173343.10169.58053.stgit@warthog.procyon.org.uk>
	 <20090313173353.10169.23515.stgit@warthog.procyon.org.uk>
Date: Sat, 14 Mar 2009 20:17:40 +0900
Message-ID: <2f11576a0903140417p390e15e6o316916c764a16616@mail.gmail.com>
Subject: Re: [PATCH 2/2] NOMMU: Make CONFIG_UNEVICTABLE_LRU available when
	CONFIG_MMU=n
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>
Cc: minchan.kim@gmail.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, peterz@infradead.org, nrik.Berkhan@ge.com, uclinux-dev@uclinux.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, riel@surriel.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

> diff --git a/mm/Kconfig b/mm/Kconfig
> index 8c89597..b53427a 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -206,7 +206,6 @@ config VIRT_TO_BUS
> =A0config UNEVICTABLE_LRU
> =A0 =A0 =A0 =A0bool "Add LRU list to track non-evictable pages"
> =A0 =A0 =A0 =A0default y
> - =A0 =A0 =A0 depends on MMU
> =A0 =A0 =A0 =A0help
> =A0 =A0 =A0 =A0 =A0Keeps unevictable pages off of the active and inactive=
 pageout
> =A0 =A0 =A0 =A0 =A0lists, so kswapd will not waste CPU time or have its b=
alancing

   Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
