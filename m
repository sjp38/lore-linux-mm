Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 750756B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 09:14:13 -0400 (EDT)
Received: by yx-out-1718.google.com with SMTP id 4so1405714yxp.26
        for <linux-mm@kvack.org>; Mon, 16 Mar 2009 06:14:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <28c262360903160555u402b4c34nf273951a207826a2@mail.gmail.com>
References: <20090316105945.18131.82359.stgit@warthog.procyon.org.uk>
	 <20090316120224.GA16506@infradead.org>
	 <20090316211830.1FE8.A69D9226@jp.fujitsu.com>
	 <28c262360903160555u402b4c34nf273951a207826a2@mail.gmail.com>
Date: Mon, 16 Mar 2009 22:14:11 +0900
Message-ID: <2f11576a0903160614n4908d0fdo25df387dd724ac19@mail.gmail.com>
Subject: Re: [PATCH] Point the UNEVICTABLE_LRU config option at the
	documentation
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, David Howells <dhowells@redhat.com>, lee.schermerhorn@hp.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2009/3/16 Minchan Kim <minchan.kim@gmail.com>:
> size vmlinux
> =A0 text =A0 =A0data =A0 =A0 bss =A0 =A0 dec =A0 =A0 hex filename
> 6232681 =A0747665 =A0708608 7688954 =A07552fa vmlinux
>
> size vmlinux.unevictable
> =A0 text =A0 =A0data =A0 =A0 bss =A0 =A0 dec =A0 =A0 hex filename
> 6239404 =A0747985 =A0708608 7695997 =A0756e7d vmlinux.unevictable
>
> It almost increases about 7K.
> Many embedded guys always have a concern about size although it is very s=
mall.
> It's important about embedded but may not be about server.

Thanks good report.
this is unintetional size to me. I'll digg it later.

Thanks!


-- kosaki


>
> In addition, CONFIG_UNEVICTABLE_LRU feature don't have a big impact in
> embedded machines which have a very small ram.
> I guess many embedded guys will not use this feature.
>
> So, I don't want to remove this configurable option.
> Lets not add useless size bloat in embedded system.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
