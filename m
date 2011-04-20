Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1B9F68D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 07:20:26 -0400 (EDT)
Received: by bwz17 with SMTP id 17so793279bwz.14
        for <linux-mm@kvack.org>; Wed, 20 Apr 2011 04:20:22 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 0/1] mm: make read-only accessors take const pointer
 parameters
References: <1302861377-8048-1-git-send-email-ext-phil.2.carmody@nokia.com>
 <20110415145133.GO15707@random.random>
 <20110415155916.GD7112@esdhcp04044.research.nokia.com>
 <20110415160957.GV15707@random.random> <1303291717.2700.20.camel@localhost>
Date: Wed, 20 Apr 2011 13:20:19 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.vt8hr5j73l0zgt@mnazarewicz-glaptop>
In-Reply-To: <1303291717.2700.20.camel@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Artem Bityutskiy <dedekind1@gmail.com>
Cc: Phil Carmody <ext-phil.2.carmody@nokia.com>, akpm@linux-foundation.org, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 20 Apr 2011 11:28:37 +0200, Artem Bityutskiy <dedekind1@gmail.com>  
wrote:
> I think it is good when small core functions like this are strict and
> use 'const' whenever possible, even though 'const' is so imperfect in C.
>
> Let me give an example from my own experience. I was writing code which
> was using the kernel RB trees, and I was trying to be strict and use
> 'const' whenever possible. But because the core functions like 'rb_next'
> do not have 'const' modifier, I could not use const in many many places
> of my code, because gcc was yelling. And I was not very enthusiastic to
> touch the RB-tree code that time.

The problem is that you end up with two sets of functions (one taking const
another taking non-const), a bunch of macros or a function that takes const
but returns non-const.  If we settle on anything I would probably vote for
the last option but the all are far from ideal.

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
