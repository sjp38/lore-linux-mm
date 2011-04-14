Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8DCA0900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 09:00:48 -0400 (EDT)
Received: by bwz17 with SMTP id 17so2036315bwz.14
        for <linux-mm@kvack.org>; Thu, 14 Apr 2011 06:00:45 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: Regarding memory fragmentation using malloc....
References: <858878.89812.qm@web162015.mail.bf1.yahoo.com>
Date: Thu, 14 Apr 2011 14:31:57 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.vtxg3jzl3l0zgt@mnazarewicz-glaptop>
In-Reply-To: <858878.89812.qm@web162015.mail.bf1.yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>, Pintu Agarwal <pintu_agarwal@yahoo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Eric Dumazet <eric.dumazet@gmail.com>, Changli Gao <xiaosuo@gmail.com>, Jiri Slaby <jslaby@suse.cz>, azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>

On Thu, 14 Apr 2011 14:24:56 +0200, Pintu Agarwal  
<pintu_agarwal@yahoo.com> wrote:

> Sorry. There was a small typo in my last sentence (mitigating not  
> *migitating* memory fragmentation)
> That means how can I measure the memory fragmentation either from user  
> space or from kernel space.
> Is there a way to measure the amount of memory fragmentation in linux?

I'm still not entirely sure what you need.  You may try to measure
fragmentation by the number of low order pages -- the more low order
pages compared to high order pages the bigger the fragmentation.

As of how to mitigate...  There's memory compaction.  There's some
optimisations in buddy system.  I'm probably not the best person to
ask anyway.

-- 
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=./ `o
..o | Computer Science,  Michal "mina86" Nazarewicz    (o o)
ooo +-----<email/xmpp: mnazarewicz@google.com>-----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
