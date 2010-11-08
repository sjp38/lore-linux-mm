Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3C9456B004A
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 06:00:38 -0500 (EST)
Received: from eu_spt2 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LBK00K56BWZF0@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Mon, 08 Nov 2010 11:00:35 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LBK005VYBWYYN@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 08 Nov 2010 11:00:35 +0000 (GMT)
Date: Mon, 08 Nov 2010 13:03:02 +0100
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH 34/39] mm: Update WARN uses
In-reply-to: 
 <01d3ac1297677b782018d82a25e2ca82f7d1ca09.1288471898.git.joe@perches.com>
Message-id: <op.vluo3cfl7p4s8u@pikus>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Content-transfer-encoding: Quoted-Printable
References: <cover.1288471897.git.joe@perches.com>
 <01d3ac1297677b782018d82a25e2ca82f7d1ca09.1288471898.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
To: Jiri Kosina <trivial@kernel.org>, Joe Perches <joe@perches.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 30 Oct 2010 23:08:51 +0200, Joe Perches <joe@perches.com> wrote:=

> diff --git a/mm/percpu.c b/mm/percpu.c
> @@ -715,8 +715,8 @@ static void __percpu *pcpu_alloc(size_t size, size=
_t align, bool reserved)
>  	unsigned long flags;
> 	if (unlikely(!size || size > PCPU_MIN_UNIT_SIZE || align > PAGE_SIZE)=
) {
> -		WARN(true, "illegal size (%zu) or align (%zu) for "
> -		     "percpu allocation\n", size, align);
> +		WARN(true, "illegal size (%zu) or align (%zu) for percpu allocation=
\n",
> +		     size, align);
>  		return NULL;
>  	}

The above is a bit grep-unfriendly though.  Just my 0.02 PLN.

-- =

Best regards,                                        _     _
| Humble Liege of Serenely Enlightened Majesty of  o' \,=3D./ `o
| Computer Science,  Micha=C5=82 "mina86" Nazarewicz       (o o)
+----[mina86*mina86.com]---[mina86*jabber.org]----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
